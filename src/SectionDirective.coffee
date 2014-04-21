#include Directive.coffee

class SectionDirective extends Directive
  constructor:->
    super("section","[^ ]+")

exports.SectionDirective=SectionDirective