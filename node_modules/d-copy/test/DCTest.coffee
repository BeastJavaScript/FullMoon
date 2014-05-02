DirectoryCopy = require("../lib/application.js").DirectoryCopy

TestCase = require("beast-test").TestCase

new (class DCTest extends TestCase
  constructor:->
    super()

  base:->
    new DirectoryCopy("source","destination",true)

  testDC:(dc)->
    dc.getFiles();
)

console.log TestCase.getResult();

