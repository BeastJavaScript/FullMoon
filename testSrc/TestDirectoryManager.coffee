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
)
