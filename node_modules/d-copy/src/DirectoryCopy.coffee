path= require "path"
fs= require "fs"
mkdirp= require "mkdirp"

class DirectoryCopy
  constructor:(@input,@output,verbose=false)->
    @message=""
    @reader= require "node-dir"
    @base=path.resolve(@input)
    console.log "base is now #{@base}"


  getFiles:->
    reader=require "node-dir"
    base=@base
    input=@input
    output=@output
    writeFiles= (input,output)->
      debugger
      fs.readFile(input,{encoding:"utf8"},(err,data)->
        if typeof data is "undefined"
          data="";
        mkdirp(path.dirname(output),->
          fs.writeFile(output,data,null,->
            console.log("file created, #{output}")
          )
        )
      );

    callback=(err,files)->
      for f in files
        fp=path.relative(input,f)
        input=path.resolve(base,f)
        output=path.resolve(process.cwd(),output,fp)
        writeFiles(input,output)
    reader.files(@base, callback);

  log:(text)->
    @message+="#{text}\n";


exports.DirectoryCopy=DirectoryCopy