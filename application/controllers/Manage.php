<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Manage extends MY_Controller {
    public function __construct() {
        parent::__construct();
        $this->load->model('financials_model');
        $this->setMenu('manage');
    }
    
    // START: Functions for displaying & processing client settings pages
    public function clients() {
        $data = array();
        $clients_by_id = array();
        $clients = $this->financials_model->getClients();
        foreach($clients as $row) {
            $clients_by_id[$row['id']] = $row;
        }
        $data['data'] = $clients_by_id;
        $data['replace_opts'] = json_encode($data['data']);

        $this->templateDisplay('manage/clients.tpl', $data);
    }

    public function editClient($id = 0) {
        $data = array();
        $data['client'] = $this->financials_model->getClient($id);
        if(!empty($data['client'])) {
            $data['heading'] = "Update {$data['client']['name']}";
        } else {
            $data['heading'] = "Add New Client";
        }
        $this->templateDisplay('manage/edit_client.tpl', $data);
    }

    public function setClient() {
        $id = 0;
        $data = (array)$this->input->post('client');
        if(!empty($data)) {
            $id = $data['id'];
            unset($data['id']);
            $id = $this->financials_model->setClient($id, $data);
        }
        $this->setMessage("Client Updated", 'success');
        redirect("/manage/editClient/$id");
    }

    public function deleteClient() {
        $delete_id = $this->input->post('delete_id');
        $transfer_id = $this->input->post('transfer_id');
        $this->financials_model->deleteClient($delete_id, $transfer_id);
        $this->setMessage("Client Deleted", 'success');
        redirect("/manage/clients");
    }
    // END: Functions for displaying & processing client settings pages

    // START: Functions for displaying & processing configuration settings
    public function config() {
        $data = array();
        $data['data'] = $this->config_model->getOptions();
        $this->templateDisplay('manage/config.tpl', $data);
    }

    public function editConfig($id = '') {
        $data = array();
        $data['option'] = $this->config_model->getOption($id, true);
        if(!empty($data['option'])) {
            $data['heading'] = "Update {$data['option']['name']}";
        } else {
            $data['heading'] = "Add New Option";
        }
        $this->templateDisplay('manage/edit_config.tpl', $data);
    }

    public function setConfig() {
        $data = (array)$this->input->post('option');
        $name = isset($data['name']) ? $data['name'] : '';
        
        // Check for a change to the option name.  If that is the case delete the old one first
        if(isset($data['start_name'])) {
            if($name != $data['start_name']) {
                $this->config_model->deleteOption($data['start_name']);
            }
            unset($data['start_name']);
        }

        // And then set the option value
        if(!empty($data)) {
            $this->config_model->setOption($data);
        }
        $this->setMessage("Config Option Updated", 'success');

        redirect("/manage/editConfig/$name");
    }

    public function deleteConfig() {
        $delete_id = $this->input->post('delete_id');
        $this->config_model->deleteOption($delete_id);
        $this->setMessage("Config Option Deleted", 'success');
        redirect("/manage/config");
    }
    // END: Functions for displaying & processing configuration settings
    
    // START: Functions for displaying & processing account data
    public function accounts() {
        $data = array();
        $accounts_by_id = array();
        $accounts = $this->financials_model->getChecksAccounts();
        foreach($accounts as $row) {
            $accounts_by_id[$row['id']] = $row;
        }
        $data['data'] = $accounts_by_id;
        $data['replace_opts'] = json_encode($accounts_by_id);

        $this->templateDisplay('manage/accounts.tpl', $data);
    }

    public function setAccounts() {      
        // First handle updates for existing entries
        $data = (array)$this->input->post('data');
        if(!empty($data)) {
            foreach($data as $id => $name) {
                if(!empty($name)) {
                    $this->financials_model->setChecksAccount($id, array('name' => $name));
                }
            }
        }

        // Next handle newly added entries
        $data = (array)$this->input->post('data_new');
        if(!empty($data)) {
            foreach($data as $name) {
                if(!empty($name)) {
                    $this->financials_model->setChecksAccount(0, array('name' => $name));
                }
            }
        }
        $this->setMessage("Account Updated", 'success');
        redirect("/manage/accounts");
    }

    public function deleteAccount() {
        $delete_id = $this->input->post('delete_id');
        $transfer_id = $this->input->post('transfer_id');
        $this->financials_model->deleteChecksAccount($delete_id, $transfer_id);
        $this->setMessage("Account Deleted", 'success');
        redirect("/manage/accounts");
    }
    // END: Functions for displaying & processing account data

    // START: Functions for displaying & processing receipt categories data
    public function categories() {
        $data = array();
        $categories = $this->financials_model->getReceiptCategories();
        $ded_groups = $this->financials_model->getDeductibles();
        $data['ded_options'] = $this->getOptions($ded_groups);
        foreach($categories as $row) {
            $data['data'][$row['id']] = $row;
        }
        foreach($ded_groups as $row) {
            $data['ded_groups'][$row['id']] = $row['name'];
        }
        $data['replace_opts'] = json_encode($data['data']);

        $this->templateDisplay('manage/categories.tpl', $data);
    }

    public function setCategories() {
        // First handle updates for existing entries
        $data = (array)$this->input->post('data');
        if(!empty($data)) {
            foreach($data as $id => $values) {
                if(!empty($values['name'])) {
                    $this->financials_model->setReceiptCategory($id, $values);
                }
            }
        }

        // Next handle newly added entries
        $data_names = (array)$this->input->post('data_names');
        $data_deductibles = (array)$this->input->post('data_deductibles');

        if(!empty($data_names) && !empty($data_deductibles)) {
            foreach($data_names as $key => $name) {
                if(!empty($name) && isset($data_deductibles[$key])) {
                    $this->financials_model->setReceiptCategory(0, array('name' => $name, 'deductible' => $data_deductibles[$key]));
                }
            }
        }
        
        $this->setMessage("Category Updated", 'success');
        redirect("/manage/categories");
    }

    public function deleteCategories() {
        $delete_id = $this->input->post('delete_id');
        $transfer_id = $this->input->post('transfer_id');
        $this->financials_model->deleteReceiptCategory($delete_id, $transfer_id);
        $this->setMessage("Category Deleted", 'success');
        redirect("/manage/categories");
    }
    // END: Functions for displaying & processing receipt categories data

    // START: Functions for displaying & processing utility categories data
    public function utilityCategories() {
        $data = array();
        $json_data = array();

        $accounts = $this->financials_model->getChecksAccounts();
        $data['acctount_options'] = $this->getOptions($accounts);

        $categories = $this->financials_model->getUtilityCategories();
        foreach($categories as $row) {
            $data['data'][$row['id']] = $row;
            $json_data[$row['id']] = $row;
            $data['data'][$row['id']]['account_options'] = $this->getOptions($accounts, $row['checks_accounts_id']);
        }

        $data['replace_opts'] = json_encode($json_data);

        $this->templateDisplay('manage/utility_categories.tpl', $data);
    }

    public function setUtilityCategories() {
        // First handle updates for existing entries
        $data = $this->input->post('data');
        if(!empty($data)) {
            foreach($data as $id => $row) {
                $this->financials_model->setUtilityCategory($id, $row);
            }
        }

        // Next handle newly added entries
        $names = $this->input->post('data_new_name');
        $vendors = $this->input->post('data_new_vendor');
        $accounts = $this->input->post('data_new_account');
        foreach($names as $key => $name) {
            if(!empty($name)) {
                $data = array('name' => $name, 'vendor' => $vendors[$key], 'checks_accounts_id' => $accounts[$key]);
                $this->financials_model->setUtilityCategory(0, $data);
            }
        }
        $this->setMessage("Category Updated", 'success');
        redirect("/manage/utilityCategories");
    }

    public function deleteUtilityCategory() {
        $delete_id = $this->input->post('delete_id');
        $transfer_id = $this->input->post('transfer_id');
        $this->financials_model->deleteUtilityCategory($delete_id, $transfer_id);
        $this->setMessage("Category Deleted", 'success');
        redirect("/manage/utilityCategories");
    }
    // END: Functions for displaying & processing utility categories data

    // START: Functions for displaying & processing tax categories data
    public function taxCategories() {
        $data = array();
        $categories = $this->financials_model->getTaxCategories();
        foreach($categories as $row) {
            $data['data'][$row['id']] = $row;
        }
        $data['replace_opts'] = json_encode($data['data']);
        $this->templateDisplay('manage/tax_categories.tpl', $data);
    }

    public function setTaxCategories() {
        // First handle updates for existing entries
        $data = (array)$this->input->post('data');
        if(!empty($data)) {
            foreach($data as $id => $name) {
                if(!empty($name)) {
                    $this->financials_model->setTaxCategory($id, array('name' => $name));
                }
            }
        }

        // Next handle newly added entries
        $data = (array)$this->input->post('data_new');
        if(!empty($data)) {
            foreach($data as $name) {
                if(!empty($name)) {
                    $this->financials_model->setTaxCategory(0, array('name' => $name));
                }
            }
        }

        $this->setMessage("Category Updated", 'success');
        redirect("/manage/taxCategories");
    }

    public function deleteTaxCategory() {
        $delete_id = $this->input->post('delete_id');
        $transfer_id = $this->input->post('transfer_id');
        $this->financials_model->deleteTaxCategory($delete_id, $transfer_id);
        $this->setMessage("Category Deleted", 'success');
        redirect("/manage/taxCategories");
    }
    // END: Functions for displaying & processing tax categories data

    // START: Functions for displaying & processing deductible categories data
    public function dedCategories() {
        $data['data'] = array();
        $categories = $this->financials_model->getDeductibles();
        foreach($categories as $row) {
            $data['data'][$row['id']] = $row;
        }
        $data['replace_opts'] = json_encode($data['data']);
        $this->templateDisplay('manage/deduct_categories.tpl', $data);
    }

    public function setDedCategories() {      
        // First handle updates for existing entries
        $data = (array)$this->input->post('data');
        if(!empty($data)) {
            foreach($data as $id => $name) {
                if(!empty($name)) {
                    $this->financials_model->setDeductible($id, array('name' => $name));
                }
            }
        }

        // Next handle newly added entries
        $data = (array)$this->input->post('data_new');
        if(!empty($data)) {
            foreach($data as $name) {
                if(!empty($name)) {
                    $this->financials_model->setDeductible(0, array('name' => $name));
                }
            }
        }
        $this->setMessage("Categories Updated", 'success');
        redirect("/manage/dedCategories");
    }

    public function deleteDedCategory() {
        $delete_id = $this->input->post('delete_id');
        $transfer_id = $this->input->post('transfer_id');
        $this->financials_model->deleteDeductible($delete_id, $transfer_id);
        $this->setMessage("Category Deleted", 'success');
        redirect("/manage/dedCategories");
    }
    // END: Functions for displaying & processing deductible categories data
}