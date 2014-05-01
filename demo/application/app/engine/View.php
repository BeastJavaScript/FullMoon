<?php
/**
 * Created by PhpStorm.
 * User: shava_000
 * Date: 4/30/14
 * Time: 4:45 PM
 */

class View {
    protected $content;
    protected $name;
    protected $vars;
    function __construct($name){
        $vars=[];
        $this->name=$name;
    }

    function send($var,$content){
        $this->vars[$var]=$content;
    }

    function __toString(){
        foreach($this->vars as $key=>$value){
            $$key=$value;
        }

        ob_start();
        include __DIR__."/../view/$this->name.php";
        $this->content=ob_get_clean();
        return $this->content;
    }
}