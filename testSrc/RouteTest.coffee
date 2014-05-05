{TestCase}= require "beast-test"
{PHPRouteBuilder}= require "../bin/index.js"


new (class RouteTest extends TestCase
  constructor:->
    super()


  base:->
    new PHPRouteBuilder("demo/routebuilder/routes.json")

  testRouteBuilder:(builder)->
    builder.export("demo/application/routes.json")


)