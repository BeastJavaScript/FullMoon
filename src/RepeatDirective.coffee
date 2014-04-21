#include Directive.coffee

class RepeatDirective extends Directive
  constructor:->
    super("repeat","[0-9]+")

exports.RepeatDirective=RepeatDirective