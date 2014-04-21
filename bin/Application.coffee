class Directive
    constructor:(@symbol,@input)->
        if @constructor is Directive
            throw new Error("Class Directive is an Abstract Class")
        @static=@constructor
        @static.regex ?= new RegExp("##{@symbol} #{@input}")
    canHandle:(text)->
        if (result=@static.regex.exec()) isnt null
            return true
        else
            return false

    getDirective:(text)->
        result=@static.regex.exec(text)
        string=result[0]
        stringSplit=string.split(" ")
        key=stringSplit.unshift()
        value=stringSplit.join(" ")
        return {key:value}

exports.Directive=Directive


class SectionDirective extends Directive
  constructor:->
    super("parent","[^ ]+")

exports.SectionDirective=SectionDirective


class RepeatDirective extends Directive
  constructor:->
    super("parent","[^ ]+")

exports.RepeatDirective=RepeatDirective


class ParentDirective extends Directive
	constructor:->
		super("parent","[^ ]+")

exports.ParentDirective=ParentDirective


class NeedDirective extends Directive
	constructor:->
		super("need","[^ ]+")

exports.NeedDirective=NeedDirective




