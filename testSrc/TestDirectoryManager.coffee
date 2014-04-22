{TestCase}=require "beast-test"
{DirectoryManager}= require "../lib/Application.js"

new (class TestDirectoryManager extends TestCase
  constructor:->
    super()

  base:->
    new DirectoryManager()

  testReadingFiles:(dm)->
    dm.loadFiles("./",null,"^(node_modules|\\.)")
    @assertTrue(dm.files.length>0)
)