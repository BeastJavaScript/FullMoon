{TestCase} =require "beast-test"
{NeedDirective}= require "../lib/Application.js"

new class TestNeedDirective extends TestCase
	constructor:->
		super()

	base:->
		d=new NeedDirective("fake","fake")

	testAbstractClass:(obj)->
		@assertNotNull(obj)
