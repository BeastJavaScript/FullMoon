class Directive
    constructor:(@symbol,@input)->
        if @constructor is Directive
            throw new Error("Class Directive is an Abstract Class")
        @static=@constructor
        @static.regex ?= new RegExp("##{@symbol} #{@input}")
    canHandle:(text)->
        if (result=@static.regex.exec(text)) isnt null
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