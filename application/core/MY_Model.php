<?php
/* Extension of the default CI_Model for use in our models.
 * Various functionality that we want across all models found here
 */
class MY_model extends CI_Model {

    // Vars used to standardize the methods across slightly different table defs
    protected $table = null;
    protected $id = 'id';
    protected $name = 'name';
    protected $status = 'status';

    public function __construct() {
        parent::__construct();
        $this->load->database();
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

    // Generic function to configure filters for a set of options
    protected function getFilters($options) {
        foreach($options as $key => $value) {
            $this->db->where($key, $value);
        }
    }

    // Generic setter for an array of things we want to set all at once
    protected function setAll($vars) {
        if(is_array($vars)) {
            foreach($vars as $var => $value) {
                $this->set($var, $value);
            }
        }
    }

    // Generic setter for whatever we may need
    protected function set($var, $value) {
        $this->$var = $value;
    }

    // Generic getter for whatever we may need
    protected function get($var) {
        if(isset($this->$var)) {
            return $this->$var;
        } else {
            return false;
        }
    }

    // Private function to negotiate a table name
    private function getTableName($table) {
        if(!$table) {
            $table = $this->table;
        }
        return $table;
    }

    // Function to get a row from the database based on our current table/id colum/etc
    public function getRow($id, $table = null, $select = null) {
        if(!empty($id)) {
            if($select) {
                $this->db->select($select);
            }
            $query = $this->db->get_where($this->getTableName($table), array($this->id => $id));
            return $query->row_array();
        }
        return false;
    }

    // Function to get rows from the database based on our current table and optionally passed in where array
    public function getRows($where, $table = null, $order = array(), $select = null) {
        if($select) {
            $this->db->select($select);
        }
        foreach($order as $col => $dir) {
            $this->db->order_by($col, $dir);
        }
        $query = $this->db->get_where($this->getTableName($table), $where);
        return $query->result_array();
    }

    // Generic function to set a row into a database table.  Either insert or update based on id
    public function setRow($id, $row, $table = null) {
        if(!empty($row)) {
            if(!empty($id)) {
                if($this->db->update($this->getTableName($table), $row, array($this->id => $id))) {
                    return $id;
                }
            } else {
                $this->db->insert($this->getTableName($table), $row);
                return $this->db->insert_id();
            }
        }
        return false;
    }
    
    // Generic function to delete a row from a database table
    public function deleteRow($id, $table = null) {
        if(!empty($id)) {
            return $this->db->delete($this->getTableName($table), array($this->id => $id));
        }
        return false;
    }
}
