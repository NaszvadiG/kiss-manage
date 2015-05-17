<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Reporting extends MY_Controller {
    public function __construct() {
        parent::__construct();
        $this->load->model('financials_model');
    }

    // Function to display the expenses reporting page
	public function expenses() {
        $data = array();

        // Handle our reporting options
        $options = $this->input->post('options');
        if(!isset($options['start_date'])) {
            $options['start_date'] = date('Y-01-01');
        }
        if(!isset($options['end_date'])) {
            $options['end_date'] = date('Y-m-d');
        }
        if(!isset($options['filter']['deductible'])) {
            $options['filter']['deductible'] = 0;
        }
        if(!isset($options['group_by'])) {
            $options['group_by'] = 'receipts.category_id';
        }
        $data['options'] = $options;

        // Get a list of months between our two dates
        $months = array();
        $start = (new DateTime($options['start_date']))->modify('first day of this month');
        $end = (new DateTime($options['end_date']))->modify('first day of this month');
        $interval = DateInterval::createFromDateString('1 month');
        $period = new DatePeriod($start, $interval, $end);

        foreach ($period as $dt) {
            $temp = $dt->format("Y-m");
            $months[$temp] = $temp;
        }

        // Get our deductible option list
        $data['deduct_options'] = $this->getOptions($this->financials_model->getDeductibles(), $options['filter']['deductible']);

        // Get the report data
        $report = $this->financials_model->getSpendingReport($options);
        $data['report'] = $report;

        // Build our graph/report data
        $graph = array();
        $chart_cats = array();
        foreach($report as $month => $month_data) {
            unset($months[$month]);
            $group = array('month' => $month);
            foreach($month_data as $deductible => $ded_data) {
                foreach($ded_data as $category => $total) {
                    $chart_cats[$category] = $category;
                    $group[$category] = $total;
                }
            }
            $graph[] = $group;
        }

        // Add entries for any months we didn't have in the data
        foreach($months as $month) {
            $graph[] = array('month' => $month);
        }

        // Make sure we have all categories we found in all groups
        foreach($chart_cats as $cat) {
            foreach($graph as $key => $row) {
                if(!isset($row[$cat])) {
                    $graph[$key][$cat] = 0;
                }
            }
        }

        // Sort them so they are pretty
        ksort($chart_cats);
        foreach($graph as $key => $row) {
            ksort($graph[$key]);
        }

        // Configure our graph data for the page
        if(!empty($graph)) {
            $data['graph']['json'] = json_encode($graph);
            $data['graph']['cats'] = "'" . implode("','", $chart_cats) . "'";
        }
        
        $this->templateDisplay('reporting/expenses.tpl', $data);
	}

    // Function to display the income reporting page
    public function income() {
        $data = array();

        // Handle our reporting options
        $options = $this->input->post('options');
        if(!isset($options['start_date'])) {
            $options['start_date'] = date('Y-01-01');
        }
        if(!isset($options['end_date'])) {
            $options['end_date'] = date('Y-m-d');
        }
        
        $selected_client = isset($options['filter']['client_id']) ? $options['filter']['client_id'] : 0;
        if(isset($options['filter']['client_id']) && $options['filter']['client_id'] <= 0) {
            unset($options['filter']['client_id']);
            $selected_client = 0;
        }
        $data['options'] = $options;

        // Get a list of months between our two dates
        $months = array();
        $start = (new DateTime($options['start_date']))->modify('first day of this month');
        $end = (new DateTime($options['end_date']))->modify('first day of this month');
        $interval = DateInterval::createFromDateString('1 month');
        $period = new DatePeriod($start, $interval, $end);

        foreach ($period as $dt) {
            $temp = $dt->format("Y-m");
            $months[$temp] = $temp;
        }

        // Get our client options
        $data['client_options'] = $this->getOptions($this->financials_model->getClients(), $selected_client);

        // Get the report data
        $report = $this->financials_model->getIncomeReport($options);
        $data['report'] = $report;

        // Build our graph/report data
        $graph = array();
        $chart_cats = array();
        foreach($report as $month => $month_data) {
            unset($months[$month]);
            $group = array('month' => $month);
            foreach($month_data as $client => $client_data) {
                $chart_cats[$client] = $client;
                $group[$client] = $client_data['total'];
            }
            $graph[] = $group;
        }

        // Add entries for any months we didn't have in the data
        foreach($months as $month) {
            $graph[] = array('month' => $month);
        }

        // Make sure we have all clients we found in all groups
        foreach($chart_cats as $cat) {
            foreach($graph as $key => $row) {
                if(!isset($row[$cat])) {
                    $graph[$key][$cat] = 0;
                }
            }
        }

        // Sort them so they are pretty
        ksort($chart_cats);
        foreach($graph as $key => $row) {
            ksort($graph[$key]);
        }

        // Configure our graph data for the page
        if(!empty($graph)) {
            $data['graph']['json'] = json_encode($graph);
            $data['graph']['cats'] = "'" . implode("','", $chart_cats) . "'";
        }

        $this->templateDisplay('reporting/income.tpl', $data);
	}

    // Function to display the utility reporting page
    public function utility() {
        $data = array();

        // Handle our reporting options
        $options = $this->input->post('options');
        if(!isset($options['start_date'])) {
            $options['start_date'] = date('Y-01-01');
        }
        if(!isset($options['end_date'])) {
            $options['end_date'] = date('Y-m-d');
        }
        if(!isset($options['filter']['category_id'])) {
            $options['filter']['category_id'] = 0;
        }
        $data['options'] = $options;

        // Get a list of months between our two dates
        $months = array();
        $start = (new DateTime($options['start_date']))->modify('first day of this month');
        $end = (new DateTime($options['end_date']))->modify('first day of this month');
        $interval = DateInterval::createFromDateString('1 month');
        $period = new DatePeriod($start, $interval, $end);

        foreach ($period as $dt) {
            $temp = $dt->format("Y-m");
            $months[$temp] = $temp;
        }

        // Get our categories options
        $data['category_options'] = $this->getOptions($this->financials_model->getUtilityCategories(), $options['filter']['category_id']);

        // Get the report data
        $report = $this->financials_model->getUtilityReport($options);
        $data['report'] = $report;

        // Build our graph/report data
        $graph = array();
        $chart_cats = array();
        foreach($report as $month => $month_data) {
            unset($months[$month]);
            $group = array('month' => $month);
            foreach($month_data as $category => $total) {
                $chart_cats[$category] = $category;
                $group[$category] = $total;
            }
            $graph[] = $group;
        }

        // Add entries for any months we didn't have in the data
        foreach($months as $month) {
            $graph[] = array('month' => $month);
        }

        // Make sure we have all categories we found in all groups
        foreach($chart_cats as $cat) {
            foreach($graph as $key => $row) {
                if(!isset($row[$cat])) {
                    $graph[$key][$cat] = 0;
                }
            }
        }

        // Sort them so they are pretty
        ksort($chart_cats);
        foreach($graph as $key => $row) {
            ksort($graph[$key]);
        }

        // Configure our graph data for the page
        if(!empty($graph)) {
            $data['graph']['json'] = json_encode($graph);
            $data['graph']['cats'] = "'" . implode("','", $chart_cats) . "'";
        }

        $this->templateDisplay('reporting/utility.tpl', $data);
	}
}