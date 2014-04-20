


{TestCase} =require "beast-test"
{NeedDirective}= require "../lib/Application.js"

new class TestNeedDirective extends TestCase
	constructor:->
		super()

	base:->
		d=new NeedDirective("fake","fake")

	testAbstractClass:(obj)->
		@assertNotNull(obj)

{TestCase}= require "beast-test"
{Directive}= require "../lib/Application.js"


new class TestDirective extends TestCase
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








console.log TestCase.getResult()
