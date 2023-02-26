use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
use Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex;
use Gnome::SourceSkimTool::Prepare;

use XML::Actions;
use YAMLish;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare;
constant \ModuleDoc = Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
constant \ApiIndex = Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex;

has ModuleDoc $!mod-actions handles <description functions signals properties>;
has ApiIndex $!api-actions handles <objects>;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!mod-actions .= new;
  $!api-actions .= new;
}

#-------------------------------------------------------------------------------
method process-gtkdocs ( Str :$test-cwd ) {
 
  my Prepare $gfl .= new(:$test-cwd);
  my Str $gd = $gfl.set-gtkdoc-dir;

  $!mod-actions .= new;

  my Str $fname = $*sub-prefix;
  $fname ~~ s:g/ '_' //;
  my Str $docpath = "$gd/docs/$fname.xml";
  note "document path for module: $docpath" if $*verbose;
  my XML::Actions $a .= new(:file($docpath));
  $a.process(:actions($!mod-actions));

  self!save-module($gfl);
}

#-------------------------------------------------------------------------------
method process-apidocs ( Str :$test-cwd ) {

  my Prepare $gfl .= new(:$test-cwd);
  my Str $gd = $gfl.set-gtkdoc-dir;

  $!api-actions .= new;

  my Str $docpath = "$gd/docs/api-index-full.xml";
  note "document path for api: $docpath" if $*verbose;
  my XML::Actions $a .= new(:file($docpath));
  $!api-actions.process-deprecations = False;
  $a.process(:actions($!api-actions));

  $docpath = "$gd/docs/api-index-deprecated.xml";
  note "document path for api deprecations: $docpath" if $*verbose;
  $!api-actions.process-deprecations = True;
  $a .= new(:file($docpath));
  $a.process(:actions($!api-actions));

  self!save-objects;
}


#-------------------------------------------------------------------------------
method !save-module ( Prepare:D $gfl ) {

  my Str $fname = $gfl.set-skim-result-file;
  
  $fname.IO.spurt(
    save-yaml(
      %( :description($!mod-actions.description),
         :functions($!mod-actions.functions),
         :signals($!mod-actions.signals),
         :properties($!mod-actions.properties)
       )
    )
  );
}

#-------------------------------------------------------------------------------
method !save-objects ( ) {

  my $fname = SKIMTOOLDATA ~ 'objects.yaml';
  $fname.IO.spurt(save-yaml($!api-actions.objects));
}
