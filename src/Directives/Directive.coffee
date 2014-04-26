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