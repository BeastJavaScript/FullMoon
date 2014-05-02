path= require "path"
fs= require "fs"
mkdirp= require "mkdirp"

class DirectoryCopy
  constructor:(@input,@output,verbose=false)->
    @message=""
    @reader= require "node-dir"
    @base=path.resolve(@input)
    console.log "base is now #{@base}"
    `debugger`


  getFiles:->
    `debugger`
    reader=require "node-dir"
    base=@base
    input=@input
    output=@output
    writeFiles= (input,output)->
      `debugger`
      fs.readFile(input,{encoding:"utf8"},(err,data)->
        if err
          console.log "we have an error"
        else
          console.log "no error processing #{input} to #{output}"
        if typeof data is "undefined"
          data="";
        console.log()
        mkdirp(path.dirname(output),->
          fs.writeFile(output,data,null,->
            console.log("file saved, #{output}")
          )
        )
      );

    reader.files(@base,(err,files)->
      `debugger`
      console.log "got the files and the length is #{files.length}"
      for f in files
        console.log "processing #{f}"
        fp=path.relative(input,f)
        console.log "the file is #{fp}"
        input=path.resolve(base,f)
        output=path.resolve(process.cwd(),output,fp)
        console.log "we are moving from #{input} to #{output}"
        writeFiles(input,output)
    )

  log:(text)->
    @message+="#{text}\n";



exports.DirectoryCopy=DirectoryCopy