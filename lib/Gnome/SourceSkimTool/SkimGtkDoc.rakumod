use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
use Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex;
use Gnome::SourceSkimTool::Prepare;

use XML::Actions;

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

  $!api-actions.load-objects;
}

#-------------------------------------------------------------------------------
method process-gtkdocs ( ) {
 
  my Str $gd = $*work-data<gtkdoc-dir>;

  $!mod-actions .= new;

  my Str $fname = $*gnome-class.lc;
  my Str $docpath = "$gd/docs/$fname.xml";
  note "\ndocument path for module: $docpath" if $*verbose;
  my XML::Actions $a .= new(:file($docpath));
  $a.process(:actions($!mod-actions));

  $!mod-actions.save-module($*work-data<skim-module-result>);
}

#-------------------------------------------------------------------------------
=begin pod
Gather the info from api-index-full.xml, api-index-deprecated.xml and  …decl.xml and store it into the yaml file objects.yaml. This is a one time operation that covers all of the particular gnome package.

  method process-apidocs ( )

=item $test-cwd
=end pod

method process-apidocs ( ) {

  my Prepare $gfl .= new;
  my Str $gd = $*work-data<gtkdoc-dir>;

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
  self!add-enum-values($gfl.get-gtkdoc-file( '-decl', :txt));

  # Add hierargy info
  self!add-hierarchy($gfl.get-gtkdoc-file( '.hierarchy', :!txt));

  # Add role implementation info
#  self!add-roles($gfl.get-gtkdoc-file( '.interfaces', :!txt));

  $!api-actions.save-objects;
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
method !add-hierarchy ( Str $gtkdoc-text ) {
 
  my Str $text = $gtkdoc-text.IO.slurp;
  my Hash $objects := $!api-actions.objects;

  my Str $current-top-class = '';
  my Array $classes = [];
  my Int $previous-indent = 0;
  for $text.lines -> $line {
    my Int $indent = 0;
    $line ~~ m/^ $<indent> = [\s*] $<class> = [.+] $/;
    $indent = ($<indent>.Str.chars / 2).Int if ?$<indent>;
    my $class = $<class>.Str;
    $classes[$indent] = $class;

    # it starts at indent 0 so $current-top-class is defined quick
    if $indent == 0 {
      $current-top-class = $class;
    }

    if $current-top-class eq 'GInterface' {
      if $indent > 0 {
        $objects{$class}<class-type> = 'role';
        $objects{$class}<location> = 'leaf';
      }
    }

    elsif $current-top-class eq 'GBoxed' {
      $objects{$class}<class-type> = 'boxed';
      $objects{$class}<location> = 'leaf';
    }

    elsif $current-top-class eq 'GFlags' {
      $objects{$class}<class-type> = 'enum';
      $objects{$class}<location> = 'leaf';
    }

    elsif $indent == 1 {
      $objects{$class}<class-type> = 'gobject';
      $objects{$class}<location> = 'top';
      $objects{$class}<leaf> = True;
      $objects{$classes[$indent-1]}<leaf> = False;
    }

    elsif $indent > 1 {
      $objects{$class}<class-type> = $classes[2] eq 'GtkWidget'
                                     ?? 'widget' !! 'gobject';
      $objects{$class}<parent> = $classes[$indent-1];

      # Assume this class is a leaf. Then make the parent <leaf> False
      $objects{$class}<leaf> = True;
      $objects{$classes[$indent-1]}<leaf> = False;
    }

    $previous-indent = $indent;
#note "$?LINE: $indent, $class";
  }
}

#-------------------------------------------------------------------------------
method !add-roles ( Str $gtkdoc-text ) {
  my Str $text = $gtkdoc-text.IO.slurp;
  my Hash $objects := $!api-actions.objects;

  for $text.lines -> $line {
    my @class-with-roles = $line.split(/\s+/);
    my Str $class = @class-with-roles.shift;

  }
}



#`{{
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
}}

#`{{
#-------------------------------------------------------------------------------
method !save-objects ( ) {

  my $fname = SKIMTOOLDATA ~ 'objects.yaml';
  $fname.IO.spurt(save-yaml($!api-actions.objects));
}

#-------------------------------------------------------------------------------
method !load-objects ( --> Hash ) {

  my $fname = SKIMTOOLDATA ~ 'objects.yaml';
  load-yaml($fname.IO.slurp);
}
}}