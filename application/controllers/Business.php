<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Business extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('business_model');
        $this->load->model('financials_model');
        $this->setMenu('business');
    }

    // Function to display the main Time Tracking page
    public function time($id = 0) {
        $data = array();
        $selected_client = 0;
        
        // Handle user setting an entry_date
        $session_entry_date = $this->session->userdata('time_entry_date');
        $entry_date = date('Y-m-d');
        if($this->input->post('entry_date')) {
            $entry_date = $this->input->post('entry_date');
            $this->session->set_userdata('time_entry_date', $entry_date);
        } elseif (!empty($session_entry_date)) {
            $entry_date = $session_entry_date;
        }
        $data['entry_date'] = $entry_date;

        // Get our client list & dropdown list
        $client_lookup = array();
        $clients = $this->financials_model->getClients();
        $client_lookup = $this->getLookups($clients);

        // Get the day's time entries and set the data accordingly
        $day_total = 0;
        $data['time_entries'] = $this->business_model->getTimeEntries(array('entry_date' => $entry_date));
        foreach($data['time_entries'] as $key => $row) {
            // Set the client name
            if(isset($client_lookup[$row['client_id']])) {
                $data['time_entries'][$key]['client'] = $client_lookup[$row['client_id']];
            } else {
                $data['time_entries'][$key]['client'] = '';
            }

            // Set the total time based on what we got from db in minutes and turned into hours:mins
            if($row['diff'] > 0) {
                // Timer currently running, add the two together
                 $data['time_entries'][$key]['total_time'] += $row['diff'];
            }
            $day_total += $data['time_entries'][$key]['total_time'];
            $hours = floor($data['time_entries'][$key]['total_time'] / 60);
            $minutes = $data['time_entries'][$key]['total_time'] % 60;
            $data['time_entries'][$key]['total_time'] = sprintf("%d:%02d", $hours, $minutes);

            // Pull out our selected entry if we have one
            if($row['id'] == $id) {
                $data['selected_entry'] = $data['time_entries'][$key];
                $selected_client = $data['time_entries'][$key]['client_id'];
            }
        }

        // Add our day total to the view array
        $hours = floor($day_total / 60);
        $minutes = $day_total % 60;
        $data['day_total'] = sprintf("%d:%02d", $hours, $minutes);

        // Get our client options
        $data['client_options'] = $this->getOptions($clients, $selected_client);

        $this->templateDisplay('business/time.tpl', $data);
    }

    // Function called to either set a time entry from the form directly or simply toggle the timer
    public function setTime($id = 0) {
        $id = (int)$id;
        if($id > 0) {
            // We just want to turn on/off a timer
            $this->business_model->setTimeClock($id);
        } else {
            // We are updating from the form
            $entry = $this->input->post('entry');
            $id = $this->input->post('entry_id');
            if(!empty($entry)) {
                $this->business_model->setTimeEntries($id, $entry);
            }
        }
        redirect("/business/time");
    }

    // Function to delete a time entry and send the user back to the main Time Tracking page
    public function deleteTime() {
        $id = $this->input->post('entry_id');
        if($id > 0) {
            $this->business_model->deleteTimeEntry($id);
        }
        redirect("/business/time");
    }

    // Function to display the main invoicing page
    public function invoicing() {
        $data = array();
        
        // Get our client list
        $clients = $this->financials_model->getClients();
        $data['clients'] = $this->getLookups($clients);

        // Get our accounts options
        $data['account_dropdown'] = $this->getOptions($this->financials_model->getChecksAccounts());

        // Get our invoices and loop thru them to set client name
        // IN FUTURE, probably add this: array('created_date >=' => $start_date, 'created_date <=', $end_date)
        $invoices = $this->business_model->getInvoices();
        foreach($invoices as $key => $row) {
            if(isset($data['clients'][$row['client_id']])) {
                $row['client_name'] = $data['clients'][$row['client_id']];
            } else {
                $row['client_name'] = '';
            }
            $data['invoices'][$row['id']] = $row;
        }

        $data['modal_title'] = "Confirm Delete?";
        $this->templateDisplay('business/invoicing.tpl', $data);
    }

    // Function to delete an invoice and send the user back to the main invoicing page
    public function deleteInvoice() {
        $id = $this->input->post('invoice_id');
        if($id > 0) {
            $this->business_model->deleteInvoice($id);
        }
        redirect("/business/invoicing");
    }

    // Function to set an invoice (either create a new one or update an existing one - more to come here in the future)
    public function setInvoice() {
        $id = 0;
        $invoice = $this->input->post('invoice');
        if(!empty($invoice)) {
            if(!isset($invoice['paid'])) {
                $invoice['paid'] = 0;
            }

            if($invoice['id'] == 0) {
                // We are creating a new invoice
                $start_date = $this->input->post('start_date');
                $end_date = $this->input->post('end_date');
                $id = $this->business_model->createInvoice($invoice, $start_date, $end_date);
            } else {
                // We are editing an existing invoice
                $id = $invoice['id'];
                unset($invoice['id']);
                $this->business_model->setInvoice($id, $invoice);
            }
        }
        redirect("/business/editInvoice/$id");
    }

    // Function to set an invoice as paid and send the user back to the main invoicing page
    public function setInvoicePaid() {
        $paid = $this->input->post('paid');
        if(!empty($paid)) {
            $invoice_id = $paid['id'];
            $lookup = $this->business_model->getInvoice($invoice_id);

            // Append a note to any existing notes
            $notes_update = $lookup['notes'] . "\nPaid {$paid['paid_date']} - check #{$paid['check_num']}";
            $this->business_model->setInvoice($invoice_id, array('paid' => 1, 'notes' => $notes_update));

            // And add the entry to the income log
            $income = array('invoice_id' => $invoice_id, 'check_num' => $paid['check_num'], 'paid_date' => $paid['paid_date'], 'account_id' => $paid['account_id'], 'total' => $lookup['amount'], 'client_id' => $lookup['client_id']);
            $this->financials_model->setIncome(0, $income);

        }
        redirect("/business/invoicing");
    }

    // function to display the edit invoice page, which also includes the initial page to create a new invoice
    public function editInvoice($id = 0) {
        $data = array();

        // Get our invoice
        $data['invoice'] = $this->business_model->getInvoice($id);
        if(!empty($data['invoice'])) {
            $data['invoice_markup'] = $this->printInvoice($id, 0);
            $data['action'] = "Update";
            $client_id = $data['invoice']['client_id'];
        } else {
            $data['action'] = "Add";
            $client_id = 0;
        }
     
        // Get our client dropdown list
        $data['client_options'] = $this->getOptions($this->financials_model->getClients(), $client_id);

        $this->templateDisplay('business/edit_invoice.tpl', $data);
    }

    // Function to "Print" an invoice either to a PDF file for download or to the screen as a normal html template
    public function printInvoice($id = 0, $download = 0) {
        $data = array();
        
        // Get our invoice
        $download = (int)$download;
        $data['invoice'] = $this->business_model->getInvoice($id);
        if(!empty($data['invoice'])) {
            // Get our client, invoice, and invoice options details
            $data['client'] = $this->financials_model->getClient($data['invoice']['client_id']);
            $data['detail'] = $this->business_model->getInvoiceDetail($id, $data['client']['default_rate']);
            $data['billables'] = $this->business_model->getBillables(array('invoice_id' => $id), array('created_date' => 'ASC'));
            $data['options']['invoice_logo_url'] = $this->config_model->getOption('invoice_logo_url');
            $data['options']['invoice_from'] = $this->config_model->getOption('invoice_from');
            $data['options']['invoice_notes'] = $this->config_model->getOption('invoice_notes');

            $base_dir = $this->config_model->getOption('invoice_path');
            $base_name = $this->config_model->getOption('invoice_base_name');
            $file_name = "{$base_name}{$id}.pdf";
            $full_name = "$base_dir/$file_name";
            $pdf_data = null;

            // Create a PDF and write it to disk so long as the invoice hasn't been sent yet.
            if(!file_exists($full_name)) {
                $this->load->library('pdf');
                $this->pdf->load_view('business/invoice_pdf', $data);
                $this->pdf->render();
                $pdf_data = $this->pdf->output();
                file_put_contents($full_name, $pdf_data);
            }

            if($download == 1) {
                $this->load->helper('download');
                if(empty($pdf_data)) {
                    $pdf_data = file_get_contents("$base_dir/$file_name");
                }
                force_download($file_name, $pdf_data);
            } else {
                return $this->template->render($data, true, 'business/invoice_view.tpl');
            }
        }        
    }

    // Function to display the send invoice page
    public function sendInvoice($id) {
        $data = array();
        $data['invoice'] = $this->business_model->getInvoice($id);
        if(!empty($data['invoice'])) {
            // Get our client and invoice details
            $data['client'] = $this->financials_model->getClient($data['invoice']['client_id']);
            $data['invoice']['amount'] = number_format($data['invoice']['amount'], 2);
            $this->templateDisplay('business/send_invoice.tpl', $data);
        } else {
            redirect("/business/invoicing");
        }
    }

    // Function to actually do the sending of the invoice via email, both as text and html format
    public function doSendInvoice() {
        $message = $this->input->post('message');
        if(!empty($message) && !empty($message['recipients'])) {
            $this->load->library('email');

            // Get the file info for the attachment
            $base_dir = $this->config_model->getOption('invoice_path');
            $base_name = $this->config_model->getOption('invoice_base_name');
            $id = $message['invoice_id'];
            $file_name = "{$base_name}{$id}.pdf";

            // Render both components of the email from their templates
            $message_text = $this->template->render($message, true, 'business/invoice_email_text.tpl');
            $message_html = $this->template->render($message, true, 'business/invoice_email_html.tpl');
            
            // Turn our email recipients into a comma separated list
            $emails = preg_replace('/\s+/', ',', $message['recipients']);

            // Configure our email parts, attach the file, and send it
            $config = array('mailtype' => 'html', 
                            'protocol' => 'smtp',
                            'smtp_port' => '25',
                            'smtp_host' => $this->config_model->getOption('smtp_host'));
            if($this->config_model->getOption('smtp_user')) {
                $config['smtp_user'] = $this->config_model->getOption('smtp_user');
            }
            if($this->config_model->getOption('smtp_pass')) {
                $config['smtp_pass'] = $this->config_model->getOption('smtp_pass');
            }

            //$config = array('mailtype' => 'html');
            $this->email->initialize($config);
            $this->email->from($this->config_model->getOption('invoice_from_email'), $this->config_model->getOption('invoice_from_name'));
            $this->email->to($emails);
            $this->email->subject($this->config_model->getOption('invoice_subject'));
            $this->email->message($message_html);
            $this->email->set_alt_message($message_text);
            $this->email->attach("$base_dir/$file_name");
            if($this->email->send()) {
                $this->business_model->setInvoice($id, array('sent' => 1));
                $this->setMessage("Invoice successfully sent", 'success');
            } else {
                $this->setMessage("Failed to send invoice", 'danger');
            }
            redirect("/business/invoicing");
        } else {
            $this->setMessage("At least one recipient is required", 'danger');
            redirect("/business/sendInvoice/$id");
        }
    }

    // Function to display the main Misc Expense page
    public function miscExpense($id = 0) {
        $data = array();
        
        // Handle user filtering by a start_date
        $session_start_date = $this->session->userdata('miscexpense_start_date_filter');
        $start_date = date('Y-m-01', strtotime('-1 month'));
        if($this->input->post('start_date')) {
            $start_date = $this->input->post('start_date');
            $this->session->set_userdata('miscexpense_start_date_filter', $start_date);
        } elseif (!empty($session_start_date)) {
            $start_date = $session_start_date;
        }
        $data['start_date'] = $start_date;

        // Get our required data and format for the view
        $expenses = $this->business_model->getRows(array('created_date >=' => $start_date), 'misc_expense');
        $categories = $this->business_model->getRows(array(), 'misc_expense_category');
        $category_lookup = $this->getLookups($categories);
        $selected_category = 0;

        foreach($expenses as $row) {
            if(isset($category_lookup[$row['category_id']])) {
                $row['category'] = $category_lookup[$row['category_id']];
            } else {
                $row['category'] = '';
            }            
            $data['rows'][$row['id']] = $row;

            // Pull out our selected item if set and matching the current loop
            if($row['id'] == $id) {
                $data['selected'] = $row;
                $selected_category = $row['category_id'];
            }
        }
        $data['category_options'] = $this->getOptions($categories, $selected_category);

        $this->templateDisplay('business/misc_expense.tpl', $data);
    }

    // Function to process the creation/update of a misc expense
    public function setMiscExpense() {
        $id = $this->input->post('id');
        $post_array = $this->input->post('post_array');
        if(!empty($post_array)) {
            $this->business_model->setRow($id, $post_array, 'misc_expense');
        }
        redirect("/business/miscExpense");
    }

    // Function to delete a misc expense
    public function deleteMiscExpense() {
        $id = $this->input->post('row_id');
        $this->business_model->deleteRow($id, 'misc_expense');
        redirect("/business/miscExpense");
    }

    // Function to display the main Billables page
    public function billables($id = 0) {
        $data = array();
        
        // Handle user filtering by a start_date
        $session_start_date = $this->session->userdata('billables_start_date_filter');
        $start_date = date('Y-m-01', strtotime('-1 month'));
        if($this->input->post('start_date')) {
            $start_date = $this->input->post('start_date');
            $this->session->set_userdata('billables_start_date_filter', $start_date);
        } elseif (!empty($session_start_date)) {
            $start_date = $session_start_date;
        }
        $data['start_date'] = $start_date;

        // Get our required data and format for the view
        $billables = $this->business_model->getBillables(array('created_date >=' => $start_date));

        // Get our client list & dropdown list
        $client_lookup = array();
        $clients = $this->financials_model->getClients();
        $client_lookup = $this->getLookups($clients);
        $selected_client = 0;

        foreach($billables as $row) {
            if(isset($client_lookup[$row['client_id']])) {
                $row['client'] = $client_lookup[$row['client_id']];
            } else {
                $row['client'] = '';
            }            
            $data['rows'][$row['id']] = $row;

            // Pull out our selected item if set and matching the current loop
            if($row['id'] == $id) {
                $data['selected'] = $row;
                $selected_client = $row['client_id'];
            }
        }
        $data['client_options'] = $this->getOptions($clients, $selected_client);

        $this->templateDisplay('business/billables.tpl', $data);
    }

    // Function to process the creation/update of a misc expense
    public function setBillable() {
        $id = $this->input->post('id');
        $post_array = $this->input->post('post_array');
        if(!empty($post_array)) {
            $this->business_model->setBillable($id, $post_array);
        }
        redirect("/business/billables");
    }

    // Function to delete a misc expense
    public function deleteBillable() {
        $id = $this->input->post('row_id');
        $this->business_model->deleteBillable($id);
        redirect("/business/billables");
    }
}
