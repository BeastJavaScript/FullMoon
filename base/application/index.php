<?php
require "vendor/autoload.php";
require "app/engine/Url.php";

function getRelativePath($from, $to)
{
    // some compatibility fixes for Windows paths
    $from = is_dir($from) ? rtrim($from, '\/') . '/' : $from;
    $to   = is_dir($to)   ? rtrim($to, '\/') . '/'   : $to;
    $from = str_replace('\\', '/', $from);
    $to   = str_replace('\\', '/', $to);

    $from     = explode('/', $from);
    $to       = explode('/', $to);
    $relPath  = $to;

    foreach($from as $depth => $dir) {
        // find first non-matching dir
        if($dir === $to[$depth]) {
            // ignore this directory
            array_shift($relPath);
        } else {
            // get number of remaining dirs to $from
            $remaining = count($from) - $depth;
            if($remaining > 1) {
                // add traversals up to first matching dir
                $padLength = (count($relPath) + $remaining - 1) * -1;
                $relPath = array_pad($relPath, $padLength, '..');
                break;
            } else {
                $relPath[0] = './' . $relPath[0];
            }
        }
    }
    return implode('/', $relPath);
}

$basedir=getRelativePath($_SERVER["DOCUMENT_ROOT"],__DIR__);
$basedir=str_replace("~../~","",$basedir);
$basedir=preg_replace("~/$~","",$basedir);
$basedir=preg_replace("~^.~","",$basedir);

$server_basedir=__DIR__;

$url= new Url();
$config=(object)json_decode(file_get_contents("routes.json"));


function base($url){
    global $basedir;
    return str_replace("~//~","/","$basedir/$url");
}


function server_base($url){
    global $server_basedir;
    return str_replace("~//~","/","$server_basedir/$url");
}


function app($url){
    global $basedir;
    $link="$basedir/app/$url";
    return str_replace("~//~","/",$link);
}

function server_app($url){
    global $server_basedir;
    $link="$server_basedir/app/$url";
    return str_replace("~//~","/",$link);
}


function assets($url){
    global $basedir;
    $link="$basedir/assets/$url";
    return str_replace("~//~","/",$link);
}

function server_assets($url){
    global $server_basedir;
    $link="$server_basedir/assets/$url";
    return str_replace("~//~","/",$link);
}


$match=[];
$hasUrl=false;
foreach($config->routes as $route){
    if(preg_match("~^".$route->match."$~",$url->request(),$match) === 1){
        $hasUrl=true;
        array_shift($match);
        $classname=$route->controller;
        $controller=new $classname;
        $content=call_user_func_array(array($controller,$route->method),$match);
        if($content instanceof File)
            $content->send();
        else
            echo $content;
    }
}
if(!$hasUrl){
    echo "url doens't exist";
}

