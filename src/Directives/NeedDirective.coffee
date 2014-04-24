#include Directive.coffee

class NeedDirective extends Directive
	constructor:->
		super("need","[^ ]+")

exports.NeedDirective=NeedDirective