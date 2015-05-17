<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Media extends MY_Controller {
    public function __construct() {
        parent::__construct();
        $this->load->model('media_model');
        $this->load->library('tvdb');
        $this->setMenu('media');
    }

    // Function to display the main movie list page
	public function movies() {
        $data = array();
        $data['movies'] = $this->media_model->getMovies();
        $this->templateDisplay('media/movies.tpl', $data);
	}

    // Function to display the main TV liist page
    public function tv() {
        $data = array();
        $data['shows'] = $this->media_model->getTvShows();
        $data['counts'] = $this->media_model->getSeasonCounts();
        $this->templateDisplay('media/tv.tpl', $data);
	}

    // Function to display the main TV edit page
    public function editTv($id = 0) {
        $data = array();
        if($id > 0) {
            $data = $this->media_model->getTvShow($id);
            $data['seasons'] = $this->media_model->getTvSeasons(array('tv_shows_id' => $id));
            foreach($data['seasons'] as $season) {
                $data['episodes'][$season['id']] = $this->media_model->getSeasonEpisodeSummary($season['id']);
            }
        }
        $this->templateDisplay('media/tv_edit.tpl', $data);
	}

    // Function to dispaly the edit season page and episode listing
    public function editSeason($season_id = 0, $tv_shows_id = 0){
        $data = array();
        $this->setSubmenu('tv');
        if($season_id > 0) {
            $data['season'] = $this->media_model->getTvSeason($season_id);
            if(!empty($data['season'])) {
                $data['show'] = $this->media_model->getTvShow($data['season']['tv_shows_id']);
                $data['episodes'] = $this->media_model->getTvEpisodes(array('tv_seasons_id' => $data['season']['id']));
            }
        } elseif($tv_shows_id > 0) {
            // Adding a new season
            $data['season']['id'] = 0;
            $data['season']['tv_shows_id'] = $tv_shows_id;
        } else {
            redirect('/media/tv');
        }
        $this->templateDisplay('media/tv_season_edit.tpl', $data);
	}

    // Function to process the submit of the editSeason page and send them back there when done
    public function doEditSeason() {
        $season_id = (int)$this->input->post('season_id');
        $season = $this->input->post('season');
        $episodes = $this->input->post('eps');
        $new_episodes = $this->input->post('neweps');
       
        // Update the season data
        $season_id = $this->media_model->setTvSeason($season_id, $season);

        // Update the existing episode data
        if(is_array($episodes)) {
            foreach($episodes as $id => $updates) {
                // If we are deleting this record then we don't care about updating
                if(isset($updates['delete']) && $updates['delete'] == 1) {
                    $this->media_model->deleteTvEpisode($id);
                } else {
                    if(!isset($updates['downloaded']) || $updates['downloaded'] != 1) {
                        $updates['downloaded'] = 0;
                    }
                    $this->media_model->setTvEpisode($id, $updates);
                }
            }
        }

        // Add any new episodes
        if(is_array($new_episodes)) {
            foreach($new_episodes as $id => $updates) {
                $updates['tv_seasons_id'] = $season_id;
                if(!isset($updates['downloaded']) || $updates['downloaded'] != 1) {
                    $updates['downloaded'] = 0;
                }
                $this->media_model->setTvEpisode(0, $updates);
            }
        }

        $this->setMessage('Season successfully saved');
        redirect("/media/editSeason/$season_id");
    }

    // Function to display the pending tv page
    public function pendingTv() {
        // Set the default end date if we don't have one set
        $session_end_date = $this->session->userdata('pending_tv_end_date_filter');
        $end_date = date('Y-m-01', strtotime('-1 month'));
        if($this->input->post('end_date')) {
            $end_date = $this->input->post('end_date');
            $this->session->set_userdata('pending_tv_end_date_filter', $end_date);
        } elseif (!empty($session_end_date)) {
            $end_date = $session_end_date;
        }
        $data['end_date'] = $end_date;
        $data['pending_tv'] = $this->media_model->getTvShowsPending($end_date);
        $this->templateDisplay('media/tv_pending.tpl', $data);
	}
    
    // Function to refresh a show from TVDB via their API
    public function refreshTVDB($id) {
        $this->tvdb->syncShows($id);
        $this->setMessage('Show successfully refreshed from TVDB');
        redirect("/media/editTv/$id");
	}
    
    // Functon to handle an edit of a tv show form
    public function doEditTv() {
        $id = $this->input->post('id');
        $name = $this->input->post('name');
        $data = $this->input->post(array('name', 'folder', 'location', 'last_updated', 'tvdb_seriesid'));
        $data['status'] = (int)$this->input->post('status');
        $id = $this->media_model->setTvShow($id, $data);
        $this->setMessage('Show successfully saved');
        redirect("/media/editTv/$id");
	}

    // Function to delete a TV season and any associated episodes from a tv show
    public function deleteTvSeason() {
        $tv_shows_id = $this->input->post('tv_shows_id');
        $season_id = $this->input->post('season_id');
        $message = $this->input->post('message');
        if($this->media_model->deleteTvSeason($season_id)) {
            $this->setMessage("Deleted $message");
        }
        redirect("/media/editTv/$tv_shows_id");
    }
    
    // Function to delete a TV show and any associated seasons/episodes
    public function deleteTvShow() {
        $id = $this->input->post('delete_show_id');
        $message = $this->input->post('message');
        if($this->media_model->deleteTvShow($id)) {
            $this->setMessage("Deleted TV show $message");
        }
        redirect("/media/tv");
    }

    // Function to set an entire TV show downloaded.  Mainly called with backfilling data
    public function setShowDownloaded($id) {
        $seasons = $this->media_model->getTvSeasons(array('tv_shows_id' => $id));
        $update = array('downloaded' => 1);
        foreach($seasons as $season) {
            $episodes = $this->media_model->getTvEpisodes(array('tv_seasons_id' => $season['id']));
            foreach($episodes as $episode) {
                $this->media_model->setTvEpisode($episode['id'], $update);
            }
        }
        $this->setMessage('Show successfully saved');
        redirect("/media/editTv/$id");
    }

    // Function to set an episode downloaded.  Called from the checkmark links on the pending TV page
    public function setEpisodeDownloaded($id) {
        $this->media_model->setTvEpisode($id, array('downloaded' => 1));
        redirect("/media/pendingTv");
    }
}