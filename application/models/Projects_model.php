<?php
/*
 * Model that corresponds to the projects controller.
 */
class Projects_model extends MY_Model {
    private $project_status = array(0 => array("id" => 0, "name" => "Pending"), 
                                    1 => array("id" => 1, "name" => "Complete"), 
                                    2 => array("id" => 2, "name" => "In Progress"), 
                                    3 => array("id" => 3, "name" => "On Hold"));

    private $task_status = array(   0 => array("id" => 0, "name" => "Pending"), 
                                    1 => array("id" => 1, "name" => "Complete"), 
                                    2 => array("id" => 2, "name" => "In Progress"), 
                                    3 => array("id" => 3, "name" => "On Hold"));

    public function __construct() {
        $this->load->database();
    }

    // Functions to get status info
    public function getProjectStatus($status = false) {
        if($status === false) {
            return $this->project_status;
        } else {
            return (isset($this->project_status[$status]) ? $this->project_status[$status]["name"] : '');
        }
    }
    public function getTaskStatus($status = false) {
        if($status === false) {
            return $this->task_status;
        } else {
            return (isset($this->task_status[$status]) ? $this->task_status[$status]["name"] : '');
        }
    }

    // Functions to manipulate project records
    public function getProject($id) {
        return $this->getRow($id, 'projects');
    }
    public function getProjects($where = array()) {
        return $this->getRows($where, 'projects', array('due_date' => 'ASC', 'created_date', 'ASC'));
    }
    public function setProject($id, $data) {
        return $this->setRow($id, $data, 'projects');
    }
    public function deleteProject($id) {
        $tasks = $this->getTasks(array('project_id' => $id));
        foreach($tasks as $task) {
            $this->deleteTask($task['id']);
        }
        $this->deleteRow($id, 'projects');
    }

    // Functions to manipulate task records
    public function getTask($id) {
        return $this->getRow($id, 'tasks');
    }
    public function getTasks($where = array()) {
        return $this->getRows($where, 'tasks', array('due_date' => 'ASC', 'created_date', 'ASC'));
    }
    public function setTask($id, $data) {
        return $this->setRow($id, $data, 'tasks');
    }
    public function deleteTask($id) {
        $this->deleteRow($id, 'tasks');
    }
}