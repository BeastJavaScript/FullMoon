{TestCase} =require "beast-test"
{RepeatDirective}= require "../lib/Application.js"

new (class RepeatDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new RepeatDirective("fake","fake")

  testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#repeat 4"))
)