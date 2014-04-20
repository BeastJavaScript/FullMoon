{TestCase,TestResult} = require "beast-test"
{Trigger} = require "../bin/trigger"
new class TestTrigger extends TestCase
  constructor:->
    super()

  base:->
    Trigger.getInstance()

  testObject:(master)->
    @assertTrue(master instanceof Trigger)
    @assertSame(Trigger.getInstance(),Trigger.getInstance())
    @assertEquals(master.trigger,[])

  testTrigger:(master)->
    master.addListener("testing",->
      process.trigger_fire ?= 0
      process.trigger_fire++
    )

    master.trigger("testing")
    @assertEquals(process.trigger_fire,1)
    master.trigger("testing")
    master.trigger("testing")
    @assertEquals(process.trigger_fire,3)

console.log TestCase.getResult()