#include Placeholder.coffee
class Variable extends Placeholder
  constructor:->
    super("{{ ?([^@ ]+) ?([^}]*?)}}","<?php echo $$$1 ?>","$2")

exports.Variable=Variable
