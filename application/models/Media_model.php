<?php
/*
 * Model that corresponds to the media controller.
 */
class Media_model extends MY_Model {
    public function __construct() {
        $this->load->database();
    }

    // Functions to manipulate movie records
    public function getMovie($id) {
        return $this->getRow($id, 'movies');
    }

    public function getMovies($where = array()) {
        return $this->getRows($where, 'movies');
    }

    public function setMovie($id, $data) {
        return $this->setRow($id, $data, 'movies');
    }

    public function deleteMovie($id) {
        $this->deleteRow($id, 'movies');
    }

    // Functions to manipulate tv records
    public function getTvShow($id) {
        return $this->getRow($id, 'tv_shows');
    }

    public function getTvShows($where = array()) {
        return $this->getRows($where, 'tv_shows');
    }

    public function setTvShow($id, $data) {
        // first check that we don't have it already if adding a new show
        if($id <= 0 && isset($data['name'])) {
            $check = $this->getTvShows(array('name' => $data['name']));
            if(!empty($check)) {
                $check = current($check);
                return $check['id'];
            }
        }

        // Go ahead and add/update
        return $this->setRow($id, $data, 'tv_shows');
    }

    public function deleteTvShow($id) {
        $seasons = $this->getTvSeasons(array('tv_shows_id' => $id));
        foreach($seasons as $season) {
            $this->deleteTvSeason($season['id']);
        }
        return $this->deleteRow($id, 'tv_shows');
    }

    // Functions to manipulate tv_seasons records
    public function getTvSeason($id) {
        return $this->getRow($id, 'tv_seasons');
    }

    public function getTvSeasons($where = array()) {
        return $this->getRows($where, 'tv_seasons');
    }

    public function setTvSeason($id, $data) {
        if(!isset($data['end_date'])) {
            $data['end_date'] = '0000-00-00';
        }
        return $this->setRow($id, $data, 'tv_seasons');
    }

    public function deleteTvSeason($id) {
        if($this->deleteRow($id, 'tv_seasons')) {
            return $this->db->delete('tv_episodes', array('tv_seasons_id' => $id));
        }
        return false;
    }

    public function getSeasonCounts($tv_shows_id = 0) {
        $where = array();
        $return = array();
        if($tv_shows_id > 0) {
           $where['tv_shows_id'] = $tv_shows_id;
        }
        $seasons = $this->getTvSeasons($where);
        foreach($seasons as $season) {
            if(isset($return[$season['tv_shows_id']])) {
                $return[$season['tv_shows_id']]++;
            } else {
                $return[$season['tv_shows_id']] = 1;
            }
        }
        return $return;
    }

    // Functions to manipulate tv_episodes records
    public function getTvEpisode($id) {
        return $this->getRow($id, 'tv_episodes');
    }

    public function getTvEpisodes($where = array()) {
        return $this->getRows($where, 'tv_episodes');
    }

    public function setTvEpisode($id, $data) {
        return $this->setRow($id, $data, 'tv_episodes');
    }

    public function deleteTvEpisode($id) {
        $this->deleteRow($id, 'tv_episodes');
    }

    public function getSeasonEpisodeSummary($tv_seasons_id) {
        $return = array('last_downloaded' => '0000-00-00', 'end_date' => '0000-00-00', 'downloaded_episodes' => 0);
        $rows = $this->getTvEpisodes(array('tv_seasons_id' => $tv_seasons_id));
        if(!empty($rows)) {
            $return['episodes'] = count($rows);
            foreach($rows as $row) {
                if($row['downloaded']) {
                    $return['downloaded_episodes']++;
                }
                $return['end_date'] = $row['air_date'];
            }
        }
        return $return;
    }

    public function getTvShowsPending($end_date) {
        // Get the shows that are currently airing and up to be downloaded
        $today = date('Y-m-d');
        $query = $this->db->query("SELECT t.id AS id, t.name, s.id AS season_id, s.season, e.id AS episode_id, e.episode, e.air_date FROM tv_shows AS t INNER JOIN tv_seasons AS s ON t.id = s.tv_shows_id INNER JOIN tv_episodes AS e ON s.id = e.tv_seasons_id WHERE t.status = 1 AND e.downloaded = 0 AND e.air_date != '0000-00-00' AND e.air_date >= '$end_date' AND e.air_date <= '$today' ORDER BY e.air_date DESC, t.name ASC");
        return $query->result_array();
    }

    public function getTvShowsSpecialNotes() {
        // Get any shows that we have entered special notes for in order to keep an eye on them
        return $this->getTvShows(array('status' => 1, 'special_notes !=' => ''));
    }
}
