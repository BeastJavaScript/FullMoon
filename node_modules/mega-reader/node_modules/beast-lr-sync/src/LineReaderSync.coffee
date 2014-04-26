fs= require "fs"
class LineReaderSync
  constructor:(path)->
    @path=path
    @file=fs.openSync(@path,"r")
    @line=new Buffer(1024)
    @buffer_size=0
    @position=0
    @finish=false

  hasNext:->
    unless @finish
      return true
    else
      return false


  read:->
    fs.readSync(@file,@line,@buffer_size++,1,@position++)
  readLine:->
    while true
      @read()
      break if (char=@line[@buffer_size-1]) is 0 or char is 13
    if char is 0
      @finish=true
    string=@line.slice(0,@buffer_size).toString()[0...-1]
    @clear()
    string
  clear:->
    @line.fill(0,0,@buffer_size)
    @buffer_size=0
    @position++

module.exports.LineReaderSync=LineReaderSync

