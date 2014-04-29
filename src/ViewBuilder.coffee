#include Directives/DirectiveLoader.coffee

path= require "path"
mkdirp= require "mkdirp"
{MegaFile}= require "mega-reader"
class ViewBuilder
  constructor:(@filename,@name,@bin,@ext,@stack)->
    @mr= new MegaFile([@filename])
    @mr.reset()
    @tools=[]
    @buildtools()
    @export();

  export:->
    unless fs.existsSync(@bin)
      mkdirp(@bin)
    fs.writeFileSync(@file(),"");

    while true
      if @mr.hasNextLine()
        @print(@mr.getNextLine())
      else
        break

  print:(line)->
    t=@canHandle(line)
    if t
      if t instanceof NeedDirective
        line= "<?php include('#{t.getDirective(line).value}.#{@ext}') ?>"
    fs.appendFileSync(@file(),"#{line}\n")


  canHandle:(line)->
    for t in @tools when t.canHandle(line)
      return t
    return false




  buildtools:->
    for tool in [new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective,new NameDirective,new ChildDirective,new RenderDirective,new StopDirective]
      @tools.push tool



  file:->
    file= path.resolve(@bin,"#{@name}.#{@ext}")

