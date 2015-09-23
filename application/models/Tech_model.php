<?php
/*
 * Model that corresponds to the tech controller.
 */
class Tech_model extends MY_Model {
    public function __construct() {
        $this->load->database();
    }

    // Functions to manipulate Notes records
    public function getNote($id) {
        return $this->getRow($id, 'notes');
    }
    public function getNotes($where = array()) {
        return $this->getRows($where, 'notes', array('name' => 'ASC'));
    }
    public function setNote($id, $data) {
        return $this->setRow($id, $data, 'notes');
    }
    public function deleteNote($id) {
        // Recursively delete all children as needed and finally the requested note
        $children = $this->getRows(array('parent_id' => $id), 'notes');
        foreach($children as $child) {
            $this->deleteNote($child['id']);
        }
        $this->deleteRow($id, 'notes');
    }
}