{TestCase} =require "beast-test"
{RepeatDirective}= require "../lib/Application.js"

new (class RepeatDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new RepeatDirective

  testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#repeat 4"))
    @assertTrue(!obj.canHandle("#repe 4"))
)