{TestCase} = require "beast-test"
{SectionDirective}= require "../bin/index.js"

new (class SectionDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new SectionDirective("fake","fake")

  testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#section parent section"))
)