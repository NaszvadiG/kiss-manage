<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Tech extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('tech_model');
        $this->load->library('Tree');
        $this->setMenu('business');
    }

    // Function to display the technical notes page
    public function notes($id = 0) {
        $id = (int)$id;
        $data = array();
        if($id <= 0) {
            $id = $this->input->cookie("notes_tree_selected");
        } else {
            $this->input->set_cookie('notes_tree_selected', $id, 31536000);
        }
        $tree_data = $this->tech_model->getNotes();
        $tree_data = $this->tree->getTree($tree_data, $id);
        $data['hierarchy_options'] = $this->getOptions($this->tree->getHierarchy());
        $data['tree_data'] = json_encode($tree_data);
        $data['selected_node'] = $this->tree->getSelectedNodeCounter();

        $this->templateDisplay('tech/notes.tpl', $data);        
    }

    // Function called to add/update a note entry
    public function setNote() {
        $id = (int)$this->input->post('note_id');
        $data = $this->input->post('note');
        $id =  $this->tech_model->setNote($id, $data);
        redirect("/tech/notes/$id");
    }

    // Function to delete a time entry and send the user back to the main Time Tracking page
    public function deleteNote() {
        $id = $this->input->post('note_id');
        if($id > 0) {
            $note = $this->tech_model->getNote($id);
            $this->tech_model->deleteNote($id);
        }
        redirect("/tech/notes/{$note['parent_id']}");
    }
}
