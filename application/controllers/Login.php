<?php
defined('BASEPATH') OR exit('No direct script access allowed');
// Login controller.  Note that we don't extend MY_Controller here cause we aren't authenticated yet (nor do we want the standard menu, etc)
class Login extends CI_Controller {

    public function __construct() {
        parent::__construct();
    }

    // Display the login page
	public function index() {
        if ($this->ion_auth->logged_in()) {
            redirect("/");
        }
        $data['message'] = $this->session->flashdata('message');

        $this->template->display($data, 'login.tpl');
	}

    // Process a login request from the form
    public function login() {
        $email = $this->input->post('email');
        $password = $this->input->post('password');
        $remember = (bool)$this->input->post('remember');
        
        if ($this->ion_auth->login($email, $password, $remember)) {
            redirect("/");
        } else {
            $this->session->set_flashdata('message', $this->ion_auth->errors());
		    redirect("/login");
        }
	}

    // Process a logout request
    public function logout() {
        $logout = $this->ion_auth->logout();
        redirect("/login");
    }
}