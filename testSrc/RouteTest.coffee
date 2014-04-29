{TestCase}= require "beast-test"
{PHPRouteBuilder}= require "../lib/Application.js"


new (class RouteTest extends TestCase
  constructor:->
    super()


  base:->
    new PHPRouteBuilder("demo/routebuilder/routes.json")

  testRouteBuilder:(builder)->
    builder.export("demo/application/routes.json")


)