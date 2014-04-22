class DirectoryManager
  constructor:(@fileManager)->
    @that=@
    @files=[]
    @dirRead= require('node-dir')
    @add=@add.bind(@)
    @loadFiles=@loadFiles.bind(@)

  watchDirectory:->
    #nothing

  loadFiles:(directory,match=null,exclude=null)->
    callback=(err, files)->
      for file in files
        if match is null or (new RegExp(match)).exec(file)
          if exclude is null or (new RegExp(exclude)).exec(file) is null
            @add(file)
    callback=callback.bind(@)
    @dirRead.files(directory,callback)


  add:(file)->
    @files.push file


exports.DirectoryManager=DirectoryManager