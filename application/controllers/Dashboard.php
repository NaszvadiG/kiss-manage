<?php
defined('BASEPATH') OR exit('No direct script access allowed');

class Dashboard extends MY_Controller {

    public function __construct() {
        parent::__construct();
        $this->load->model('house_model');
        $this->load->model('financials_model');
    }

    // Function to display the main dashboard page and contained components
	public function index() {
        $data = array();

        // Get the shopping summary
        $summary = array();
        $stores = $this->house_model->getStores();
        foreach($stores as $store) {
            $items = $this->house_model->getShoppingList(array('store_id' => $store['id'], 'status' => 0));
            $count = count($items);
            if($count > 0) {
                $summary[] = array('id' => $store['id'], 'name' => $store['name'], 'count' => $count);
            }
        }
        $data['shopping_summary'] = $summary;

        // Get the monthly spending summary
        $spending_summary = array();
        $chart_cats = array('Income');
        $options = array('start_date' => date('Y-m-01', strtotime('-6 months')));
        $group_template = array('month' => '', 'income' => 0);

        // Get our deductibles
        $deductibles = $this->financials_model->getDeductibles();
        foreach($deductibles as $row) {
            $chart_cats[$row['name']] = $row['name'];
            $group_template[$row['name']] = 0;
        }

        // Get our income
        $income = $this->financials_model->getIncomeReport($options);

        // Get our expenses
        $options['group_by'] = "receipts_categories.deductible";
        $spending = $this->financials_model->getSpendingReport($options);
        foreach($spending as $month => $month_data) {
            $group = $group_template;
            $group['month'] = $month;
            if(isset($income[$month])) {
                $total = 0;
                foreach($income[$month] as $client_totals) {
                    $total += $client_totals['total'];
                }
                $group['Income'] = $total;
            } else {
                $group['Income'] = 0;
            }
            foreach($month_data as $deductible => $ded_data) {
                $total = 0;
                foreach($ded_data as $category => $row_total) {
                    $total += $row_total;
                    if(isset($group[$deductible])) {
                        $group[$deductible] += $total;
                    }
                }
            }
            $spending_summary[] = $group;
        }
        if(!empty($spending_summary)) {
            $data['spending_summary']['json'] = json_encode($spending_summary);
            $data['spending_summary']['cats'] = "'" . implode("','", $chart_cats) . "'";
        }

        $this->templateDisplay('dashboard.tpl', $data);
	}
}