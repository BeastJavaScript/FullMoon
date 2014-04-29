#include CommandLine.coffee
#include Directives/DirectiveLoader.coffee
#include DirectoryManager.coffee
#include FileManager.coffee
#include RenderLine.coffee



#include Route/RouteLoader.coffee

fs = require('fs')
Log = require('log')
process.output = new Log('debug', fs.createWriteStream('my.log'))