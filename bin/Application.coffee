class Directive
    constructor:(@symbol,@input)->
        if @constructor is Directive
            throw new Error("Class Directive is an Abstract Class")
        @static=@constructor
        unless @input is null
          @regex=new RegExp("##{@symbol} #{@input}")
        else
          @regex=new RegExp("##{@symbol}")
    canHandle:(text)->
        if (result=@regex.exec(text)) isnt null
            return true
        else
            return false

    getDirective:(text)->
        result=@regex.exec(text)
        string=result[0]
        stringSplit=string.split(" ")
        key=stringSplit.unshift()
        value=stringSplit.join(" ")
        return {key:value}

exports.Directive=Directive
class DirectoryManager
  constructor:(@fileManager)->
    @that=@
    @files=[]
    @dirRead= require('node-dir')
    @add=@add.bind(@)
    @loadFiles=@loadFiles.bind(@)

  watchDirectory:->
    #nothing

  loadFiles:(directory,match=null,exclude=null,callback2=null)->
    callback=(err, files)->
      for file in files
        if match is null or (new RegExp(match)).exec(file)
          if exclude is null or (new RegExp(exclude)).exec(file) is null
            @add(file)
      if callback2 isnt null
        callback2.call()
    callback=callback.bind(@)
    @dirRead.files(directory,callback)


  add:(file)->
    @files.push file

  toString:->
    "[DirectoryManager]"



exports.DirectoryManager=DirectoryManager



class SectionDirective extends Directive
  constructor:->
    super("section","[^ ]+")

exports.SectionDirective=SectionDirective


class RepeatDirective extends Directive
  constructor:->
    super("repeat","[0-9]+")

exports.RepeatDirective=RepeatDirective


class ParentDirective extends Directive
	constructor:->
		super("parent","[^ ]+")

exports.ParentDirective=ParentDirective


class NeedDirective extends Directive
	constructor:->
		super("need","[^ ]+")

exports.NeedDirective=NeedDirective





