{TestCase} =require "beast-test"
{ParentDirective}= require "../bin/index.js"

new (class ParentDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new ParentDirective("fake","fake")

  testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#parent content"))
)