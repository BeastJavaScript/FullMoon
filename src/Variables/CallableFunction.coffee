#include Placeholder.coffee
class CallableFunction extends Placeholder
  constructor:->
    super("{{exec\\*(.*)\\* ?([^}]*)}}","<?php echo $1 ?>","$2")

exports.Variable=Variable