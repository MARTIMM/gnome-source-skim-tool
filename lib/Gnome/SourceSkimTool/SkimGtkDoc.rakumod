use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc::DocSearch;
use Gnome::SourceSkimTool::GetFileList;

use XML::Actions;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc;

#-------------------------------------------------------------------------------
constant \DocSearch = Gnome::SourceSkimTool::SkimGtkDoc::DocSearch;
constant \GetFileList = Gnome::SourceSkimTool::GetFileList;

#-------------------------------------------------------------------------------
#submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method process-description ( Str :$test-cwd ) {
  my GetFileList $gfl .= new(:$test-cwd);
  my Str $gd = $gfl.set-gtkdoc-dir;
  my Str $fname = $*sub-prefix;
  $fname ~~ s:g/ '_' //;
  my Str $docpath = "$gd/docs/$fname.xml";
note "doc: $docpath";

  my DocSearch $actions .= new;
  my XML::Actions $a .= new(:file($docpath));
  $a.process(:$actions);
note $actions.description;
}
