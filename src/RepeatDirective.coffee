#include Directive.coffee

class RepeatDirective extends Directive
  constructor:->
    super("parent","[^ ]+")

exports.RepeatDirective=RepeatDirective