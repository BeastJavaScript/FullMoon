#include Directive.coffee

class CustomDirective extends Directive
  constructor:(symbol,input)->
    super(symbol,input)
    unless @input is null
      @static=@
      @static.regex = new RegExp("##{@symbol} #{@input}")
    else
      @static.regex = new RegExp("##{@symbol}")

exports.CustomDirective=CustomDirective