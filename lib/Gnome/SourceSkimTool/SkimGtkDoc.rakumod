use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc::DocSearch;
use Gnome::SourceSkimTool::GetFileList;

use XML::Actions;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc;

#-------------------------------------------------------------------------------
constant \DocSearch = Gnome::SourceSkimTool::SkimGtkDoc::DocSearch;
constant \GetFileList = Gnome::SourceSkimTool::GetFileList;

has DocSearch $!actions handles <description functions>;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!actions .= new;
}

#-------------------------------------------------------------------------------
method process-gtkdocs ( Str :$test-cwd ) {
  my GetFileList $gfl .= new(:$test-cwd);
  my Str $gd = $gfl.set-gtkdoc-dir;
  my Str $fname = $*sub-prefix;
  $fname ~~ s:g/ '_' //;
  my Str $docpath = "$gd/docs/$fname.xml";
#note "doc: $docpath";

  my XML::Actions $a .= new(:file($docpath));
  $a.process(:$!actions);
#note $!actions.description;
}
