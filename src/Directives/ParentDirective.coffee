#include Directive.coffee

class ParentDirective extends Directive
	constructor:->
		super("parent","[^ \r\n]+")

exports.ParentDirective=ParentDirective