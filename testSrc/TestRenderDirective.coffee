{TestCase} =require "beast-test"
{RenderDirective}= require "../bin/index.js"

new (class RenderDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new RenderDirective

  testRenderDirective:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#render"))
)