{LineReaderSync}=require "../bin/LineReaderSync.js"
{TestCase,TestResult}=require("beast-test")


new class testLRClass extends TestCase
  constructor:->
    super()

  base:->
    new LineReaderSync("./sample.txt")

  testReadLine:(lr)->
    @assertTrue(lr.hasNext())
    @assertEquals(lr.readLine(),"this is some sample text")
    @assertTrue(lr.hasNext())
    @assertEquals(lr.readLine(),"this is some more on line two")
    @assertEquals(lr.hasNext(),false)


console.log TestCase.getResult()


