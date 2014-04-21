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
{TestCase} =require "beast-test"
{RepeatDirective}= require "../lib/Application.js"

new (class RepeatDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new RepeatDirective("fake","fake")

  testAbstractClass:(obj)->
    @assertNotNull(obj)
)
{TestCase} =require "beast-test"
{ParentDirective}= require "../lib/Application.js"

new (class ParentDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new ParentDirective("fake","fake")

  testAbstractClass:(obj)->
    @assertNotNull(obj)
)
{TestCase} =require "beast-test"
{NeedDirective}= require "../lib/Application.js"

new (class TestNeedDirectiveTest extends TestCase
	constructor:->
    super()

	base:->
		d=new NeedDirective("fake","fake")

	testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#need content"))
)
{TestCase}= require "beast-test"
{Directive}= require "../lib/Application.js"


new (class TestDirective extends TestCase
	constructor:->
    super()

	base:->
		try 
			d=new Directive("fake","fake")
		catch e
			return e
		return d

	testAbstractClass:(obj)->
		@assertEquals(obj.message,"Class Directive is an Abstract Class")
)







console.log TestCase.getResult()
