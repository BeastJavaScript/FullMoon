<?php ini_set('error_reporting', 0);?>
<?php
  $renderstack[]= new stdClass();
  ob_start();
  include("main-layout.php");
  $last=&$renderstack[count($renderstack)-1];
  $last->parent=ob_get_clean();
  $last->sections=[];
?>

<?php ob_start();?>
<div>Welcome to beast homepage</div>
<?php
  $section_buffer=ob_get_clean();
  $last->sections['page']=$section_buffer
?>
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
