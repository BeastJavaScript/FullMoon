class DirectoryManager
  constructor:(@fileManager)->
    @that=@
    @files=[]
    @dirRead= require('node-dir')
    @add=@add.bind(@)
    @loadFiles=@loadFiles.bind(@)

  watchDirectory:->
    #nothing

  loadFiles:(directory,match=null,exclude=null,callback2=null)->
    callback=(err, files)->
      for file in files
        if match is null or (new RegExp(match)).exec(file)
          if exclude is null or (new RegExp(exclude)).exec(file) is null
            @add(file)
      if callback2 isnt null
        callback2.call()
    callback=callback.bind(@)
    @dirRead.files(directory,callback)


  add:(file)->
    @files.push file

  toString:->
    "[DirectoryManager]"



exports.DirectoryManager=DirectoryManager
