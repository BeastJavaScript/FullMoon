#include Directive.coffee

class ParentDirective extends Directive
	constructor:->
		super("parent","[^ ]+")

exports.ParentDirective=ParentDirective