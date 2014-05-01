#include Directive.coffee

class SectionDirective extends Directive
  constructor:->
    super("section","[^ \r\n]+")

exports.SectionDirective=SectionDirective