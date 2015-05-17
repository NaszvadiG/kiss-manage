<?php
/*
 * Model that corresponds to the business controller.
 */
class Business_model extends MY_model {
    public function __construct() {
        // For completeness
    }

    // Functions to manipulate time entry records
    public function getTimeEntry($id) {
        return $this->getRow($id, 'time_entries', "*, TIMESTAMPDIFF(MINUTE, start_time, NOW()) AS diff");
    }

    public function getTimeEntries($where = array()) {
        return $this->getRows($where, 'time_entries', array('entry_date' => 'DESC', 'id' => 'DESC'), "*, TIMESTAMPDIFF(MINUTE, start_time, NOW()) AS diff");
    }

    public function deleteTimeEntry($id) {
        $this->deleteRow($id, 'time_entries');
    }

    public function setTimeEntries($id, $data, $handle_time = true) {
        $id = (int)$id;

        // Only do the following if we are updating time and need to do calculations
        if($handle_time) {
            // First if we have an id get the current record to use to see how to handle time
            $prev_time = 0;
            if($id > 0 ) {
                $check = $this->getTimeEntry($id);
                if($check['start_time'] != '0000-00-00 00:00:00') {
                    // There is a current timer running, don't update the time even if its passed in
                    unset($data['total_time']);
                }
                $prev_time = (int)$check['total_time'];
            } else {
                if(!isset($data['total_time']) || $data['total_time'] <= 0) {
                    $data['start_time'] = date('Y-m-d H:i:s');
                }
            }

            // If we have a valid time value passed set that if needed
            if(isset($data['total_time'])) {
                $parts = array();
                if(preg_match("/^(\d{0,2}):(\d{2})$/", $data['total_time'], $parts)) {
                    $hours = $parts[1];
                    $mins = $parts[2];
                    $updated_time = ($hours * 60) + $mins;
                    if($prev_time != $updated_time) {
                        $data['total_time'] = $updated_time;
                        $data['start_time'] = '0000-00-00 00:00:00';
                    } else {
                        unset($data['total_time']);
                    }
                } else {
                    unset($data['total_time']);
                }
            }
        }
        
        // Set the row in the DB
        return $this->setRow($id, $data, 'time_entries');
    }

    public function setTimeClock($id) {
        if($id > 0) {
            $data = array();
            $check = $this->getTimeEntry($id);
            $check['diff'] = (int)$check['diff'];

            if($check['start_time'] == '0000-00-00 00:00:00') {
                // We are starting a timer
                $data['start_time'] = date('Y-m-d H:i:s');
            } else {
                // We are stopping a timer
                $data['start_time'] = '0000-00-00 00:00:00';
                $data['total_time'] = $check['total_time'] + $check['diff'];
            }
            $this->setTimeEntries($id, $data, false);
        }
    }

    // Functions to manipulate invoice data
    public function deleteInvoice($id) {
        if($this->deleteRow($id, 'invoices')) {
            $this->db->update("time_entries", array('invoice_id' => 0), array('invoice_id' => $id));
        }
    }

    public function setInvoice($id, $data) {
        return $this->setRow($id, $data, 'invoices');
    }

    public function getInvoice($id) {
        return $this->getRow($id, 'invoices');
    }

    public function getInvoices($where = array()) {
        return $this->getRows($where, 'invoices', array('created_date' => 'DESC', 'id' => 'DESC'));
    }

    public function getInvoiceDetail($id = 0, $rate = 0) {
        $id = (int)$id;
        $return = array();
        if($id > 0 ) {
            $query = $this->db->get_where('time_entries', array('invoice_id' => $id));
            $return = $query->result_array();
            $this->calculateTimeEntriesTotals($return, $rate);
        }
        return $return;
    }

    // Function to create an invoice (and all that comes with it)
    public function createInvoice($invoice, $start_date, $end_date) {
        $this->load->model('financials_model');
        $time_entry_ids = array();
        $id = 0;
        $total = 0;
        $default_rate = 0;

        if(!empty($invoice)) {
            $client_id = (int)$invoice['client_id'];
            if($client_id > 0) {
                // Look up our default rate for the client
                $client = $this->financials_model->getClient($client_id);
                if(!empty($client)) {
                    $default_rate = $client['default_rate'];
                }

                // Get our uninvoiced time entries based on our dates we got
                $this->db->where('client_id', $client_id);
                $this->db->where('entry_date >=', $start_date);
                $this->db->where('entry_date <=', $end_date);
                $this->db->where('invoice_id', 0);
                $query = $this->db->get('time_entries');
                $time_entries = $query->result_array();
                $total = $this->calculateTimeEntriesTotals($time_entries, $default_rate);

                // If we have a total create the invoice and return the ID
                if($total > 0) {
                    $invoice['amount'] = $total;
                    $id = $this->setInvoice($id, $invoice);

                    // Set all the corresponding time entries to reflect that they are on this invoice
                    foreach($time_entries as $row) {
                        $this->setTimeEntries($row['id'], array('invoice_id' => $id), false);
                    }
                }
            }
        }
        return $id;
    }

    // Function to calculate the totals for an array of time entries
    private function calculateTimeEntriesTotals(&$time_entries, $default_rate) {
        $total = 0;
        foreach($time_entries as $key => $row) {
            $rate = 0;
            if($row['rate'] > 0) {
                $rate = $row['rate'];
            } else {
                $rate = $default_rate;
            }
            $entry_time = round(($row['total_time'] / 60), 2);
            $entry_total = round($entry_time * $rate, 2);
            $total += $entry_total;
            $time_entries[$key]['entry_total'] = $entry_total;
            $time_entries[$key]['effective_rate'] = $rate;
        }
        return $total;
    }
}
