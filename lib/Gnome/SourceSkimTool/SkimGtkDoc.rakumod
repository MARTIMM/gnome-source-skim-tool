use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
#use Gnome::SourceSkimTool::SkimGtkDoc::PropDoc;
use Gnome::SourceSkimTool::Prepare;

use XML::Actions;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare;
constant \ModuleDoc = Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
#constant \PropDoc = Gnome::SourceSkimTool::SkimGtkDoc::PropDoc;

has ModuleDoc $!mod-actions handles <description functions signals properties>;
#has PropDoc $!prop-actions;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!mod-actions .= new;
#  $!prop-actions .= new;
}

#-------------------------------------------------------------------------------
method process-gtkdocs ( Str :$test-cwd ) {
  my Prepare $gfl .= new(:$test-cwd);
  my Str $gd = $gfl.set-gtkdoc-dir;

  my Str $fname = $*sub-prefix;
  $fname ~~ s:g/ '_' //;
  my Str $docpath = "$gd/docs/$fname.xml";
  note "document path for module: $docpath" if $*verbose;

  my XML::Actions $a .= new(:file($docpath));
  $a.process(:actions($!mod-actions));
  note $!mod-actions.description.substr( 0, 100) if $*verbose;

#TODO; props and signals from xml docbook file!

#`{{
  $docpath = "$gd/gtk3.args";
  my Str $xml = $docpath.IO.slurp;
  $xml = Q:q:to/EOXML/;
    <?xml version="1.0"?>
    <!DOCTYPE args>
    <args>
    $xml
    </args>
  EOXML

  note "document path for module: $docpath" if $*verbose;
  $a .= new(:$xml);
  $a.process(:actions($!mod-actions));
}}
}
