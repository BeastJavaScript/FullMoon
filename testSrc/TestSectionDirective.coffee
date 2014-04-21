{TestCase} = require "beast-test"
{SectionDirective}= require "../lib/Application.js"

new (class SectionDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new SectionDirective("fake","fake")

  testAbstractClass:(obj)->
    @assertNotNull(obj)
)