<?php ini_set('error_reporting', 0);?>
<link rel="stylesheet" href="<?php echo assets("style/stylesheets/screen.css") ?>"/>
<link rel="stylesheet" href="<?php echo assets("style/stylesheets/ie.css") ?>"/>
<link rel="stylesheet" href="<?php echo assets("style/stylesheets/print.css") ?>"/>

<?php
if(isset($renderstack) && count($renderstack)>0){
   $last=&array_pop($renderstack);
   foreach($last->sections as $key=>$value){
     $last->parent=str_replace("#child ".$key, $value, $last->parent);
   }
}
 echo $last->parent;
 unset($last)
?>
