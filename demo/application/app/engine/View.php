<?php
/**
 * Created by PhpStorm.
 * User: shava_000
 * Date: 4/30/14
 * Time: 4:45 PM
 */

class View {
    protected $content;
    function __construct($name){
        global $config;
        ob_start();
        include __DIR__."/../view/$name.php";
        $this->content=ob_get_clean();
    }


    function __toString(){
        return $this->content;
    }
}