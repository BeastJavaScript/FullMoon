{TestCase}= require "beast-test"
{Variable}= require "../bin/index.js"

new (class PlaceholderTest extends TestCase
  constructor:->
    super()

  base:->
    new Variable()


  testVariable:(v)->
    text="{{hello blah blah}}"
    @assertTrue(v.canHandle(text))
    @assertEquals(v.getReplacement(text),"<?php echo $hello ?>")
    @assertEquals(v.getPreviewReplacement(text),"blah blah")
)