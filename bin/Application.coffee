fs=require "fs"

class RouteBuilder
  constructor:(jsonFile)->
    @file=jsonFile
    @load(@file)
    @parseRoute(@routes)

  load:(file)->
    content=fs.readFileSync(file,{encoding:"utf8"})
    @routes= JSON.parse(content)
    @routes

  parseRoute:(settings)->
    parameter= new RegExp("{.*?}","g")
    for route in settings.routes
      param=[]
      while (result=parameter.exec(route.url))
        rawParam=result[0].replace(/({|})/g,"")
        rawParam=rawParam.split(" ")
        param.push(rawParam)
      match=route.url
      for p in param
        if p.length is 1
          p.push("[^/]+")
        match=match.replace(new RegExp("{ ?#{p[0]}.*?}"),"(#{p[1]})")
      route.match=match

  export:(file)->
    @routes
    fs.writeFile(file,JSON.stringify(@routes,null,2))

    


exports.RouteBuilder=RouteBuilder




class PHPRouteBuilder extends RouteBuilder
  constructor:(file)->
    super(file)

  object:(object)->
    str=JSON.stringify(object)
    console.log str




exports.PHPRouteBuilder=PHPRouteBuilder












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
    if (t=@canHandle(line))
      if t instanceof NeedDirective
        line= "<?php include('#{@file()}') ?>"
    console.log line
    fs.appendFileSync(@filename,line)


  canHandle:(line)->
    for t in @tools when t.canHandle(line)
      return t
    return false




  buildtools:->
    for tool in [new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective,new NameDirective,new ChildDirective,new RenderDirective,new StopDirective]
      @tools.push tool



  file:->
    file= path.resolve(@bin,"#{@name}.#{@ext}")




fs= require "fs"
{MegaFile}=require "mega-reader"

class FileManager
  constructor:(@filename,@bin,@stack)->
    @mr= new MegaFile([@filename])
    @mr.reset()
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


  build:(callback)->
    if @render
      @buildRenderLine()
    callback.call()

  buildRenderLine:->
    process.output.debug "building renderline"
    @renderline = new RenderLine(@name,@bin,@stack)
    item=@
    while true
      unless item
        break
      @renderline.unshift(item)
      item=item.getParent()
    @renderline.render()


  export:->
    @vb=new ViewBuilder(@filename,@name,@bin,"php",@stack)

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



async= require "async"

class DirectoryManager
  constructor:(@fileManager)->
    process.output.debug "entering DirectoryManager #{Date.now()}"
    @files=[]
    @dirRead= require('node-dir')

    ###
      bindings
    ###
    @add=@add.bind(@)
    @loadFiles=@loadFiles.bind(@)
    @buildIndex=@buildIndex.bind(@)
    @buildConcreteView=@buildConcreteView.bind(@)

  watchDirectory:->
    #nothing

  exclude:null
  match:null

  loadFiles:(directory,@bin,@match=null,@exclude=null,@loadFileFinished=null)->
    process.output.debug "getting ready to load the files"
    @dirRead.files(directory,@readDirFinished)

  readDirFinished:(err, files)=>
    process.output.debug "we have finished reading the directory and now wish to process the files"

    afterIterator=(file,fileBuilt)=>
      file.build(fileBuilt)

    after= =>
      async.each(@files,afterIterator,@loadFileFinished);
    async.each(files,@buildIndex,after)

  buildIndex:(file,fileProcessed)->
    if @match is null or (new RegExp(@match)).exec(file)
      if @exclude is null or (new RegExp(@exclude)).exec(file) is null
        process.output.debug("moving on to process file #{file}")
        @add(file,@bin)
    fileProcessed.call()


  buildView:(directory,@bin,@match,@exclude,@buildViewFinished)->
    @dirRead.files(directory,@buildConcreteView)

  buildConcreteView:(err,files)->
    process.output.debug "finished reading the directory files for creating the views"
    indexBuilt= =>
      afterIndexed= (file,cb)=>
        file.export(@bin)
        cb.call()

      afterIndexed=afterIndexed.bind(@)
      async.each(@files,afterIndexed,@buildViewFinished)

    indexBuilt=indexBuilt.bind(@)
    console.log typeof @buildIndex
    console.log typeof indexBuilt
    async.each(files,@buildIndex,indexBuilt)



  add:(file,bin)->
    fm=new FileManager(file,bin,@files)
    for f in @files when f.name is fm.name
      return null
    @files.push(fm)


  toString:->
    "[DirectoryManager]"

exports.DirectoryManager=DirectoryManager

fs= require "fs"
path= require "path"

class CommandLine
  constructor:(args)->
    @program= require "commander"

    @program.version("0.0.1")
    .option("-w, --watch","this will watch the directory and re-render files")
    .option("-c, --config [value]","This is the path to the roar.json file with the configuration")
    .option("-r, --route","Build the route file from the route.json in the routebuilder location")
    .option("-p, --preview","Flag used to build preview file")
    .parse(args)

    @program.config ?= "roar.json"
    @basedir=path.resolve(path.dirname(@program.config))
    if fs.existsSync(@program.config)
      @config=JSON.parse(fs.readFileSync(@program.config,{encoding:"utf8"}))
    else
      console.log "#{@program.config} doesn't exist"
      process.exit(0)


    program=@program
    if program.preview
      @preview()

    if program.route
      @routeBuilder()


  config:null


  preview:->
    basedir=@basedir
    config=@config
    viewbuilder=path.resolve basedir,config.path.viewbuilder
    preview=path.resolve basedir, config.path.preview
    input=config.view.extension.input
    exclude=config.view.extension.exclude
    if exclude is ""
      exclude=null

    dm= new DirectoryManager()
    dm.loadFiles(viewbuilder,preview,input,exclude)


  routeBuilder:->
    basedir=@basedir
    config=@config
    routebuilder=path.resolve basedir,config.path.routebuilder,"routes.json"
    exportdir=path.resolve basedir,config.path.application,"routes.json"

    route=new PHPRouteBuilder(routebuilder)
    route.export(exportdir)



  @getInstance:->
    if typeof CommandLine.interface is "undefined"
      CommandLine.interface = new CommandLine(process.argv)
    CommandLine.interface

exports.CommandLine=CommandLine











fs = require('fs')
Log = require('log')
process.output = new Log('debug', fs.createWriteStream('my.log'))
