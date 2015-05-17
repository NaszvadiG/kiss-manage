<?php
/* Extension of the default CI_controller for use in our controllers.
 * Various functionality that we want across all controllers found here
 */
class MY_Controller extends CI_Controller
{
    protected $user = null;
    protected $header_data = array('selected_menu' => '', 'selected_submenu' => '');

    public function __construct() {
        parent::__construct();

        // Check that the request is frmo a logged in user, if not go to the login page
        if (!$this->ion_auth->logged_in()) {
            redirect('/login');
        }
        $this->user = $this->ion_auth->user()->row();

        // Collect a few pieces of data for the header
        $this->header_data['first_name'] = $this->user->first_name;
        $this->header_data['title'] = $this->config_model->getOption('site_title');
        $this->header_data['navbar_brand'] = $this->config_model->getOption('navbar_brand');
    }

    // Helper function to output some raw debug data ot the screen
    protected function debug($data, $exit = false) {
        echo "<pre>";
        var_dump($data);
        echo "</pre>";
        if($exit) {
            exit;
        }
    }

    // Function to set a flash message to be displayed on the next page load
    protected function setMessage($message, $status = 'success') {
        $this->session->set_flashdata('status', $status);
        $this->session->set_flashdata('message', $message);
    }

    // Function to set the current Menu.  Technically only required when the current page is not one thats found in the menu definition.
    protected function setMenu($menu) {
        $this->header_data['selected_menu'] = $menu;
    }

    // Function to set the current Sub Menu.  Technically only required when the current page is not one thats found in the menu definition.
    protected function setSubmenu($submenu) {
        $this->header_data['selected_submenu'] = $submenu;
    }

    // Wrapper function to display a template to the page.
    protected function templateDisplay($template, $data) {
        $data['header_data'] = $this->header_data;
        $data['header_data']['status'] = $this->session->flashdata('status');
        $data['header_data']['message'] = $this->session->flashdata('message');
        $this->template->display($data, $template);
    }

    // Helper function to get the options of an option list based on how we set these up in the templates
    protected function getOptions($options, $selected = 0, $name_key = 'name', $id_key = 'id') {
        $return = array();
        foreach($options as $option) {
            $select = '';
            if($selected == $option[$id_key]) {
                $select = 'selected';
            }
            $return[] = "<option value=\"{$option[$id_key]}\" $select>{$option[$name_key]}</option>";
        }
        return $return;
    }

    // Helper function to take an array of rows from the database and return an array if id => name pairs for lookup purposes
    protected function getLookups($options, $name_key = 'name', $id_key = 'id') {
        $return = array();
        foreach($options as $option) {
            $return[$option[$id_key]] = $option[$name_key];
        }
        return $return;
    }
}
