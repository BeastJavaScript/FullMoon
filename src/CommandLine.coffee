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

    program=@program

    if program.args[0] is "generate"
      if program.args.length>1
        folder=program.args[1]
      else
        folder="."
      @generate(folder)
    else
      program.config ?= "roar.json"
      @basedir=path.resolve(path.dirname(program.config))
      if fs.existsSync(program.config)
        @config=JSON.parse(fs.readFileSync(program.config,{encoding:"utf8"}))



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


  generate:(folder)->
    dcopy=require("d-copy").DirectoryCopy
    base=path.resolve(__dirname,"../base")
    dest=path.resolve(process.cwd(),folder);
    d= new dcopy(base,dest);
    d.getFiles()

  @getInstance:->
    if typeof CommandLine.interface is "undefined"
      CommandLine.interface = new CommandLine(process.argv)
    CommandLine.interface

exports.CommandLine=CommandLine