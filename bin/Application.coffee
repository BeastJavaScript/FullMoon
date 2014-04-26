









fs= require "fs"
{MegaFile}=require "mega-reader"

class FileManager
  constructor:(@filename,@callback=null,@stack)->
    @mr= new MegaFile([@filename])
    @tools=[]
    @needed=[]
    @section=[]
    @child=[]
    @buildtools()
    @analyze()

  repeat:null

  needed:null

  parent:null

  section:null

  name:null

  child:null

  renderline:null

  analyze:->
    file=fs.readFileSync(@filename,{encoding:"utf8"})
    if (new RenderDirective).canHandle(file)
      @render=true

    if (rd=new RepeatDirective).canHandle(file)
      @repeat=rd.getDirective(file).value

    if (nd=new NeedDirective).canHandle(file)
      @needed.push nd.getDirective(file).value

    if (pd=new ParentDirective).canHandle(file)
      @parent=pd.getDirective(file).value

    if (sd=new SectionDirective).canHandle(file)
      @section.push sd.getDirective(file).value

    if (named=new NameDirective).canHandle(file)
      @name = named.getDirective(file).value

    if (cd=new ChildDirective).canHandle(file)
      @child.push cd.getDirective(file).value

    @callback.call()

  build:(callback)->
    if @render
      @buildRenderLine()
    callback.call()

  buildRenderLine:->
    process.output.debug "building renderline"
    @renderline = new RenderLine(@name,@stack)
    item=@
    while true
      unless item
        break
      @renderline.unshift(item)
      item=item.getParent()
    @renderline.render()


  toString:()->
    obj=
      name:@name
      parent:@parent
      needed:@needed
      sections:@section
      repeat:@repeat
      render:@render
      child:@child

    JSON.stringify(obj,undefined,2)







  buildtools:->
    for tool in [new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective]
      @tools.push tool


  getParent:()->
    unless @parent
      return @parent

    for fm in @stack when fm.name is @parent
      return fm
class Directive
    constructor:(@symbol,@input=null,@parent=null)->
        if @constructor is Directive
            throw new Error("Class Directive is an Abstract Class")
        @static=@constructor
        unless @input is null
          @static.regex ?= new RegExp("##{@symbol} #{@input}")
        else
          @static.regex ?= new RegExp("##{@symbol}")



    canHandle:(text)->
        if (result=@static.regex.exec(text)) isnt null
            return true
        else
            return false

    getDirective:(text)->
        result=@static.regex.exec(text)
        string=result[0]
        stringSplit=string.split(" ")
        key=stringSplit.shift()
        value=stringSplit.join(" ")
        obj= key:key, value:value
        return obj


exports.Directive=Directive


class CustomDirective extends Directive
  constructor:(symbol,input)->
    super(symbol,input)
    unless @input is null
      @static=@
      @static.regex = new RegExp("##{@symbol} #{@input}")
    else
      @static.regex = new RegExp("##{@symbol}")

exports.CustomDirective=CustomDirective


class StopDirective extends Directive
  constructor:->
    super("stop")

exports.StopDirective=StopDirective


class ChildDirective extends Directive
  constructor:->
    super("child","[^\s\r\n]+")

exports.ChildDirective=ChildDirective


class NameDirective extends Directive
  constructor:->
    super("name","[^\s\r\n]+")

exports.NameDirective=NameDirective


class RenderDirective extends Directive
  constructor:->
    super("render")

exports.RenderDirective=RenderDirective


class SectionDirective extends Directive
  constructor:->
    super("section","[^\s\r\n]+")

exports.SectionDirective=SectionDirective


class RepeatDirective extends Directive
  constructor:->
    super("repeat","[0-9]+")

exports.RepeatDirective=RepeatDirective


class ParentDirective extends Directive
	constructor:->
		super("parent","[^\s\r\n]+")

exports.ParentDirective=ParentDirective


class NeedDirective extends Directive
	constructor:->
		super("need","[^\s\r\n]+")

exports.NeedDirective=NeedDirective


fs=require "fs"
{MegaFile}= require "mega-reader"
async= require "async"
mkdirp= require "mkdirp"
path= require "path"
os= require "os"

class RenderLine
  constructor:(@name,@stack)->
    process.output.debug "renderline #{@name} created"
    @path="./preview"
    @line=[]



  clear:->
    @position=-1
    @tools=[]
    @readers=[]

  buildReaders:->
    for file in @line
      @readers.push(new MegaFile([file.filename]))

  buildtools:->
    for tool in [new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective,new NameDirective,new ChildDirective,new RenderDirective,new StopDirective]
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
    unless fs.existsSync(@path)
      mkdirp.sync(@path)
    fs.openSync(@previewFile(),"w")

  previewFile:->
    "#{@path}#{path.sep}#{@name}.html"


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

      if reader.hasNextLine()
        unless stop
          continue

      console.log "rendering #{reader.files}"
      console.log repeat

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






fs = require('fs')
Log = require('log')
process.output = new Log('debug', fs.createWriteStream('my.log'))
