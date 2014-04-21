#include Directive.coffee

class SectionDirective extends Directive
  constructor:->
    super("parent","[^ ]+")

exports.SectionDirective=SectionDirective