#include Directive.coffee

class ChildDirective extends Directive
  constructor:->
    super("child","[^ \r\n]+")

exports.ChildDirective=ChildDirective