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
          console.log "reading the files"
          dm.loadFiles("./",null,"^(node_modules|\\.)",callback)
      ,
        (callback)=>
          console.log "asserting true"
          @assertTrue(dm.files.length>0)
          callback.call()
      ]
      ,
      ()=>
        console.log "needed to be printed here because of async task that finished later"
        console.log TestCase.getResult()
    )
)