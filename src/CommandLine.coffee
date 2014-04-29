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