<?php ini_set('error_reporting', 0);?>
<!doctype html>
<html lang="en-US">
<head>
    <meta charset="UTF-8">
    <title></title>
</head>
<body>
<?php include('menu.php') ?>
#child page
</body>
</html>
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
