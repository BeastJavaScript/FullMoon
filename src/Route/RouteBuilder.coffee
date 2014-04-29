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


