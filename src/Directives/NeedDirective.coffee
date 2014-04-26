#include Directive.coffee

class NeedDirective extends Directive
	constructor:->
		super("need","[^\s\r\n]+")

exports.NeedDirective=NeedDirective