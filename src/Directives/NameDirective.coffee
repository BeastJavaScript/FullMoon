#include Directive.coffee

class NameDirective extends Directive
  constructor:->
    super("name","[^\s\r\n]+")

exports.NameDirective=NameDirective