<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class House extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('house_model');
        $this->setMenu('house');
    }

    // Function to view the main shopping list page
    public function shopping($store_id = 0, $item_id = 0) {
        $data = array();
        $selected_store = 0;
        
        // Handle user filtering by a specific store
        if($this->input->post('store_id')) {
            $store_id = $this->input->post('store_id');
        }
        $data['store_id'] = $store_id;

        // Handle the filter for looking up the list
        $store_where = array('status' => 0);
        if($store_id > 0) {
            $store_where['store_id'] = $store_id;
        }

        // Get our data based on what we have passed in
        $stores = $this->house_model->getStores();
        $list = $this->house_model->getShoppingList($store_where);
        $store_lookup = $this->getLookups($stores);

        foreach($list as $item) {
            if(isset($store_lookup[$item['store_id']])) {
                $item['store_name'] = $store_lookup[$item['store_id']];
            } else {
                $item['store_name'] = '';
            }
            $data['list'][$item['id']] = $item;

            // Pull out our selected item if set and matching the current loop
            if($item['id'] == $item_id) {
                $data['selected'] = $item;
                $selected_store = $item['store_id'];
            }
        }

        // Get our dropdown lists
        $data['store_options'] = $this->getOptions($stores, $selected_store);
        $data['store_filter'] = $this->getOptions($stores, $store_id);

        $this->templateDisplay('house/shopping.tpl', $data);
    }

    // Function to add/update a shopping list entry and send the user back to the main shopping list page.  Note this also takes care 
    // of adding a store if that was included
    public function editShoppingItem() {
        $item_id = (int)$this->input->post('item_id');
        $store_id = (int)$this->input->post('store_id');
        $name = (string)$this->input->post('name');
        $store_name = (string)$this->input->post('store_name');

        if($store_id < 0) {
            // We need to add a new store first
            $store_id = $this->house_model->setStore(0, array('name' => $store_name));
        }
        
        // Now set our show
        $item_id = $this->house_model->setShoppingList($item_id, array('name' => $name, 'store_id' => $store_id, 'created_date' => date('Y-m-d')));

        redirect("/house/shopping");
    }

    // Function to set an item on the shopping list as purchased
    public function setShoppingItemPurchased($store_id, $item_id) {
        $item_id = (int)$item_id;
        if($item_id > 0) {
            $this->house_model->setShoppingList($item_id, array('status' => 1));
        }
        redirect("/house/shopping/$store_id");
    }
}