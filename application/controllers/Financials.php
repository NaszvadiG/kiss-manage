<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Financials extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('financials_model');
        $this->setMenu('financials');
    }

    // Function to display the main receipts page
    public function receipts($id = 0) {
        $data = array();
        $selected_category = 0;

        // Handle user filtering by a start_date
        $session_start_date = $this->session->userdata('receipts_start_date_filter');
        $start_date = date('Y-m-01', strtotime('-1 month'));
        if($this->input->post('start_date')) {
            $start_date = $this->input->post('start_date');
            $this->session->set_userdata('receipts_start_date_filter', $start_date);
        } elseif (!empty($session_start_date)) {
            $start_date = $session_start_date;
        }
        $data['start_date'] = $start_date;

        // Get our data based on what we have passed in
        $receipts = $this->financials_model->getReceipts(array('receipt_date >=' => $start_date));
        $categories = $this->financials_model->getReceiptCategories();
        $category_lookup = $this->getLookups($categories);

        foreach($receipts as $row) {
            if(isset($category_lookup[$row['category_id']])) {
                $row['category'] = $category_lookup[$row['category_id']];
            } else {
                $row['category'] = '';
            }
            $data['receipts'][$row['id']] = $row;

            // Pull out our selected item if set and matching the current loop
            if($row['id'] == $id) {
                $data['selected'] = $row;
                $selected_category = $row['category_id'];
            }
        }

        // Get our category dropdown
        $data['category_options'] = $this->getOptions($categories, $selected_category);
        
        $this->templateDisplay('financials/receipts.tpl', $data);
    }

    // Function to add/update a receipt entry and send the user back to the main receipts page
    public function setReceipt() {
        $data = (array)$this->input->post('receipt');
        if(!empty($data)) {
            $id = (int)$this->input->post('id');
            $receipt_id = $this->financials_model->setReceipt($id, $data);
        }
        redirect("/financials/receipts");
    }

    // Function to delete a receipt entry and send the user back to the main receipts page
    public function deleteReceipt() {
        $this->financials_model->deleteReceipt($this->input->post('receipt_id'));
        redirect("/financials/receipts");
    }

    // Function to return a receipts template CSV for use for importing receipt data
    public function getReceiptsTemplate() {
        $csv_header = array('receipt_date', 'receipt_number', 'vendor', 'description', 'total', 'category');
        $output = fopen('php://output', 'w');
        ob_start();
        fputcsv($output, $csv_header);
        $output = ob_get_clean();
        $filename = "receipt_import_template.csv";
        header('Pragma: public');
        header('Expires: 0');
        header('Cache-Control: must-revalidate, post-check=0, pre-check=0');
        header('Cache-Control: private', false);
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . $filename . '";');
        header('Content-Transfer-Encoding: binary');
        exit($output);
    }

    // Function to import a CSV of receipt data.  The source file MUST match the expected template format.
    public function importReceipts() {
        if (isset($_FILES['import_file']['tmp_name']) && is_uploaded_file($_FILES['import_file']['tmp_name'])) {
            $count = 0;
            $handle = fopen($_FILES['import_file']['tmp_name'], 'r');
            while(($data = fgetcsv($handle)) !== false) {
                if(count($data) == 8 && $count > 0) {
                    $receipt = array();

                    // Set the columns that don't require extra lookup or such
                    $receipt['receipt_number'] = $data[1];
                    $receipt['vendor'] = $data[2];
                    $receipt['description'] = $data[3];
                    $receipt['total'] = $data[4];

                    // If no date included in first column set it as today
                    if(!empty($data[0])) {
                        $receipt['receipt_date'] = date('Y-m-d', strtotime($data[0]));
                    } else {
                        $receipt['receipt_date'] = date('Y-m-d');
                    }
                    
                    // If a category name is passed attempt to lookup the id
                    $lookup_id = 0;
                    if(!empty($data[5])) {
                        $check = $this->financials_model->getReceiptCategories(array('name' =>$data[5]));
                        if(!empty($check)) {
                            $lookup_id = $check['id'];
                        }
                    }
                    $receipt['category_id'] = $lookup_id;

                    $this->financials_model->setReceipt(0, $receipt);
                }
                $count++;
            }
            fclose($handle);
        }
        redirect("/financials/receipts");
    }

    // Function to display the main utilities listing page
    public function utilities($id = 0) {
        $data = array();
        $selected_category = 0;

        // Handle user filtering by a start_date
        $session_start_date = $this->session->userdata('utilities_start_date_filter');
        $start_date = date('Y-m-01', strtotime('-1 month'));
        if($this->input->post('start_date')) {
            $start_date = $this->input->post('start_date');
            $this->session->set_userdata('utilities_start_date_filter', $start_date);
        } elseif (!empty($session_start_date)) {
            $start_date = $session_start_date;
        }
        $data['start_date'] = $start_date;

        // Get our data based on what we have passed in
        $utilities = $this->financials_model->getUtilities(array('paid_date >=' => $start_date));
        $categories = $this->financials_model->getUtilityCategories();
        $category_lookup = $this->getLookups($categories);

        foreach($utilities as $row) {
            if(isset($category_lookup[$row['category_id']])) {
                $row['category'] = $category_lookup[$row['category_id']];
            } else {
                $row['category'] = '';
            }            
            $data['utilities'][$row['id']] = $row;

            // Pull out our selected item if set and matching the current loop
            if($row['id'] == $id) {
                $data['selected'] = $row;
                $selected_category = $row['category_id'];
            }
        }
        
        // Get our category dropdown
        $data['category_options'] = $this->getOptions($categories, $selected_category);
        
        $this->templateDisplay('financials/utilities.tpl', $data);
    }

    // Function to add/update a utility entry and send the user back to the main utilities page
    public function setUtility() {
        $data = (array)$this->input->post('utility');
        if(!empty($data)) {
            $id = (int)$this->input->post('id');
            $this->financials_model->setUtility($id, $data);

            // Handle adding an entry for a new check if applicable
            if($id == 0 && isset($data['check_num']) && !empty($data['check_num'])) {
                if($data['category_id'] > 0) {
                    $category = $this->financials_model->getUtilityCategory($data['category_id']);
                    $paid_to = $category['vendor'];
                    $account_id = $category['checks_accounts_id'];
                } else {
                    $paid_to = "Unspecified Utility";
                    $account_id = 0;
                }
                $this->financials_model->setCheck(0, array('check_num' => $data['check_num'], 'check_date' => $data['paid_date'], 'paid_to' => $paid_to, 'account_id' => $account_id, 'total' => $data['total'], 'posted' => 0));
            }
        }
        redirect("/financials/utilities");
    }

    // Function to delete a utility entry and send the user back to the main utilities page
    public function deleteUtility() {
        $this->financials_model->deleteUtility($this->input->post('utility_id'));
        redirect("/financials/utilities");
    }

    // Function to display the main checking list page
    public function checking($id = 0) {
        $data = array();
        
        // Handle user filtering by a start_date/account
        $session_start_date = $this->session->userdata('checking_start_date_filter');
        $session_filter_account = $this->session->userdata('checking_filter_account');
        $start_date = date('Y-m-01', strtotime('-1 month'));
        $filter_account = 0;

        if($this->input->post('start_date')) {
            $start_date = $this->input->post('start_date');
            $this->session->set_userdata('checking_start_date_filter', $start_date);
        } elseif (!empty($session_start_date)) {
            $start_date = $session_start_date;
        }
        if($this->input->post('filter_account') !== null) {
            $filter_account = $this->input->post('filter_account');
            $this->session->set_userdata('checking_filter_account', $filter_account);
        } elseif (!empty($session_filter_account)) {
            $filter_account = $session_filter_account;
        }
        $data['start_date'] = $start_date;
        $data['filter_account'] = $filter_account;

        // Get our data based on what we have passed in
        $checks_where = array('check_date >=' => $start_date);
        if($filter_account > 0) {
            $checks_where['account_id'] = $filter_account;
        }
        $checks = $this->financials_model->getChecks($checks_where);
        $accounts = $this->financials_model->getChecksAccounts();
        $account_lookup = $this->getLookups($accounts);
        $data['account_dropdown'] = $this->getOptions($accounts, $id);
        $data['account_filter'] = $this->getOptions($accounts, $filter_account);

        // Loop thru all the checks
        foreach($checks as $row) {
            if(isset($account_lookup[$row['account_id']])) {
                $row['account'] = $account_lookup[$row['account_id']];
            } else {
                $row['account'] = '';
            }            
            $data['checks'][$row['id']] = $row;

            // Pull out our selected item if set and matching the current loop
            if($row['id'] == $id) {
                $data['selected_check'] = $row;
            }
        }
        
        $this->templateDisplay('financials/checking.tpl', $data);
    }

    // Function to add/update a check entry and send the user back to the main checking page
    public function setCheck() {
        $data = (array)$this->input->post('check');
        if(!empty($data)) {
            $id = (int)$this->input->post('id');
            if(!isset($data['posted'])) {
                   $data['posted'] = 0;
            }
            $this->financials_model->setCheck($id, $data);
        }
        redirect("/financials/checking");
    }

    // Function to delete a check entry and send the user back to the main checking page
    public function deleteCheck() {
        $this->financials_model->deleteCheck($this->input->post('check_id'));
        redirect("/financials/checking");
    }

    // Function to set a check entry to posted and send the user back to the main checking page
    public function postCheck() {
        $check_id = (int)$this->input->post('check_id');
        if($check_id > 0) {
            $this->financials_model->setCheck($check_id, array('posted' => 1));
        }
        redirect("/financials/checking");
    }

    // Function to display the main income list page
    public function income($id = 0) {
        $data = array();
        $selected_account = 0;
        $selected_client = 0;
        
        // Handle user filtering by a start_date/client
        $session_start_date = $this->session->userdata('income_start_date_filter');
        $session_filter_client = $this->session->userdata('income_filter_client');
        $start_date = date('Y-m-01', strtotime('-1 month'));
        $filter_client = 0;

        if($this->input->post('start_date')) {
            $start_date = $this->input->post('start_date');
            $this->session->set_userdata('income_start_date_filter', $start_date);
        } elseif (!empty($session_start_date)) {
            $start_date = $session_start_date;
        }
        if($this->input->post('filter_client') !== null) {
            $filter_client = $this->input->post('filter_client');
            $this->session->set_userdata('income_filter_client', $filter_client);
        } elseif (!empty($session_filter_client)) {
            $filter_client = $session_filter_client;
        }
        $data['start_date'] = $start_date;
        $data['filter_client'] = $filter_client;

        // Get our data based on what we have passed in
        $filter = array('paid_date >=' => $start_date);
        if($filter_client > 0) {
            $filter['client_id'] = $filter_client;
        }
        $incomes = $this->financials_model->getIncomes($filter);
        $clients = $this->financials_model->getClients(array('status' => 1));
        $accounts = $this->financials_model->getChecksAccounts();
        $client_lookup = $this->getLookups($clients);
        $account_lookup = $this->getLookups($accounts);
        
        foreach($incomes as $row) {
            if(isset($client_lookup[$row['client_id']])) {
                $row['client'] = $client_lookup[$row['client_id']];
            } else {
                $row['client'] = '';
            }
            if(isset($account_lookup[$row['account_id']])) {
                $row['account'] = $account_lookup[$row['account_id']];
            } else {
                $row['account'] = '';
            }           
            $data['incomes'][$row['id']] = $row;

            // Pull out our selected item if set and matching the current loop
            if($row['id'] == $id) {
                $data['selected'] = $row;
                $selected_account = $row['account_id'];
                $selected_client = $row['client_id'];
            }
        }

        // Get our dropdowns
        $data['account_options'] = $this->getOptions($accounts, $selected_account);
        $data['client_options'] = $this->getOptions($clients, $selected_client);
        $data['client_filters'] = $this->getOptions($clients, $filter_client);

        $this->templateDisplay('financials/income.tpl', $data);
    }

    // Function to add/update an income entry and send the user back to the main income page
    public function setIncome() {
        $data = (array)$this->input->post('income');
        if(!empty($data)) {
            $id = (int)$this->input->post('id');
            $this->financials_model->setIncome($id, $data);
        }
        redirect("/financials/income");
    }

    // Function to delete an income entry and send the user back to the main income page
    public function deleteIncome() {
        $this->financials_model->deleteIncome($this->input->post('income_id'));
        redirect("/financials/income");
    }

    // Function to display the main taxes page
    public function taxes($id = 0) {
        $data = array();
        $selected_category = 0;
        
        // Handle user filtering by a start_date/account
        $session_start_date = $this->session->userdata('taxes_start_date_filter');
        $start_date = date('Y-m-01', strtotime('-1 month'));
        if($this->input->post('start_date')) {
            $start_date = $this->input->post('start_date');
            $this->session->set_userdata('taxes_start_date_filter', $start_date);
        } elseif (!empty($session_start_date)) {
            $start_date = $session_start_date;
        }
        $data['start_date'] = $start_date;

        // Get our data based on what we have passed in
        $taxes = $this->financials_model->getTaxes(array('paid_date >=' => $start_date));
        $categories = $this->financials_model->getTaxCategories();
        $category_lookup = $this->getLookups($categories);

        foreach($taxes as $row) {
            if(isset($category_lookup[$row['category_id']])) {
                $row['category'] = $category_lookup[$row['category_id']];
            } else {
                $row['category'] = '';
            }            
            $data['taxes'][$row['id']] = $row;

            // Pull out our selected item if set and matching the current loop
            if($row['id'] == $id) {
                $data['selected'] = $row;
                $selected_category = $row['category_id'];
            }
        }
        
        // Get our category dropdown
        $data['category_options'] = $this->getOptions($categories, $selected_category);
        
        $this->templateDisplay('financials/taxes.tpl', $data);
    }

    // Function to add/update a tax entry and send the user back to the main taxes page
    public function setTax() {
        $data = (array)$this->input->post('tax');
        if(!empty($data)) {
            $id = (int)$this->input->post('id');
            $this->financials_model->setTax($id, $data);
        }
        redirect("/financials/taxes");
    }

    // Function to delete a tax entry and send the user back to the main taxes page
    public function deleteTax() {
        $this->financials_model->deleteTax($this->input->post('tax_id'));
        redirect("/financials/taxes");
    }
}