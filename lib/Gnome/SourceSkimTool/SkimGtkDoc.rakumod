
use XML;
use XML::XPath;
use YAMLish;

use Gnome::SourceSkimTool::ConstEnumType;


#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc:auth<github:MARTIMM>;

has Hash $!map;
has Hash $!other;
has XML::XPath $!xp;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  my Str $file = $*work-data<gir>;
  $!xp .= new(:$file);

  # the sections like :function are arrays of XML::Element's
  $!other = %(
    :function([]),
    :record([]),
    :union([]),
    :callback([]),
    :bitfield([]),
    :enumeration([]),
    :interface([]),
  );
}

#-------------------------------------------------------------------------------
method get-classes-from-gir ( ) {
  #my @r = ($!xp.find( '//class[@name="Label"]/doc', :to-list));
  #note @r[0].Str;

  # make start of xml by taking the <package> and <namespace> elements.
  # some gir files mention two packages. we take only one
  my XML::Element $e = $!xp.find( '/repository/package', :to-list)[0];
  my Str $xml-namespace = "  $e.Str()\n      <namespace\n";

  # get info from namespace
  $e = $!xp.find( '/repository/namespace');
  my $attribs = $e.attribs;
  my Str $namespace-name = $attribs<name>;
  my Str $symbol-prefix = $attribs<c:symbol-prefixes>;
  my Str $id-prefix = $attribs<c:identifier-prefixes>;

  # and add attributes to the xml start
  for $attribs.kv -> $k, $v {
    $xml-namespace ~= "            $k=\"$v\"\n";
  }
  $xml-namespace ~= "      >\n";

  my @elements = ($!xp.find( '/repository/namespace/*', :to-list));
  for @elements -> $element {
    given $element.name {

      # save the class info in separate gir files
      when 'class' {
        my $attrs = $element.attribs;
        my $name = $attrs<name>;
        my Str $xml = qq:to/EOXML/;
          <?xml version="1.0"?>
          <!--
            File is automatically generated from original gir files;
            DO NOT EDIT!
          -->
          <repository version="1.2"
                      xmlns="http://www.gtk.org/introspection/core/1.0"
                      xmlns:c="http://www.gtk.org/introspection/c/1.0"
                      xmlns:glib="http://www.gtk.org/introspection/glib/1.0">
              $xml-namespace
              $element.Str()
            </namespace>
          </repository>
          EOXML

        my $xml-file = "$*work-data<gir-module-path>$name.gir";
        note "Save class $name in '$xml-file'" if $*verbose;
        $xml-file.IO.spurt($xml);
      }

      when 'function' {
        $!other<function>.push: $element;
      }

      when 'record' {
        $!other<record>.push: $element;
      }

      when 'union' {
        $!other<union>.push: $element;
      }

      when 'callback' {
        $!other<callback>.push: $element;
      }

      when 'bitfield' {
        $!other<bitfield>.push: $element;
      }

      when 'enumeration' {
        $!other<enumeration>.push: $element;
      }

      when 'interface' {
        $!other<enumeration>.push: $element;
      }
    }

#note "$?LINE: $namespace-name, $symbol-prefix, $id-prefix";
    self!map-element( $element, $namespace-name, $symbol-prefix, $id-prefix);
  }

  # Before we save the map find out which classes are at the bottom (≡ leaf)
  for $!map.keys -> $entry-name {
    # Skip all other types
    next unless $!map{$entry-name}<gir-type> eq 'class';

    # If there is a leaf and is False, then all parents are also set False
    next if $!map{$entry-name}<leaf>:exists and ! $!map{$entry-name}<leaf>;

    # Assume we are at the end, so leaf is True
    $!map{$entry-name}<leaf> = True;

    sub set-parent-leaf-false ( Str $parent = '' ) {
      return unless ?$parent;

      if $!map{$parent}<leaf>:exists and $!map{$parent}<leaf> {
        $!map{$parent}<leaf> = False;
        set-parent-leaf-false($!map{$parent}<parent-gnome-name>);
      }
    }

    set-parent-leaf-false($!map{$entry-name}<parent-gnome-name>);
  }


  self!save-other($xml-namespace);
  self!save-map;
}

#-------------------------------------------------------------------------------
# Make a map of function, class and structure names to Raku names. Add some
# extra notes like type and location in hierarchy tree.
method !map-element (
  XML::Element $element, Str $namespace-name, Str $symbol-prefix, Str $id-prefix
) {

  my Hash $attrs = $element.attribs;
  note "$?LINE: ", $element.name, ', ', $attrs<name> if $*verbose;

  given $element.name {
    when 'class' {
      my @roles = ();
      for $!xp.find( 'implements', :start($element), :to-list) -> $ie {
        @roles.push: $ie.attribs<name>;
      }
          
      my Str ( $parent-gnome-name, $parent-raku-name ) =
         self!set-names($attrs<parent> // '');
      
      my Bool $inheritable = False;
      $inheritable = True if $attrs<c:type> ne 'GtkWidget'
                     and $*work-data<raku-package> ~~ m/ '::Gtk' /;

      $!map{$attrs<c:type> // $attrs<glib:type-name>} = %(
        :rname($*work-data<raku-package> ~ '::' ~ $attrs<name>),
        :$parent-raku-name, :$parent-gnome-name, :@roles,
        :symbol-prefix($symbol-prefix ~ '_' ~ $attrs<c:symbol-prefix> ~ '_'),
        :$inheritable,
        :gir-type<class>,
      );
    }

    when 'function' {
      my Str $rname = $attrs<name>;
      $rname ~~ s:g/ '_' /-/;
      $!map{$attrs<c:identifier>} = %(
        :$rname,
        :gir-type<function>,
      )
    }

    # 'typedef'
    when 'alias' {
      my Hash $alias-type-attribs;
      for $element.nodes -> $n {
        if $n ~~ XML::Element and $n.name eq 'type' {
          $alias-type-attribs = $n.attribs;
          last;
        }
      }

      $!map{$attrs<c:type>} = %(
        :cname($alias-type-attribs<c:type>),
        :rname($alias-type-attribs<name>),
        :gir-type<alias>
      );
    }

    when 'constant' {
       my Hash $const-type-attribs;
      for $element.nodes -> $n {
        if $n ~~ XML::Element and $n.name eq 'type' {
          $const-type-attribs = $n.attribs;
          last;
        }
      }

      $!map{$attrs<c:type>} = %(
        :cname($const-type-attribs<c:type>),
        :rname($const-type-attribs<name>),
        :gir-type<constant>,
      );
    }

    # 'struct'
    when 'record' {
      $!map{$attrs<c:type>} = %(
        :rname($*work-data<raku-package> ~ '::' ~ $attrs<name>),
        :gir-type<record>,
      );
    }

    when 'callback' {
      $!map{$attrs<c:type>} = %(
        :rname($attrs<name>),
        :gir-type<callback>,
      );
    }

    when 'bitfield' {
      $!map{$attrs<c:type>} = %(
        :rname($attrs<name>),
        :gir-type<bitfield>,
      );
    }

    when 'docsection' {
      $!map{$attrs<name>} = %(
        :rname($attrs<name>),
        :gir-type<docsection>,
      )
    }

    when 'union' {
      $!map{$attrs<c:type>} = %(
        :rname($attrs<name>),
        :gir-type<union>,
      );
    }

    # 'enum'
    when 'enumeration' {
      $!map{$attrs<c:type>} = %(
        :rname($attrs<name>),
        :gir-type<enumeration>,
      );
    }

    # 'role'
    when 'interface' {
      $!map{$attrs<c:type>} = %(
        :gir-type<interface>,
        :rname($*work-data<raku-package> ~ '::' ~ $attrs<name>),
        :symbol-prefix($symbol-prefix ~ '_' ~ $attrs<c:symbol-prefix> ~ '_'),
      );
    }

    # '#define'
    when 'function-macro' { }

    default {
      print 'Missed an element type: ', .note;
    }
  }
}

#-------------------------------------------------------------------------------
# This $naked-gnome-name is a name without a package name or one seperated with 
# a dot. Convert it into two names. E.g.
#   Widget ==> ( GtkWidget, Gnome::Gtk3::Widget)
#   Atk.Component ==> ( AtkComponent, Gnome::Atk::Component)
method !set-names ( Str $naked-gnome-name is copy  --> List ) {

  my Str $raku-name = $naked-gnome-name;

  my $gnome-name = $naked-gnome-name;
  given $naked-gnome-name {
    when /^ GObject \. / {
      $gnome-name ~~ s/^ GObject \. /G/;
      $raku-name ~~ s/^ GObject \. /Gnome::GObject::/;
    }

    when /^ Gio \. / {
      $gnome-name ~~ s/^ GObject \. /G/;
      $raku-name ~~ s/^ Gio \. /Gnome::Gio::/;
    }

    # ?? probably not used ??
    when /^ Glib \. / {
      $gnome-name ~~ s/^ Glib \. /G/;
      $raku-name ~~ s/^ Glib \. /Gnome::Glib::/;
    }

    when /^ Atk \. / {
      $gnome-name ~~ s/ \. //;
      $raku-name ~~ s/^ Atk \. /Gnome::Atk::/;
    }

    when /^ Gtk \. / {
      # Get version. There will only be a mention of versions in packages
      # of the same version level. Lower level packages will never mention
      # higher ones.
      $*gnome-package ~~ m/ $<version> = [\d+] $/;
      my Str $version = ($<version>//'').Str;
      $gnome-name ~~ s/ \. //;
      $raku-name ~~ s/^ Gtk \. /Gnome::Gtk{$version}::/;
    }

    when /^ Gdk \. / {
      $*gnome-package ~~ m/ $<version> = [\d+] $/;
      my Str $version = ($<version>//'').Str;
      $gnome-name ~~ s/ \. //;
      $raku-name ~~ s/^ Gdk \. /Gnome::Gdk{$version}::/;
    }

    when /^ Gsk \. / {
      $gnome-name ~~ s/ \. //;
      $raku-name ~~ s/^ Gtk \. /Gnome::Gsk4::/;
    }

    # When no dot is used it must be from the same package
    when ?$naked-gnome-name {
      $gnome-name =
         "{ S/ \d $// with $*gnome-package.Str }$naked-gnome-name";
      $raku-name = "Gnome::{$*gnome-package.Str}::$naked-gnome-name";
    }
  }

  ( $gnome-name, $raku-name)
}

#-------------------------------------------------------------------------------
method !save-map ( ) {

  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  note "Save object map in '$fname'" if $*verbose;
  $fname.IO.spurt(save-yaml($!map));
}

#`{{
#-------------------------------------------------------------------------------
multi method load-map ( --> Hash ) {

  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  note "Load object map from '$fname'" if $*verbose;
  load-yaml($fname.IO.slurp);
}
}}

#-------------------------------------------------------------------------------
method load-map ( $object-map-path --> Hash ) {

#  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  my $fname = $object-map-path ~ 'repo-object-map.yaml';
  note "Load object map from '$fname'" if $*verbose;
  load-yaml($fname.IO.slurp);
}

#-------------------------------------------------------------------------------
method !save-other ( Str $xml-namespace ) {

  my Str $xml-begin = qq:to/EOXML/;
    <?xml version="1.0"?>
    <!--
      File is automatically generated from original gir files;
      DO NOT EDIT!
    -->
    <repository version="1.2"
                xmlns="http://www.gtk.org/introspection/core/1.0"
                xmlns:c="http://www.gtk.org/introspection/c/1.0"
                xmlns:glib="http://www.gtk.org/introspection/glib/1.0">
        $xml-namespace
    EOXML

  my Str $xml-end = qq:to/EOXML/;
      </namespace>
    </repository>
    EOXML

  my Str $content = '';
  for $!other.keys -> $section {
    if $!other{$section}.elems {
      $content = $xml-begin;
      for @($!other{$section}) -> $element {
        $content ~= $element.Str ~ "\n";
      }
      $content ~= $xml-end;

      my Str $name = 'repo-' ~ $section;
      my $xml-file = "$*work-data<gir-module-path>$name.gir";
      note "Save $section in '$xml-file'" if $*verbose;
      $xml-file.IO.spurt($content);
    }
  }
}






=finish

#-------------------------------------------------------------------------------
# Get data from functions, callbacks and methods
method !routine-data ( XML::Element $element, Hash $attrs ) {

  my Str $rname = $attrs<name>;
  $rname ~~ s:g/ '_' /-/;
  $!map{$attrs<c:identifier>} = %(
    :$rname,
  )
}


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

  my Prepare $gfl .= new;

  $!mod-actions .= new;
  $!api-actions .= new;

  $!api-actions.load-objects($*work-data<gir-module-path> ~ 'objects.yaml');
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

  $!mod-actions.save-module($*work-data<gir-module-path>);
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

  my Str $docpath = "$gd/docs/api-index-full.xml";
  note "document path for api: $docpath" if $*verbose;
  my XML::Actions $a .= new(:file($docpath));
  # no notion of deprecations in the api-index-full file
  $!api-actions.process-deprecations = False;
  $a.process(:actions($!api-actions));

  $docpath = "$gd/docs/api-index-deprecated.xml";
  note "document path for api deprecations: $docpath" if $*verbose;
  # there are only deprecations in the api-index-deprecated file
  $!api-actions.process-deprecations = True;
  $a .= new(:file($docpath));
  $a.process(:actions($!api-actions));

  # Get enum values from e.g. ./Gtkdoc/Gtk3/gtk3-decl.txt
  self!add-enum-values($gfl.get-gtkdoc-file( '-decl', :txt));

  # Add hierargy info
  self!add-hierarchy($gfl.get-gtkdoc-file( '.hierarchy', :!txt));

  # Add role implementation info
#  self!add-roles($gfl.get-gtkdoc-file( '.interfaces', :!txt));

  $!api-actions.save-objects($*work-data<gir-module-path> ~ 'objects.yaml');
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
#print "$?LINE: $enum-name, $entry-name: $entry-value";

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
#note "--> $entry-value";
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

      # Assume this class is a leaf. Then make the parent <leaf> False.
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