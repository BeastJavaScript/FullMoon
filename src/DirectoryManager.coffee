#include FileManager.coffee
async= require "async"

class DirectoryManager
  constructor:(@fileManager)->
    process.output.debug "entering DirectoryManager #{Date.now()}"
    @files=[]
    @dirRead= require('node-dir')

    ###
      bindings
    ###
    @add=@add.bind(@)
    @loadFiles=@loadFiles.bind(@)
    @buildIndex=@buildIndex.bind(@)
    @buildConcreteView=@buildConcreteView.bind(@)

  watchDirectory:->
    #nothing

  exclude:null
  match:null

  loadFiles:(directory,@bin,@match=null,@exclude=null,@loadFileFinished=null)->
    process.output.debug "getting ready to load the files"
    @dirRead.files(directory,@readDirFinished)

  readDirFinished:(err, files)=>
    process.output.debug "we have finished reading the directory and now wish to process the files"

    afterIterator=(file,fileBuilt)=>
      file.build(fileBuilt)

    after= =>
      async.each(@files,afterIterator,@loadFileFinished);
    async.each(files,@buildIndex,after)

  buildIndex:(file,fileProcessed)->
    if @match is null or (new RegExp(@match)).exec(file)
      if @exclude is null or (new RegExp(@exclude)).exec(file) is null
        process.output.debug("moving on to process file #{file}")
        @add(file,@bin)
    fileProcessed.call()


  buildView:(directory,@bin,@match,@exclude,@buildViewFinished)->
    @dirRead.files(directory,@buildConcreteView)

  buildConcreteView:(err,files)->
    process.output.debug "finished reading the directory files for creating the views"
    indexBuilt= =>
      afterIndexed= (file,cb)=>
        file.export(@bin)
        cb.call()

      afterIndexed=afterIndexed.bind(@)
      async.each(@files,afterIndexed,@buildViewFinished)

    indexBuilt=indexBuilt.bind(@)
    console.log typeof @buildIndex
    console.log typeof indexBuilt
    async.each(files,@buildIndex,indexBuilt)



  add:(file,bin)->
    fm=new FileManager(file,bin,@files)
    for f in @files when f.name is fm.name
      return null
    @files.push(fm)


  toString:->
    "[DirectoryManager]"

exports.DirectoryManager=DirectoryManager
