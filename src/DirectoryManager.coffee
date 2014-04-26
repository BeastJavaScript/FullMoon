#include FileManager.coffee
async= require "async"

class DirectoryManager
  constructor:(@fileManager)->
    process.output.debug "entering DirectoryManager #{Date.now()}"
    @files=[]
    @dirRead= require('node-dir')
    @add=@add.bind(@)
    @loadFiles=@loadFiles.bind(@)

  watchDirectory:->
    #nothing

  loadFiles:(directory,match=null,exclude=null,loadFileFinished=null)->
    process.output.debug "getting ready to load the files"
    readDirFinished=(err, files)=>
      process.output.debug "we have finished reading the directory and now wish to process the files"
      iterator=(file,fileProcessed)=>
        if match is null or (new RegExp(match)).exec(file)
          if exclude is null or (new RegExp(exclude)).exec(file) is null
            process.output.debug("moving on to process file #{file}")
            @add(file,fileProcessed)
          else
            fileProcessed.call()
        else
          fileProcessed.call()

      iterator= iterator.bind(@)


      afterIterator=(file,fileBuilt)=>
        file.build(fileBuilt)

      after= =>
        async.each(@files,afterIterator,loadFileFinished);

      async.each(files,iterator,after)

    readDirFinished=readDirFinished.bind(@)
    @dirRead.files(directory,readDirFinished)


  add:(file,callback)->
    @files.push(new FileManager file,callback,@files)

  toString:->
    "[DirectoryManager]"

exports.DirectoryManager=DirectoryManager
