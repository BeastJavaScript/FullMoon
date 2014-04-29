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
{TestCase}=require "beast-test"
{DirectoryManager}= require "../lib/Application.js"
async=require "async"

new (class TestDirectoryManager extends TestCase
  constructor:->
    super()

  base:->
    new DirectoryManager()

  testReadingFiles:(dm)->
    async.series(
      [
        (callback)->
          process.output.debug "starting to load directory"
          allFileLoadedandParsed = (err)->
            process.output.debug "allfiledloadedandparse has been called"
            callback.call()
            process.output.debug "all files loaded and parsed"
          dm.loadFiles("demo/viewbuilder","demo/preview","html$","^(node_modules|\\.)",allFileLoadedandParsed)
      ,
        (callback)=>
          @assertTrue(dm.files.length>0)
          callback.call()
          process.output.debug(dm)

      ]
      ,
      ()=>
        console.log "needed to be printed here because of async task that finished later"
        console.log TestCase.getResult()
    )


  testViewBuilder:(dm)->
    async.series(
      [
        (callback)->
          dm.buildView("demo/viewbuilder","demo/application/app/view","html$",null,callback)
      ]
    )


)

{TestCase} = require "beast-test"
{SectionDirective}= require "../lib/Application.js"

new (class SectionDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new SectionDirective("fake","fake")

  testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#section parent section"))
)
{TestCase} =require "beast-test"
{RepeatDirective}= require "../lib/Application.js"

new (class RepeatDirectiveTest extends TestCase
  constructor:->
    super()

  base:->
    d=new RepeatDirective

  testAbstractClass:(obj)->
    @assertNotNull(obj)
    @assertTrue(obj.canHandle("#repeat 4"))
    @assertTrue(!obj.canHandle("#repe 4"))
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
    @assertTrue(obj.canHandle("#parent content"))
)
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
