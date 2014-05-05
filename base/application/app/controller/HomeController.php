<?php

class HomeController{

    function home(){
        $v=new View("home");
        $v->send("user","shavyg2");
       return $v;
    }
}