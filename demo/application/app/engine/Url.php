<?php

class Url{

    protected $method=null;
    protected $request_uri=null;

    function __construct(){
        $this->load();
    }

    function load(){
        $this->request_uri=strtolower($_SERVER["REQUEST_URI"]);
        $this->request_uri=preg_replace("~/$~","",$this->request_uri);
        if($this->request_uri === ""){
            $this->request_uri="/";
        }
        $this->method=strtolower($_SERVER["REQUEST_METHOD"]);
    }


    function request(){
        return $this->request_uri;
    }
}