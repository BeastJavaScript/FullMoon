{TestCase}= require "beast-test"
{Directive}= require "../bin/index.js"


new (class TestDirective extends TestCase
	constructor:->
    super()

	base:->
		try 
			d=new Directive("fake","fake")
		catch e
			return e
		return d

	testAbstractClass:(obj)->
		@assertEquals(obj.message,"Class Directive is an Abstract Class")
)