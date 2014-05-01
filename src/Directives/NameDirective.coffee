#include Directive.coffee

class NameDirective extends Directive
  constructor:->
    super("name","[^ \r\n]+")

exports.NameDirective=NameDirective