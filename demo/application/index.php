<?php
require "vendor/autoload.php";
require "app/engine/Url.php";

$url= new Url();
$config=(object)json_decode(file_get_contents("routes.json"));


$match=[];
$hasUrl=false;
foreach($config->routes as $route){
    if(preg_match("~^".$route->match."$~",$url->request(),$match) === 1){
        $hasUrl=true;
        array_shift($match);
        $classname=$route->controller;
        $controller=new $classname;
        call_user_func_array(array($controller,$route->method),$match);
    }
}
if(!$hasUrl){
    echo "url doens't exist";
}

