<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Projects extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('projects_model');
        $this->load->model('financials_model');
        $this->setMenu('business');
    }

    public function getTaskData($id) {
        $task = $this->projects_model->getTask($id);
        $task['status_options'] = $this->getOptions($this->projects_model->getTaskStatus(), $task['status']);
        $this->output->set_content_type('application/json');
        $this->output->set_output(json_encode($task));
    }

    public function view($id = 0) {
        // Lookup our clients, projects, statuses, etc
        $data = array();
        $clients = $this->financials_model->getClients();
        $clients_lookup = $this->getLookups($clients);
        $projects = $this->projects_model->getProjects();
        $project_statuses = $this->projects_model->getProjectStatus();
        $task_statuses = $this->projects_model->getTaskStatus();

        // Build out our default task status options
        $data['task_status_options'] = '';
        $task_status_options = $this->getOptions($task_statuses);
        foreach($task_status_options as $option) {
            $data['task_status_options'] .= $option;
        }

        foreach($projects as $row) {
            // Get the status name and set the options for the project
            $row['status_name'] = $this->projects_model->getProjectStatus($row['status']);
            $row['status_options'] = $this->getOptions($project_statuses, $row['status']);

            // And handle a selected project if we got one
            if($row['id'] == $id ) {
                $row['selected'] = $id;
            }

            // Set the client name and options for the project
            if(isset($clients_lookup[$row['client_id']])) {
                $row['client_name'] = $clients_lookup[$row['client_id']];
            } else {
                $row['client_name'] = 'None';
            }
            $row['client_options'] = $this->getOptions($clients, $row['client_id']);
            
            // Get the tasks for the project
            $tasks = $this->projects_model->getTasks(array('project_id' => $row['id']));
            foreach($tasks as $task) {
                $task['status_name'] = $this->projects_model->getTaskStatus($task['status']);
                $row['tasks'][$task['id']] = $task;
            }

            $data['projects'][$row['id']] = $row;
        }

        // Now add an empty project so that its included on the page to add a new one
        $empty = array( 'id' => 0,
                        'name' => 'Add New Project',
                        'status' => 0,
                        'client_id' => 0,
                        'status_options' => $this->getOptions($project_statuses),
                        'client_options' => $this->getOptions($clients));
        $data['projects']['empty'] = $empty;
        
        $this->templateDisplay('projects/view.tpl', $data);
    }

    public function setProject() {
        $project_id = $this->input->post('project_id');
        $project = $this->input->post('project');
        $project_id = $this->projects_model->setProject($project_id, $project);
        redirect("/projects/view/$project_id");
    }

    public function setTask() {
        $redirect = $this->input->post('task_redirect');
        $task_id = $this->input->post('task_id');
        $task = $this->input->post('task');
        $this->projects_model->setTask($task_id, $task);
        redirect($redirect);
    }

    public function deleteProject() {
        $project_id = $this->input->post('project_id');
        $this->projects_model->deleteProject($project_id);
        redirect("/projects/view");
    }

    public function deleteTask() {
        $project_id = $this->input->post('project_id');
        $task_id = $this->input->post('task_id');
        $this->projects_model->deleteTask($task_id);
        redirect("/projects/view/$project_id");
    }
}