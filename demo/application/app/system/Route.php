<?php

class Route{

    protected $method=null;
    protected $request_uri=null;

    function __construct(){
        $this->load();
    }

    function load(){
        $this->request_uri=strtolower($_SERVER["REQUEST_URI"]);

        $this->method=strtolower($_SERVER["REQUEST_METHOD"]);
    }
}