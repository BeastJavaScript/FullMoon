#include Directive.coffee

class NeedDirective extends Directive
	constructor:->
		super("need","[^ \r\n]+")

exports.NeedDirective=NeedDirective