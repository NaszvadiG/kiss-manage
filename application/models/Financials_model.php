<?php
/*
 * Model that corresponds to the Financials controller.
 */
class Financials_model extends MY_Model {
    public function __construct() {
        $this->load->database();
    }

    // Functions to manipulate client records
    public function getClient($id) {
        return $this->getRow($id, 'clients');
    }

    public function getClients() {
        return $this->getRows(array(), 'clients', array('name' => 'ASC'));
    }

    public function setClient($id, $data) {
        return $this->setRow($id, $data, 'clients');
    }

    public function deleteClient($id, $transfer_id = 0) {
        $transfer_id = (int)$transfer_id;
        if($this->deleteRow($id, 'clients')) {
            // If we are transfering related records, run those updates.
            if($transfer_id > 0) {
                $this->db->update("income", array('client_id' => $transfer_id), array('client_id' => $id));
            }
        }
    }

    // Functions to manipulate tax category records
    public function getTaxCategory($id) {
        return $this->getRow($id, 'tax_categories');
    }

    public function getTaxCategories() {
        return $this->getRows(array(), 'tax_categories', array('name' => 'ASC'));
    }

    public function setTaxCategory($id, $data) {
        return $this->setRow($id, $data, 'tax_categories');
    }

    public function deleteTaxCategory($id, $transfer_id = 0) {
        $transfer_id = (int)$transfer_id;
        if($this->deleteRow($id, 'tax_categories')) {
            // If we are transfering related records, run those updates.
            if($transfer_id > 0) {
                $this->db->update("tax", array('category_id' => $transfer_id), array('category_id' => $id));
            }
        }
    }

    // Functions to manipulate utility category records
    public function getUtilityCategory($id = 0) {
        return $this->getRow($id, 'utilities_categories');
    }

    public function getUtilityCategories() {
        return $this->getRows(array(), 'utilities_categories', array('name' => 'ASC'));
    }

    public function setUtilityCategory($id, $data) {
        return $this->setRow($id, $data, 'utilities_categories');
    }

    public function deleteUtilityCategory($id, $transfer_id = 0) {
        $transfer_id = (int)$transfer_id;
        if($this->deleteRow($id, 'utilities_categories')) {
            // If we are transfering related records, run those updates.
            if($transfer_id > 0) {
                $this->db->update("utilities", array('category_id' => $transfer_id), array('category_id' => $id));
            }
        }
    }
    
    // Functions to mainipulate checking account records
    public function getChecksAccount($id) {
        return $this->getRow($id, 'checks_accounts');
    }
    
    public function getChecksAccounts() {
        return $this->getRows(array(), 'checks_accounts', array('name' => 'ASC'));
    }

    public function setChecksAccount($id, $data) {
        return $this->setRow($id, $data, 'checks_accounts');
    }

    public function deleteChecksAccount($id, $transfer_id = 0) {
        $transfer_id = (int)$transfer_id;
        if($this->deleteRow($id, 'checks_accounts')) {
            // If we are transfering related records, run those updates.
            if($transfer_id > 0) {
                $this->db->update("checks", array('account_id' => $transfer_id), array('account_id' => $id));
                $this->db->update("income", array('account_id' => $transfer_id), array('account_id' => $id));
            }
        }
    }

    // Functions to manipulate receipt records
    public function getReceipt($id) {
        return $this->getRow($id, 'receipts');
    }

    public function getReceipts($where = array()) {
        return $this->getRows($where, 'receipts', array('receipt_date' => 'DESC', 'id' => 'DESC'));
    }

    public function setReceipt($id, $data) {
        return $this->setRow($id, $data, 'receipts');
    }

    public function deleteReceipt($id) {
        $this->deleteRow($id, 'receipts');
    }

    // Functions to manipulate receipt category records
    public function getReceiptCategory($id) {
        return $this->getRow($id, 'receipts_categories');
    }

    public function getReceiptCategories($where = array()) {
        return $this->getRows($where, 'receipts_categories', array('deductible' => 'ASC', 'name' => 'ASC'));
    }

    public function setReceiptCategory($id, $data) {
        return $this->setRow($id, $data, 'receipts_categories');
    }

    public function deleteReceiptCategory($id, $transfer_id = 0) {
        $transfer_id = (int)$transfer_id;
        if($this->deleteRow($id, 'receipts_categories')) {
            // If we are transfering related records, run those updates.
            if($transfer_id > 0) {
                $this->db->update("receipts", array('category_id' => $transfer_id), array('category_id' => $id));
            }
        }
    }

    // Functions to manipulate deductible records
    public function getDeductible($id) {
        return $this->getRow($id, 'deductibles');
    }

    public function getDeductibles() {
        return $this->getRows(array(), 'deductibles', array('name' => 'ASC'));
    }

    public function setDeductible($id, $data) {
        return $this->setRow($id, $data, 'deductibles');
    }

    public function deleteDeductible($id, $transfer_id = 0) {
        $transfer_id = (int)$transfer_id;
        if($this->deleteRow($id, 'deductibles')) {
            // If we are transfering related records, run those updates.
            if($transfer_id > 0) {
                $this->db->update("receipts_categories", array('deductible' => $transfer_id), array('deductible' => $id));
            }
        }
    }

    // Functions to manipulate utility records
    public function getUtility($id) {
        return $this->getRow($id, 'utilities');
    }

    public function getUtilities($where = array()) {
        return $this->getRows($where, 'utilities', array('paid_date' => 'DESC', 'id' => 'DESC'));
    }

    public function setUtility($id, $data) {
        return $this->setRow($id, $data, 'utilities');
    }

    public function deleteUtility($id) {
        $this->deleteRow($id, 'utilities');
    }

    // Functions to manipulate check records
    public function getCheck($id) {
        return $this->getRow($id, 'checks');
    }

    public function getChecks($where = array()) {
        return $this->getRows($where, 'checks', array('check_date' => 'DESC', 'id' => 'DESC'));
    }

    public function setCheck($id, $data) {
        return $this->setRow($id, $data, 'checks');
    }

    public function deleteCheck($id) {
        $this->deleteRow($id, 'checks');
    }

    // Functions to manipulate income records
    public function getIncome($id) {
        return $this->getRow($id, 'income');
    }

    public function getIncomes($where = array()) {
        return $this->getRows($where, 'income', array('paid_date' => 'DESC', 'id' => 'DESC'));
    }

    public function setIncome($id, $data) {
        return $this->setRow($id, $data, 'income');
    }

    public function deleteIncome($id) {
        $this->deleteRow($id, 'income');
    }

    // Functions to manipulate tax records
    public function getTax($id) {
        return $this->getRow($id, 'tax');
    }

    public function getTaxes($where = array()) {
        return $this->getRows($where, 'tax', array('paid_date' => 'DESC', 'id' => 'DESC'));
    }

    public function setTax($id, $data) {
        return $this->setRow($id, $data, 'tax');
    }

    public function deleteTax($id) {
        $this->deleteRow($id, 'tax');
    }

    // Function to get the spending report data
    public function getSpendingReport($options) {
        $return = array();

        // Setup our wheres based on the options
        if(isset($options['start_date'])) {
            $this->db->where('receipt_date >=', $options['start_date']);
            unset($options['start_date']);
        }
        if(isset($options['end_date'])) {
            $this->db->where('receipt_date <=', $options['end_date']);
            unset($options['end_date']);
        }
        if(isset($options['filter'])) {
            foreach($options['filter'] as $key => $value) {
                $this->db->where($key, $value);
            }
        }

        // Setup our group by
        $this->db->group_by('month');
        if(isset($options['group_by']) && !empty($options['group_by'])) {
            $this->db->group_by($options['group_by']);
        }

        // Now build our joins and run the query
        $this->db->select("DATE_FORMAT(receipt_date, '%Y-%m') AS month, SUM(total) AS total, receipts_categories.name AS category, receipts_categories.deductible AS deductible, deductibles.name as deductible_name");
        $this->db->from('receipts');
        $this->db->join('receipts_categories', 'receipts.category_id = receipts_categories.id', 'left');
        $this->db->join('deductibles', 'receipts_categories.deductible = deductibles.id', 'left');
        $this->db->order_by('month', 'ASC');
        $this->db->order_by('category', 'ASC');
        $this->db->order_by('deductible_name', 'ASC');
        $query = $this->db->get();
        if(!empty($query->result_array())) {
            foreach($query->result_array() as $row) {
                if(empty($row['category'])) {
                    $row['category'] = 'None';
                }
                $return[$row['month']][$row['deductible_name']][$row['category']] = $row['total'];
            }
        }
        return $return;
    }

    // function to get the income report data
    public function getIncomeReport($options) {
        $return = array();
        $options_income = array();
        $options_time = array();

        // Setup our wheres based on the options
        if(isset($options['start_date'])) {
            $options_income['paid_date >='] = $options['start_date'];
            $options_time['entry_date >='] = $options['start_date'];
            unset($options['start_date']);
        }
        if(isset($options['end_date'])) {
            $options_income['paid_date <='] = $options['end_date'];
            $options_time['entry_date <='] = $options['end_date'];
            unset($options['end_date']);
        }
        if(isset($options['filter'])) {
            foreach($options['filter'] as $key => $value) {
                $options_income[$key] = $value;
                $options_time[$key] = $value;
            }
        }

        // Now build our joins and run the query for income data
        $this->getFilters($options_income);
        $this->db->select("DATE_FORMAT(paid_date, '%Y-%m') AS month, SUM(total) AS total, clients.name AS client, income.client_id AS client_id");
        $this->db->from('income');
        $this->db->join('clients', 'income.client_id = clients.id', 'left');
        $this->db->order_by('month', 'ASC');
        $this->db->order_by('client', 'ASC');
        $this->db->group_by('month, client_id');
        $query = $this->db->get();
        if(!empty($query->result_array())) {
            foreach($query->result_array() as $row) {
                if(empty($row['client'])) {
                    $row['client'] = 'None';
                }
                $return[$row['month']][$row['client']]['total_time'] = 0;
                $return[$row['month']][$row['client']]['total'] = $row['total'];
            }
        }

        // Now build our joins and run the query for time data
        $this->getFilters($options_time);
        $this->db->select("DATE_FORMAT(entry_date, '%Y-%m') AS month, SUM(total_time)/60 AS total_time, clients.name AS client, time_entries.client_id AS client_id");
        $this->db->from('time_entries');
        $this->db->join('clients', 'time_entries.client_id = clients.id', 'left');
        $this->db->order_by('month', 'ASC');
        $this->db->order_by('client', 'ASC');
        $this->db->group_by('month, client_id');
        $query = $this->db->get();
        if(!empty($query->result_array())) {
            foreach($query->result_array() as $row) {
                if(empty($row['client'])) {
                    $row['client'] = 'None';
                }
                if(isset($return[$row['month']][$row['client']])) {
                    $return[$row['month']][$row['client']]['total_time'] = $row['total_time'];
                } else {
                    $return[$row['month']][$row['client']]['total'] = 0;
                    $return[$row['month']][$row['client']]['total_time'] = $row['total_time'];
                }
            }
        }
        return $return;
    }

    // Function to get the utility report data
    public function getUtilityReport($options) {
        $return = array();

        // Setup our wheres based on the options
        if(isset($options['start_date'])) {
            $this->db->where('paid_date >=', $options['start_date']);
            unset($options['start_date']);
        }
        if(isset($options['end_date'])) {
            $this->db->where('paid_date <=', $options['end_date']);
            unset($options['end_date']);
        }
        if(isset($options['filter'])) {
            foreach($options['filter'] as $key => $value) {
                if($value > 0) {
                    $this->db->where($key, $value);
                }
            }
        }

        // Now build query and run it
        $this->db->select("DATE_FORMAT(paid_date, '%Y-%m') AS month, SUM(total) AS total, utilities_categories.name AS category");
        $this->db->from('utilities');
        $this->db->join('utilities_categories', 'utilities.category_id = utilities_categories.id', 'left');
        $this->db->group_by('month, category');
        $this->db->order_by('month', 'ASC');
        $this->db->order_by('category', 'ASC');
        $query = $this->db->get();
        if(!empty($query->result_array())) {
            foreach($query->result_array() as $row) {
                if(empty($row['category'])) {
                    $row['category'] = 'None';
                }
                $return[$row['month']][$row['category']] = $row['total'];
            }
        }
        return $return;
    }
}