<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Projects extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('projects_model');
        $this->load->model('financials_model');
        $this->setMenu('business');
    }

    public function getTaskData($id, $project_id) {
        $task = $this->projects_model->getTask($id);
        if(!empty($task)) {
            $task['status_options'] = $this->getOptions($this->projects_model->getTaskStatus(), $task['status']);
        } else {
            // We are really adding a task so provide the sane defaults
            $task = array();
            $task['id'] = 0;
            $task['project_id'] = $project_id;
            $task['name'] = '';
            $task['created_date'] = date('Y-m-d');
            $task['due_date'] = date('Y-m-d', strtotime('+1 month'));
            $task['status_options'] = $this->getOptions($this->projects_model->getTaskStatus());
            $task['detail'] = '';
        }
        $this->output->set_content_type('application/json');
        $this->output->set_output(json_encode($task));
    }

    public function view($id = 0) {
        // Misc Init
        $data = array();
        $clients = $this->financials_model->getClients();
        $clients_lookup = $this->getLookups($clients);
        $project_statuses = $this->projects_model->getProjectStatus();
        $task_statuses = $this->projects_model->getTaskStatus();

        // Handle our filters
        $current_filters = array();
        $session_filters = $this->input->cookie('projects_filter');
        $current_filters['due_date >='] = date('Y-m-01', strtotime('-1 month'));
        $filtered_status = -1;
        $filtered_client = 0;

        if($this->input->post('filter')) {
            $post_filters = $this->input->post('filter');
            if($post_filters['clear'] != "1") {
                $current_filters['due_date >='] = $post_filters['due_date'];
                if($post_filters['status'] >= 0) {
                    $filtered_status = $post_filters['status'];
                    $current_filters['status'] = $filtered_status;
                } elseif($post_filters['status'] == -2) {
                    $filtered_status = $post_filters['status'];
                    $current_filters['status !='] = 1;
                }
                if($post_filters['client_id'] > 0) {
                    $filtered_client = $post_filters['client_id'];
                    $current_filters['client_id'] = $filtered_client;
                }
            }
            $this->input->set_cookie('projects_filter', serialize($current_filters), 31536000);
        } elseif (!empty($session_filters)) {
            $current_filters = unserialize($session_filters);
        }

        $data['filter_status_options'] = $this->getOptions($project_statuses, $filtered_status);
        $data['filter_client_options'] = $this->getOptions($clients, $filtered_client);
        $data['filter_status_value'] = $filtered_status;
        $data['filter'] = $current_filters;
        if(isset($data['filter']['due_date >='])) {
            $data['filter']['due_date'] = $data['filter']['due_date >='];
        }

        // Get our projects and process accordingly
        $projects = $this->projects_model->getProjects($current_filters);
        foreach($projects as $row) {
            // Set the header name separately
            $row['header_name'] = $row['name'];

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
                        'header_name' => 'Add New Project',
                        'name' => '',
                        'status' => 0,
                        'client_id' => 0,
                        'created_date' => date('Y-m-d'),
                        'due_date' => date('Y-m-d', strtotime('+1 month')),
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