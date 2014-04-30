#include Directives/DirectiveLoader.coffee

path= require "path"
mkdirp= require "mkdirp"
{MegaFile}= require "mega-reader"
class ViewBuilder
  constructor:(@filename,@name,@bin,@ext,@stack)->
    @mr= new MegaFile([@filename])
    @mr.reset()
    @tools=[]
    @buildtools()
    @export();

  export:->
    unless fs.existsSync(@bin)
      mkdirp(@bin)
    fs.writeFileSync(@file(),"");
    @print("<?php ini_set('error_reporting', 0);?>")
    while true
      if @mr.hasNextLine()
        @print(@mr.getNextLine())
      else
        @print(
              """
               <?php
               if(isset($renderstack) && count($renderstack)>0){
                  $last=&array_pop($renderstack);
                  foreach($last->sections as $key=>$value){
                    $last->parent=str_replace("#child ".$key, $value, $last->parent);
                  }
               }
                echo $last->parent;
                unset($last)
               ?>
              """
        )
        break

  print:(line)->
    t=@canHandle(line)
    if t
      if t instanceof NeedDirective
        line= "<?php include('#{t.getDirective(line).value}.#{@ext}') ?>"
      if t instanceof RenderDirective or t instanceof RepeatDirective or t instanceof NameDirective
        line=""
        return
      if t instanceof ParentDirective
        parentname= t.getDirective(line).value
        line="""
            <?php
              $renderstack[]= new stdClass();
              ob_start();
              include("#{parentname}.#{@ext}");
              $last=&$renderstack[count($renderstack)-1];
              $last->parent=ob_get_clean();
              $last->sections=[];
            ?>
            """

      if t instanceof SectionDirective
        @sectionName= t.getDirective(line).value
        line= """
              <?php ob_start();?>
              """
      if t instanceof StopDirective
        sectionName=@sectionName
        delete @sectionName
        line= """
              <?php
                $section_buffer=ob_get_clean();
                $last->sections['#{sectionName}']=$section_buffer
              ?>
              """

    fs.appendFileSync(@file(),"#{line}\n")


  canHandle:(line)->
    for t in @tools when t.canHandle(line)
      return t
    return false




  buildtools:->
    for tool in [new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective,new NameDirective,new ChildDirective,new RenderDirective,new StopDirective]
      @tools.push tool



  file:->
    file= path.resolve(@bin,"#{@name}.#{@ext}")

