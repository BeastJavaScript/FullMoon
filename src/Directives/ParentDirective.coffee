#include Directive.coffee

class ParentDirective extends Directive
	constructor:->
		super("parent","[^\s\r\n]+")

exports.ParentDirective=ParentDirective