{TestCase} =require "beast-test"
{RenderDirective}= require "../lib/Application.js"

new (class RenderDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new RenderDirective

  testRenderDirective:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#render"))
)