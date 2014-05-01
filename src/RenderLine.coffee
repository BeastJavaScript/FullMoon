#include Directives/DirectiveLoader.coffee
#include Variables/PlaceholderLoader.coffee

fs=require "fs"
{MegaFile}= require "mega-reader"
async= require "async"
mkdirp= require "mkdirp"
path= require "path"
os= require "os"

class RenderLine
  constructor:(@name,@bin,@stack)->
    process.output.debug "renderline #{@name} created"
    @line=[]

  clear:->
    @position=-1
    @tools=[]
    @readers=[]

  buildReaders:->
    for file in @line
      @readers.push(new MegaFile([file.filename]))

  buildtools:->
    for tool in [new Asset,new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective,new NameDirective,new ChildDirective,new RenderDirective,new StopDirective,new CallableFunction,new Variable,new If,new EndIf,new ForEach,new EndForEach]
      @tools.push tool

  shift:()->
    @line.shift()

  unshift:(item)->
    @line.unshift(item)

  push:(item)->
    @line.push(item)

  pop:(item)->
    @line.pop(item)

  position:null

  internalLine:(text)->
    value=null
    for tool in @tools
      if tool.canHandle(text)
        value=tool
        break;
    value


  makefile:->
    unless fs.existsSync(@bin)
      mkdirp.sync(@bin)
    fs.openSync(@previewFile(),"w")

  previewFile:->
    "#{@bin}#{path.sep}#{@name}.html"


  printFile:(file,reader,repeat=1)->
    while true
      process.output.debug "--------------------------------"
      process.output.debug "#{repeat},#{reader.files}"

      stop=false
      if reader.hasNextLine()
        line = reader.getNextLine()
        process.output.debug "#{line}"
        directive=@internalLine(line)
        unless directive
          fs.writeSync(file,"#{line}#{os.EOL}")
        else if directive instanceof ChildDirective
          @printChild(file,directive.getDirective(line))
        else if directive instanceof NeedDirective
          @printNeed(file,directive.getDirective(line).value)
        else if directive instanceof StopDirective
           stop=true
        else if directive instanceof Asset or directive instanceof Variable or directive instanceof CallableFunction or directive instanceof If or directive instanceof EndIf or directive instanceof ForEach  or directive instanceof EndForEach
            fs.writeSync(file,"#{directive.getPreviewReplacement(line)}#{os.EOL}    ")

      if reader.hasNextLine()
        unless stop
          continue

      if repeat>0
        reader.reset()
        repeat--

      if repeat<=0
        break
    process.debug=off

  printRenderFile:(file)->
    @position++
    repeat=@line[@position].repeat
    reader=@readers[@position]
    @printFile(file,reader,repeat)
    @position--


  printChild:(file,secDirective)->
    @position++
    reader=@readers[@position]
    reader.reset()
    cd= new CustomDirective(secDirective.key.replace("#child","section"),secDirective.value)
    process.output.debug "#{JSON.stringify(secDirective)}"
    while true
      if reader.hasNextLine()
        line=reader.getNextLine()
        unless cd.canHandle(line)
          continue
      break
    @position--
    @printRenderFile(file)


  printNeed:(file,need)->
    reader=null
    for f in @stack when f.name is need
      reader=f
      break
    @printFile(file,new MegaFile([reader.filename]),reader.repeat)



  render:->
    @clear()
    @buildtools()
    @buildReaders()
    file=@makefile()
    @printRenderFile(file)
    fs.closeSync(file)

  toString:->
    obj=[]
    for l in @line
      obj.push(l.toString())
    str=obj.join ",\n"
    str




exports.RenderLine=RenderLine

