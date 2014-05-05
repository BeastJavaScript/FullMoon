{TestCase} =require "beast-test"
{NeedDirective}= require "../bin/index.js"

new (class TestNeedDirectiveTest extends TestCase
	constructor:->
    super()

	base:->
		d=new NeedDirective("fake","fake")

	testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#need content"))
)