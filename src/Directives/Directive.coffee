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