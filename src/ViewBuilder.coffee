#include Directives/DirectiveLoader.coffee
#include Variables/PlaceholderLoader.coffee

path= require "path"
mkdirp= require "mkdirp"
{MegaFile}= require "mega-reader"
class ViewBuilder
  constructor:(@filename,@name,@bin,@ext,@stack)->
    @endRender=false;
    @mr= new MegaFile([@filename])
    @mr.reset()
    @tools=[]
    @buildtools()
    @export();

  export:->
    unless fs.existsSync(@bin)
      mkdirp(@bin)
    fs.writeFileSync(@file(),"");
    @print("<?php //ini_set('error_reporting', 0);?>")
    while true
      if @mr.hasNextLine()
        @print(@mr.getNextLine())
      else if @endRender
        @endRender=false
        @print(
              """
               <?php
               if(isset($renderstack) && count($renderstack)>0){
                  $last=array_pop($renderstack);
                  if(isset($last->sections)):
                    foreach($last->sections as $key=>$value){
                      if(isset($last) && isset($last->parent)):
                      $last->parent=str_replace("#child ".$key, $value, $last->parent);
                      endif;
                    }
                  endif;
               }
                if(isset($last->parent)):
                echo $last->parent;
                endif;
               ?>
              """
        )
      else
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
        @endRender=true
        parentname= t.getDirective(line).value
        line="""
            <?php
              ob_start();
              if(!isset($renderstack)){
                $renderstack=[];
              }
              array_push($renderstack,new stdClass());

              include("#{parentname}.#{@ext}");
              if(!isset($last)){
                $last=null;
              }
              $last=$renderstack[count($renderstack)-1];
              if(isset($last) && !isset($last->parent)){
                $last->parent=null;
              }
              if(isset($last)):
                $last->parent=ob_get_clean();
              endif;
              if(isset($last) &&!isset($last->section)):
              $last->sections=[];
              endif;
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
      if t instanceof Variable or t instanceof CallableFunction or t instanceof If or t instanceof EndIf or t instanceof ForEach or t instanceof EndForEach or t instanceof Asset
        line= t.getReplacement line


    fs.appendFileSync(@file(),"#{line}#{os.EOL}")


  canHandle:(line)->
    for t in @tools when t.canHandle(line)
      return t
    return false




  buildtools:->
    for tool in [new Asset,new NeedDirective,new ParentDirective,new RepeatDirective,new SectionDirective,new NameDirective,new ChildDirective,new RenderDirective,new StopDirective,new CallableFunction,new Variable,new If,new EndIf]
      @tools.push tool



  file:->
    file= path.resolve(@bin,"#{@name}.#{@ext}")

