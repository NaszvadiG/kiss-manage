<?php defined('BASEPATH') OR exit('No direct script access allowed');

class Tvdb {

    protected $CI;
    private $tvdb_key = "";
    private $tvdb_url = "";
    private $tvdb_time = 0;
    private $logging = false;
    private $summary = array();
    private $status = true;

    public function __construct()
    {
        // Assign the CodeIgniter super-object
        $this->CI =& get_instance();
        $this->CI->load->model('media_model');
        $this->CI->load->model('config_model');
        $this->CI->load->library('curl');

        $this->tvdb_key = $this->CI->config_model->getOption('tvdb_key');
        $this->tvdb_url = $this->CI->config_model->getOption('tvdb_url');
    }
    
    private function log($str, $summary = true) {
        if($this->logging) {
            $msg = date('Y-m-d H:i:s') . " -> $str\n";
            echo $msg;
            if($summary) {
                $this->summary[] = $msg;
            }
        }
    }

    public function getSummary() {
        return $this->summary;
    }

    public function syncUpdates($log = 0) {
        $this->logging = $log;

        // Get the updates since our last refresh and then set the time
        $updates = $this->getUpdates();
        
        // Process the show data for updates
        foreach($updates['shows'] as $seriesid) {
            $this->log("Processing seriesid: $seriesid", false);
            $update = $this->getSeries($seriesid);
            $this->updateShow($update);
        }

        // Now process the episodes to see which may be of concern
        foreach($updates['episodes'] as $episodeid) {
            $this->log("Processing episodeid: $episodeid", false);
            $update = $this->getEpisode($episodeid);
            $this->processEpisodes($update);
        }
        
        // Set our time
        $this->setTime($updates['time']);
    }

    public function syncShows($id = 0, $log = 0) {
        $this->logging = $log;

        if($id > 0) {
            // we just want to refresh a single show, regardless of its init state
            $shows[] = $this->CI->media_model->getTvShow($id);
        } else {
            // Get all shows that are active
            $shows = $this->CI->media_model->getTvShows(array('tvdb_seriesid >' => 0, 'status' => 1));
        }

        // Set our timestamp in the database for incremental updates
        $this->setTime();

        foreach($shows as $show) {
            // log if desired
            $this->log("Checking show {$show['name']} for TVDB episodes", false);

            // Get all the series data
            $results = $this->getSeries($show['tvdb_seriesid'], true);

            // Process the show data for updates
            $this->updateShow($results, $show);

            // Process the episode data for new/updated records
            $this->processEpisodes($results, $show);
        }
    }

    private function processEpisodes($results, $show = array()) {
        foreach($results['episodes'] as $seasonid => $episodes) {
            foreach($episodes as $episodeid => $data) {
                $seriesid = $data['seriesid'];
                $season = $data['season'];
                $episode = $data['episode'];
                $air_date = $data['date'];

                // If we didn't have a show record passed in, look it up
                if(empty($show)) {
                    if($show = $this->CI->media_model->getTvShows(array('tvdb_seriesid' => $seriesid))) {
                        $show = $show[0];
                    }
                }

                if(!empty($show)) {
                    $name = $show['name'];
                    $id = $show['id'];

                    // Check to see if we need to add this season
                    $check = $this->CI->media_model->getTvSeasons(array('tvdb_seasonid' => $seasonid));
                    if(empty($check)) {
                        $new = array('tv_shows_id' => $id, 'season' => $season, 'tvdb_seasonid' => $seasonid);
                        $tv_seasons_id = $this->CI->media_model->setTvSeason(0, $new);

                        $this->log("Adding new season $season to show $name");
                    } else {
                        $check = $check[0];
                        $tv_seasons_id = $check['id'];
                    }

                    // And check to see if we need to add this episode
                    $check = $this->CI->media_model->getTvEpisodes(array('tvdb_id' => $episodeid));
                    if(empty($check)) {
                        $new = array('tv_seasons_id' => $tv_seasons_id, 'episode' => $episode, 'tvdb_id' => $episodeid, 'air_date' => $air_date);
                        $this->CI->media_model->setTvEpisode(0, $new);

                        $this->log("Adding new episode s{$season}e{$episode} ($air_date) to show $name");
                    } else {
                        $check = $check[0];
                        if(!empty($air_date) && $check['air_date'] != $air_date) {
                            $update = array('air_date' => $air_date);
                            $this->CI->media_model->setTvEpisode($check['id'], $update);

                            $this->log("Updating episode s{$season}e{$episode} ($air_date) for show $name");
                        }
                    }
                }
            }
        }
    }

    private function updateShow($results, $show = array()) {
        if(empty($show) && isset($results['seriesid'])) {
            $show = $this->CI->media_model->getTvShows(array('tvdb_seriesid' => $results['seriesid']));
        }
        if(!empty($show)) {
            $show = $show[0];
            $last_updated = false;
            if(isset($results['last_updated']) && !empty($results['last_updated'])) {
                $last_updated = date('Y-m-d', $results['last_updated']);
            }
            if(!empty($last_updated) && $last_updated != $show['last_updated']) {
                $this->CI->media_model->setTvShow($show['id'], array('last_updated' => $last_updated));
                $this->log("Updated show {$show['name']} to reflect last_updated date of $last_updated");
            }
        }
    }

    private function getTVDB($path, $key = false) {
        $return = new stdClass();
        $url = $this->tvdb_url;
        if($key) {
            $url .= "/{$this->tvdb_key}";
        }
        $url .= "/$path";

        $response = '';
        try{
            $response = $this->CI->curl->simple_get($url);
            $return = new SimpleXmlElement($response, LIBXML_NOCDATA);
        } catch(Exception $e) {
            $this->log("Unable to parse response from TVDB API.  Exception: " . $e->getMessage() . ".  URL: $url. Response: $response");
            //$this->status = false;
        }
        return $return;
    }

    public function getUpdates() {
        $return = array('shows' => array(), 'episodes' => array(), 'time' => 0);
        $previoustime = $this->CI->config_model->getOption('tvdb_time');
        if($previoustime) {
            $response = $this->getTVDB("Updates.php?type=all&time=$previoustime");
            if(isset($response->Time)) {
                $return['time'] = (string)$response->Time;
            }
            if(isset($response->Series) && !empty($response->Series)) {
                $return['shows'] = (array)$response->Series;
            }
            if(isset($response->Episode) && !empty($response->Episode)) {
                $return['episodes'] = (array)$response->Episode;
            }
        }
        return $return;
    }
    
    public function getTime() {
        $response = $this->getTVDB("Updates.php?type=none");
        if(isset($response->Time)) {
            $this->tvdb_time = $response->Time;
        }
        return $this->tvdb_time;
    }

    public function setTime($time = 0) {
        if($this->status) {
            if($time > 0) {
                $this->tvdb_time = $time;
            }
            if($this->tvdb_time <= 0) {
                $this->getTime();
            }
            $this->CI->config_model->setOption(array('name' => 'tvdb_time', 'value' => (string)$this->tvdb_time));
            $this->log("Set TVDB time to " . (string)$this->tvdb_time);
        }
    }

    private function getSeriesByName($name) {   
        $name = (string)$name;
        $return = array();
        if(!empty($name)) {
            $name = urlencode($name);
            $response = $this->getTVDB("GetSeries.php?seriesname=$name");
            if(isset($response->Series)) {
                foreach($response->Series as $series) {
                    $series = (array)$series;
                    $return[$series['seriesid']] = $series;
                }
            }
        }
        return $return;
    }

    private function getSeries($seriesid, $all = false) {
        $return = array('show' => array(), 'episodes' => array());
        if(!empty($seriesid)) {
            if($all) {
                $results = $this->getTVDB("series/$seriesid/all", true);
            } else {
                $results = $this->getTVDB("series/$seriesid/en.xml", true);
            }

            if(isset($results->Series)) {
                $return['seriesid'] = (int)$results->Series->id;
                $return['last_updated'] = (int)$results->Series->lastupdated;
            }

            $return['episodes'] = $this->parseEpisodes($results);
        }
        return $return;
    }

    private function getEpisode($episodeid) {
        $return = array();
        $episodeid = (int)$episodeid;
        if($episodeid > 0) {
            $results = $this->getTVDB("episodes/$episodeid/en.xml", true);
            $return['episodes'] = $this->parseEpisodes($results);
        }
        return $return;
    }

    private function parseEpisodes($xml) {
        $return = array();
        if(isset($xml->Episode)) {
            foreach($xml->Episode as $episode) {
                $season = (int)$episode->SeasonNumber;
                $episode_number = (int)$episode->EpisodeNumber;
                $seasonid = (int)$episode->seasonid;
                $episodeid = (int)$episode->id;
                $seriesid = (int)$episode->seriesid;
                $date = (string)$episode->FirstAired;
                if($season > 0 && $episode_number > 0) {
                    $return[$seasonid][$episodeid] = array('seriesid' => $seriesid, 'date' => $date, 'season' => $season, 'episode' => $episode_number);
                }
            }
        }
        return $return;
    }
}