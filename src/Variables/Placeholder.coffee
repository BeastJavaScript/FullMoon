class Placeholder
  constructor:(@match,@replacement,@preview)->
    @static=@constructor
    @static.regex ?= new RegExp(@match)
    @static.regexR ?= new RegExp(@match,"g")

  canHandle:(text)->
    @static.regex.exec(text) isnt null;

  getReplacement:(text)->
    text.replace(@static.regexR,@replacement,text)


  getPreviewReplacement:(text)->
    text.replace(@static.regexR,@preview,text)



exports.Placeholder=Placeholder
