<?php
defined('BASEPATH') OR exit('No direct script access allowed');
/*
 * Controller used for running batch processes from the command line.  For instance, calling it as follows:
 * 
 * php public/index.php batch syncTVDBInc
 */
class Batch extends CI_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->library('tvdb');
        $this->load->library('email');

        // Only allow running from cli
        if(!is_cli()) {
            exit('Only available from cli...');
        }
    }

    // Private function used to send email notifications from the processes as desired
    private function sendTVDBNotification($updates, $type) {
        $message = "The following is a summary of the $type TVDB sync processing run at: " . date('Y-m-d H:i:s') . "\n\n";
        foreach($updates as $line) {
            $message .= "$line";
        }

        $this->email->initialize(array('wrapchars' => 120));
        $this->email->from('noreply@careydrive.com', 'TVDB Updater');
        $this->email->to('brian@careydrive.com');
        $this->email->subject("TVDB Update - $type");
        $this->email->message($message);
        $this->email->send();
    }

    // Function used to do a full sync of all TV shows we have against TVDB
    public function syncTVDBFull() {
        // Sync all of our shows that have a tvdbid set
        $updates = $this->tvdb->syncShows(0, 1);

        // Send a notification message
        $this->sendTVDBNotification($this->tvdb->getSummary(), 'Full');
    }
    
    // Function to do an incremental sync of updates from TVDB based on the last updated timestamp
    public function syncTVDBInc() {
        $updates = $this->tvdb->syncUpdates(1);

        // Send a notification message
        $this->sendTVDBNotification($this->tvdb->getSummary(), 'Incremental');
    }
}