#include Directive.coffee

class ChildDirective extends Directive
  constructor:->
    super("child","[^\s\r\n]+")

exports.ChildDirective=ChildDirective