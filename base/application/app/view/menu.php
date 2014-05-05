<?php ini_set('error_reporting', 0);?>
<nav>
    <ul>
        <li>Home</li>
        <li>Contact</li>
        <li>About</li>
    </ul>
</nav>
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
