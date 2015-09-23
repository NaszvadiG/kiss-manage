<?php defined('BASEPATH') OR exit('No direct script access allowed');

class Tree {

    private $tree = array();
    private $hierarchy = array();
    private $node_counter = 0;
    private $selected_node_id = 0;
    private $selected_node_counter = 0;

    public function getSelectedNodeCounter() {
        return $this->selected_node_counter;
    }

    public function getHierarchy() {
        return $this->hierarchy;
    }

    private function setHierarchy($id, $parent_id, $name) {
        if(isset($this->hierarchy[$parent_id])) {
            $name = $this->hierarchy[$parent_id]['name'] . ' \\ ' . $name;
        }
        $this->hierarchy[$id] = array('id' => $id, 'name' => $name);
    }

    public function getTree($data = array(), $selected = 0) {
        if(!empty($data)) {
            $this->selected_node_id = (int)$selected;
            $this->buildTree($data);
        }
        return $this->tree;
    }

    private function buildNode($row) {
        if($row['id'] == $this->selected_node_id) {
            $this->selected_node_counter = $this->node_counter;
        }
        $this->node_counter++;
        return array('text' => $row['name'], 'data' => $row['data'], 'node_id' => $row['id'], 'parent_id' => $row['parent_id']);
    }

    private function buildTree($data) {
        foreach($data as $row) {
            if($row['parent_id'] == 0) {
                $node = $this->buildNode($row);
                $this->setHierarchy($row['id'], $row['parent_id'], $row['name']);
                $nodes = $this->buildNodes($row['id'], $data);
                if(!empty($nodes)) {
                   $node['nodes'] = $nodes;
                }
                $this->tree[] = $node;
            }
        }
    }

    private function buildNodes($parent_id, $data) {
        $nodes = array();
        foreach($data as $row) {
            if($row['parent_id'] == $parent_id) {
                $node = $this->buildNode($row);
                $this->setHierarchy($row['id'], $row['parent_id'], $row['name']);
                $children = $this->buildNodes($row['id'], $data);
                if(!empty($children)) {
                    $node['nodes'] = $children;
                }
                $nodes[] = $node;
            }
        }
        return $nodes;
    }
}