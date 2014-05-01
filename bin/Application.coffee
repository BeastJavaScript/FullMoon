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



















class Placeholder
  constructor:(@match,@replacement,@preview)->
    @static=@constructor
    @static.regex ?= new RegExp(@match)
    @static.regexR ?= new RegExp(@match,"g")

  canHandle:(text)->
    @static.regex.exec(text) isnt null;

  getReplacement:(text)->
    text.replace(@static.regexR,@replacement,text)


  getPreviewReplacement:(text)->
    text.replace(@static.regexR,@preview,text)



exports.Placeholder=Placeholder


class Asset extends Placeholder
  constructor:->
    super("{{ *?asset[*](.*?)[*] *?}}","<?php echo assets(\"$1\") ?>","../application/assets/$1")

exports.Asset=Asset

class EndForEach extends Placeholder
  constructor:->
    super("@endforeach","<?php endforeach; ?>","")

exports.EndForEach=EndForEach

class ForEach extends Placeholder
  constructor:->
    super("@foreach\\((.*)\\)","<?php foreach$1: ?>","")

exports.ForEach=ForEach

class EndIf extends Placeholder
  constructor:->
    super("@endif","<?php endif; ?>","")

exports.EndIf=EndIf

class If extends Placeholder
  constructor:->
    super("@if\\((.+)\\)","<?php if($1): ?>","")

exports.If=If

class CallableFunction extends Placeholder
  constructor:->
    super("{{exec\\*(.*)\\* ?([^}]*)}}","<?php echo $1 ?>","$2")

exports.Variable=Variable

class Variable extends Placeholder
  constructor:->
    super("{{ ?([^@ ]+) ?([^}]*?)}}","<?php echo $$$1 ?>","$2")

exports.Variable=Variable

class Placeholder
  constructor:(@match,@replacement,@preview)->
    @static=@constructor
    @static.regex ?= new RegExp(@match)
    @static.regexR ?= new RegExp(@match,"g")

  canHandle:(text)->
    @static.regex.exec(text) isnt null;

  getReplacement:(text)->
    text.replace(@static.regexR,@replacement,text)


  getPreviewReplacement:(text)->
    text.replace(@static.regexR,@preview,text)



exports.Placeholder=Placeholder




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
    @print("<?php ini_set('error_reporting', 0);?>")
    while true
      if @mr.hasNextLine()
        @print(@mr.getNextLine())
      else
        @print(
              """
               <?php
               if(isset($renderstack) && count($renderstack)>0){
                  $last=&array_pop($renderstack);
                  foreach($last->sections as $key=>$value){
                    $last->parent=str_replace("#child ".$key, $value, $last->parent);
                  }
               }
                echo $last->parent;
                unset($last)
               ?>
              """
        )
        break

  print:(line)->
    t=@canHandle(line)
    if t
      if t instanceof NeedDirective
        line= "<?php include('#{t.getDirective(line).value}.#{@ext}') ?>"
      if t instanceof RenderDirective or t instanceof RepeatDirective or t instanceof NameDirective
        line=""
        return
      if t instanceof ParentDirective
        parentname= t.getDirective(line).value
        line="""
            <?php
              $renderstack[]= new stdClass();
              ob_start();
              include("#{parentname}.#{@ext}");
              $last=&$renderstack[count($renderstack)-1];
              $last->parent=ob_get_clean();
              $last->sections=[];
            ?>
            """

      if t instanceof SectionDirective
        @sectionName= t.getDirective(line).value
        line= """
              <?php ob_start();?>
              """
      if t instanceof StopDirective
        sectionName=@sectionName
        delete @sectionName
        line= """
              <?php
                $section_buffer=ob_get_clean();
                $last->sections['#{sectionName}']=$section_buffer
              ?>
              """
      if t instanceof Variable or t instanceof CallableFunction or t instanceof If or t instanceof EndIf or t instanceof ForEach or t instanceof EndForEach or t instanceof Asset
        line= t.getReplacement line


    fs.appendFileSync(@file(),"#{line}#{os.EOL}")


  canHandle:(line)->
    for t in @tools when t.canHandle(line)
      return t
    return false




  buildtools:->
    for tool in [new Asset,new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective,new NameDirective,new ChildDirective,new RenderDirective,new StopDirective,new CallableFunction,new Variable,new If,new EndIf]
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
    super("child","[^ \r\n]+")

exports.ChildDirective=ChildDirective


class NameDirective extends Directive
  constructor:->
    super("name","[^ \r\n]+")

exports.NameDirective=NameDirective


class RenderDirective extends Directive
  constructor:->
    super("render")

exports.RenderDirective=RenderDirective


class SectionDirective extends Directive
  constructor:->
    super("section","[^ \r\n]+")

exports.SectionDirective=SectionDirective


class RepeatDirective extends Directive
  constructor:->
    super("repeat","[0-9]+")

exports.RepeatDirective=RepeatDirective


class ParentDirective extends Directive
	constructor:->
		super("parent","[^ \r\n]+")

exports.ParentDirective=ParentDirective


class NeedDirective extends Directive
	constructor:->
		super("need","[^ \r\n]+")

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
    .option("-v, --viewbuild","Flag used to build preview file")
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


    if program.viewbuild
      @viewBuild()


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


  viewBuild:->
    dm= new DirectoryManager()
    program=@program
    basedir=@basedir
    config= @config


    match=config.view.extension.match
    if match is ""
      match=null

    exclude=config.view.extension.exclude
    if exclude is ""
      exclude=null

    viewbuilder=path.resolve basedir,config.path.viewbuilder
    viewpath= path.resolve basedir,config.path.view

    dm.buildView(viewbuilder,viewpath,match,exclude,->)




  @getInstance:->
    if typeof CommandLine.interface is "undefined"
      CommandLine.interface = new CommandLine(process.argv)
    CommandLine.interface

exports.CommandLine=CommandLine














fs = require('fs')
Log = require('log')
process.output = new Log('debug', fs.createWriteStream('my.log'))
