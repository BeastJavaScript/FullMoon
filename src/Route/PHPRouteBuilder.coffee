#include RouteBuilder.coffee
class PHPRouteBuilder extends RouteBuilder
  constructor:(file)->
    super(file)

  object:(object)->
    str=JSON.stringify(object)
    console.log str




exports.PHPRouteBuilder=PHPRouteBuilder