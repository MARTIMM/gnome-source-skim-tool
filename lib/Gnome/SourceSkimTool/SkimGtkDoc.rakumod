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

has ModuleDoc $!mod-actions handles <
  description functions signals properties types
>;
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
=begin pod
Gather the info from api-index-full.xml, api-index-deprecated.xml and  …decl.xml and store it into the yaml file objects.yaml. This is a one time operation that covers all of the particular gnome package.

  method process-apidocs ( Str :$test-cwd )

=item $test-cwd
=end pod

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

  # Get enum values from e.g. ./Gtkdoc/Gtk3/gtk3-decl.txt
  self!add-enum-values($gfl.set-gtkdoc-file('decl'));
  self!save-objects;
}

#-------------------------------------------------------------------------------
method !add-enum-values ( Str $gtkdoc-text ) {
  my Str $text = $gtkdoc-text.IO.slurp;
  my Hash $objects := $!api-actions.objects;

  loop {
    $text ~~ m/ $<enum-text> = [ \< ENUM \> .*? \< \/ ENUM \> ] /;
    last unless ?$<enum-text>;

    # remove from main text so next loop will get next enum
    my Str $enum-text = $<enum-text>.Str;
    $text ~~ s/ $enum-text //;

    # get name of enum
    $enum-text ~~ m/ \< NAME \> $<enum-name> = [.*?] \< \/ NAME \> /;
    my Str $enum-name = $<enum-name>.Str;
    $objects{$enum-name}<values> = [];
    $objects{$enum-name}<names> = [];
#note "$?LINE: $enum-name";

    # get content of enum and remove all comments
    $enum-text ~~ s:g/ '/*' .*? '*/' //;
    $enum-text ~~ m/ typedef \s+ enum \s* '{' \s+
                     $<enum-list> = [.*?] \s* '}'
                   /;
    my Str $enum-list = $<enum-list>.Str;

    # split list on the commas and process each entry
    my @entries = $enum-list.split(/ ',' /);
    my Int $enum-count = 0;
    my Str $entry-value;

    # sometimes ored names are used as a value from the same enum definition.
    # gather them in a Hash to substitute the previously defined value
    my Hash $ored-values = %();

    for @entries -> $entry is copy {
      # cleanup; leading/trailing spaces, (…)
      $entry ~~ s/^ \s+ //;
      $entry ~~ s/ \s+ $//;
      $entry ~~ s:g/ <[\(\)]> //;
#note "$?LINE: $entry";

      # get the enum name
      $entry ~~ /^ $<entry-name> = [<-[\s]>+] /;
      
      # sometimes an empty entry at the end
      next unless ?$<entry-name>;

      my Str $entry-name = $<entry-name>.Str;

      $entry ~~ / '=' \s+ $<entry-value> = [.*] $/;
      if ?$<entry-value> {
        $entry-value = $<entry-value>.Str;
print "$?LINE: $enum-name, $entry-name: $entry-value";

        # check for ored values
        if $entry-value ~~ m/ '|' / {
          my @v = $entry-value.split(/\s* '|' \s*/);
          loop ( my Int $i = 0; $i < @v.elems; $i++ ) {
            @v[$i] = '(' ~ $ored-values{@v[$i]} ~ ')';
          }

          # Make it a Raku join operation
          $entry-value = @v.join(' +| ');
        }

        else {
          # If there is a C-lang shift left, convert it to a Raku-lang shift
          $entry-value ~~ s/ '<<' /+</;
        }
note "--> $entry-value";
      }

      else {
        $entry-value = ($enum-count++).Str;
      }

      # temporary use for ored value substitutions
      $ored-values{$entry-name} = $entry-value;

      $objects{$enum-name}<names>.push: $entry-name;
      $objects{$enum-name}<values>.push: $entry-value;
#      $objects{$enum-name}<sequential> = $enum-count > 0;
    }
    
    # if we have counted the entries, then use the simplefied version
    # and throw away the array
    if $enum-count > 0 {
      $objects{$enum-name}<sequential> = True;
      $objects{$enum-name}<values>:delete;
    }

    else {
      $objects{$enum-name}<sequential> = False;
    }
  }
}

#-------------------------------------------------------------------------------
method !save-module ( Prepare:D $gfl ) {

  my Str $fname = $gfl.set-skim-result-file;
  
  $fname.IO.spurt(
    save-yaml(
      %( :description($!mod-actions.description),
         :functions($!mod-actions.functions),
         :signals($!mod-actions.signals),
         :properties($!mod-actions.properties),
         :types($!mod-actions.types),
       )
    )
  );
}

#-------------------------------------------------------------------------------
method !save-objects ( ) {

  my $fname = SKIMTOOLDATA ~ 'objects.yaml';
  $fname.IO.spurt(save-yaml($!api-actions.objects));
}
