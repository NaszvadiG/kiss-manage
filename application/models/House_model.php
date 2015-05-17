<?php
/*
 * Model that corresponds to the house controller.
 */
class House_model extends MY_Model {
    public function __construct() {
        $this->load->database();
    }

    // Functions to manipulate store records
    public function getStore($id) {
        return $this->getRow($id, 'shopping_store');
    }

    public function getStores() {
        return $this->getRows(array(), 'shopping_store', array('name' => 'ASC'));
    }

    public function setStore($id, $data) {
        return $this->setRow($id, $data, 'shopping_store');
    }

    // Functions to manipulate shopping list records
    public function setShoppingList($id, $data) {
        return $this->setRow($id, $data, 'shopping_list');
    }

    public function getShoppingList($where = array()) {
        return $this->getRows($where, 'shopping_list');
    }
}