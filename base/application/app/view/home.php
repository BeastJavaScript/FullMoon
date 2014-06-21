<?php //ini_set('error_reporting', 0);?>
<?php
  ob_start();
  if(!isset($renderstack)){
    $renderstack=[];
  }
  array_push($renderstack,new stdClass());

  include("main-layout.php");
  if(!isset($last)){
    $last=null;
  }
  $last=$renderstack[count($renderstack)-1];
  if(isset($last) && !isset($last->parent)){
    $last->parent=null;
  }
  if(isset($last)):
    $last->parent=ob_get_clean();
  endif;
  if(isset($last) &&!isset($last->section)):
  $last->sections=[];
  endif;
?>
<?php ob_start();?>

<?php if($user): ?>
<div>Welcome to beast homepage, <?php echo $user ?></div>
<?php endif; ?>
<div>Welcome to beast homepage, <?php echo strtolower("Shavuahn Gabay") ?></div>
<?php
  $section_buffer=ob_get_clean();
  $last->sections['page']=$section_buffer
?>
<?php
if(isset($renderstack) && count($renderstack)>0){
   $last=array_pop($renderstack);
   if(isset($last->sections)):
     foreach($last->sections as $key=>$value){
       if(isset($last) && isset($last->parent)):
       $last->parent=str_replace("#child ".$key, $value, $last->parent);
       endif;
     }
   endif;
}
 if(isset($last->parent)):
 echo $last->parent;
 endif;
?>
