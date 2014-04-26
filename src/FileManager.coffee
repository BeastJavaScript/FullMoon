fs= require "fs"
{MegaFile}=require "mega-reader"

class FileManager
  constructor:(@filename,@callback=null,@stack)->
    @mr= new MegaFile([@filename])
    @tools=[]
    @needed=[]
    @section=[]
    @child=[]
    @buildtools()
    @analyze()

  repeat:null

  needed:null

  parent:null

  section:null

  name:null

  child:null

  renderline:null

  analyze:->
    file=fs.readFileSync(@filename,{encoding:"utf8"})
    if (new RenderDirective).canHandle(file)
      @render=true

    if (rd=new RepeatDirective).canHandle(file)
      @repeat=rd.getDirective(file).value

    if (nd=new NeedDirective).canHandle(file)
      @needed.push nd.getDirective(file).value

    if (pd=new ParentDirective).canHandle(file)
      @parent=pd.getDirective(file).value

    if (sd=new SectionDirective).canHandle(file)
      @section.push sd.getDirective(file).value

    if (named=new NameDirective).canHandle(file)
      @name = named.getDirective(file).value

    if (cd=new ChildDirective).canHandle(file)
      @child.push cd.getDirective(file).value

    @callback.call()

  build:(callback)->
    if @render
      @buildRenderLine()
    callback.call()

  buildRenderLine:->
    process.output.debug "building renderline"
    @renderline = new RenderLine(@name,@stack)
    item=@
    while true
      unless item
        break
      @renderline.unshift(item)
      item=item.getParent()
    @renderline.render()


  toString:()->
    obj=
      name:@name
      parent:@parent
      needed:@needed
      sections:@section
      repeat:@repeat
      render:@render
      child:@child

    JSON.stringify(obj,undefined,2)







  buildtools:->
    for tool in [new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective]
      @tools.push tool


  getParent:()->
    unless @parent
      return @parent

    for fm in @stack when fm.name is @parent
      return fm