<?php
class UserController{

    function profile($username){
        echo "hello ".$username;
    }

    function file(){
      $f= new File(server_assets("style/sass/screen.scss"));
      return $f;
    }
}