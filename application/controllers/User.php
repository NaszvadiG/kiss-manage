<?php
defined('BASEPATH') OR exit('No direct script access allowed');

/*
 * Controller for managing user records.  Note this leverages the Ion Auth user module and that alot of this code was pulled from their examples.
 */
class User extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->library('form_validation');
		$this->load->helper('language');
		$this->form_validation->set_error_delimiters($this->config->item('error_start_delimiter', 'ion_auth'), $this->config->item('error_end_delimiter', 'ion_auth'));
        $this->lang->load('auth');
    }

    // Function to display the manage users page
    public function manageUsers() {
        $data = array();
        $users = $this->ion_auth->users()->result();
        foreach($users as $user) {
            $data['data'][$user->id] = $user->email;
        }
        $this->templateDisplay('user/manage.tpl', $data);
    }

    // Function to display a user profile page
	public function profile($id = 0) {
        $id = (int)$id;
        $data = array();
        
        if($id > 0) {
            $data = (array)$this->ion_auth->user($id)->row();
        }
        if(empty($data)) {
            $data = (array)$this->user;
        }
        $data['message'] = $this->session->flashdata('message');
        $this->templateDisplay('user/profile.tpl', $data);
	}

    // Function to display the add user page
    public function add() {
        $data = array('id' => 0, 'first_name' => '', 'last_name' => '', 'email' => '');
        $data['message'] = $this->session->flashdata('message');
        $data['add'] = 1;
        $this->templateDisplay('user/profile.tpl', $data);
	}

    // Function to delete a user
    public function delete() {
        $id = (int)$this->input->post('delete_id');
        $this->ion_auth_model->delete_user($id);
        redirect("/user/manageUsers");
    }

    // Function to update a users profile, including password if set
    public function setProfile() {
        $data = array();
        $logout = false;

        $id = (int)$this->input->post('id');
        $add = $this->input->post('add');
        if(!$add && $id <= 0) {
            $id = $this->user->id;
        }

        $this->form_validation->set_rules('email', $this->lang->line('edit_user_email_label'), 'required');
        $this->form_validation->set_rules('first_name', $this->lang->line('edit_user_validation_fname_label'), 'required');
		$this->form_validation->set_rules('last_name', $this->lang->line('edit_user_validation_lname_label'), 'required');

        // Force/Validate a password when creating users or if one is set
        if($id <= 0 || $this->input->post('password')) {
            $this->form_validation->set_rules('password', $this->lang->line('edit_user_validation_password_label'), 'required|min_length[' .            $this->config->item('min_password_length', 'ion_auth') . ']|max_length[' . $this->config->item('max_password_length', 'ion_auth') . ']|matches[password_confirm]');
		    $this->form_validation->set_rules('password_confirm', $this->lang->line('edit_user_validation_password_confirm_label'), 'required');
        }

        if($this->form_validation->run() === true) {
            $data['email'] = $this->input->post('email');
            $data['first_name'] = $this->input->post('first_name');
            $data['last_name'] = $this->input->post('last_name');

            if($this->input->post('password')) {
                // Set the password in the update array since its there
                $data['password'] = $this->input->post('password');
            }

            if($id > 0) {
                // Update an existing user

                if($this->ion_auth->update($id, $data)) {
                    $this->session->set_flashdata('message', $this->ion_auth->messages());
                    if(isset($data['password'])) {
                        $logout = true;
                    }
                } else {
                    $this->session->set_flashdata('message', $this->ion_auth->errors());
                }
            } else {
                // Create a new user
                $additional_data = array('first_name' => $this->input->post('first_name'), 'last_name' => $this->input->post('last_name'));
                if($this->ion_auth->register($data['email'], $data['password'], $data['email'], $additional_data)) {
                    $this->session->set_flashdata('message', $this->ion_auth->messages());
                } else {
                    $this->session->set_flashdata('message', $this->ion_auth->errors());
                }
            }

        } else {
            $this->session->set_flashdata('message', (validation_errors()) ? validation_errors() : $this->session->flashdata('message'));
        }

        if($logout) {
            redirect('/logout');
        } else {
            redirect("/user/profile/$id");
        }
    }
}