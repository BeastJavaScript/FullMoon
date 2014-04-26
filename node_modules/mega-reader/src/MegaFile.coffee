{LineReaderSync}=require("beast-lr-sync")
fs=require "fs"
class MegaFile
  constructor:(@files)->
    @position=0
    @reader=null

  getNextLine:->
    @reader.readLine()

  hasNextLine:->
    if (@reader is null or not @reader.hasNext()) and @hasNextFile()
      @updateReader()

    if @reader.hasNext()
      return true
    else
      @hasNextFile()

  updateReader:->
    @reader=new LineReaderSync(@getFile())

  file:->
    if typeof @files[@position] is "string"
      return @files[@position]
    else
      return null

  getFile:->
    file=@file()
    @position++
    file

  hasNextFile:->
    if @file()
      file=@file()
      if (stat=fs.statSync(file)) and stat.isFile()
        return true
    else false

  reset:->
    @position=0
    @reader=null


module.exports.MegaFile=MegaFile
