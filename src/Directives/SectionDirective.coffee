#include Directive.coffee

class SectionDirective extends Directive
  constructor:->
    super("section","[^\s\r\n]+")

exports.SectionDirective=SectionDirective