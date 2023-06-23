
use XML;
use XML::XPath;
use YAMLish;

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;


#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Hash $!map;
has Hash $!other;
has XML::XPath $!xp;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!sas .= new;

  # the sections like :function are arrays of XML::Element's
  $!other = %(
    :function([]),
#    :record([]),
#    :union([]),
    :callback([]),
    :bitfield([]),
    :enumeration([]),
    :constant([]),
    :docsection([]),
#    :interface([]),
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

  # glib strays of from standard, must correct it. Gio and GObject are correct
  $symbol-prefix ~~ s/^ g \. .* /g/;

  my Str $id-prefix = $attribs<c:identifier-prefixes>;

  # and add attributes to the xml start
  for $attribs.kv -> $k, $v {
    $xml-namespace ~= "            $k=\"$v\"\n";
  }
  $xml-namespace ~= "      >\n";

  my @elements = ($!xp.find( '/repository/namespace/*', :to-list));
  for @elements -> $element {

#note "$?LINE: $namespace-name, $symbol-prefix, $id-prefix";
    # Map an element into the repo-object-map. Returns True if
    # element is deprecated or is a class, iface or private type.
    next if self!map-element(
      $element, $namespace-name, $symbol-prefix, $id-prefix
    );

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

        my $xml-file = "$*work-data<gir-module-path>C-$name.gir";
        note "Save class $name in '$xml-file'" if $*verbose;
        $xml-file.IO.spurt($xml);
      }

      # Only stand alone functions. Functions within other
      # elements are not saved here.
      when 'function' {
        $!other<function>.push: $element;
      }

      # Records are structures in C. There are fields for the structure,
      # constructors, methods and functions.
      when 'record' {
#        $!other<record>.push: $element;
        my $attrs = $element.attribs;
        my $name = $attrs<c:type>;

        my Str $name-prefix = $*work-data<name-prefix>;
        $name ~~ s:i/^ $name-prefix //;

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

        my $xml-file = "$*work-data<gir-module-path>R-$name.gir";
        note "Save record $name in '$xml-file'" if $*verbose;
        $xml-file.IO.spurt($xml);
      }

      when 'constant' {
        $!other<constant>.push: $element;
      }

      when 'docsection' {
        $!other<docsection>.push: $element;
      }

      when 'union' {
#        $!other<union>.push: $element;
        my $attrs = $element.attribs;
        my $name = $attrs<c:type>;

        my Str $name-prefix = $*work-data<name-prefix>;
        $name ~~ s:i/^ $name-prefix //;

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

        my $xml-file = "$*work-data<gir-module-path>U-$name.gir";
        note "Save record $name in '$xml-file'" if $*verbose;
        $xml-file.IO.spurt($xml);
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

        my $xml-file = "$*work-data<gir-module-path>I-$name.gir";
        note "Save class $name in '$xml-file'" if $*verbose;
        $xml-file.IO.spurt($xml);
      }
    }
  }

  # Before we save the map find out which classes are at the bottom (≡ leaf)
  # Also we want to know which classes will be inheritable. It is now decided to
  # only have decendents from GtkWidget be able to inherit.
  # The classes which implement a role (a C-interface) must be checked if the
  # parent has also the same role. Only the top most class can implement this
  # role in Raku. All decendents will have access to the methods and signals
  # defined in that role.
  for $!map.keys -> $entry-name {

    # Skip all other types
    next unless $!map{$entry-name}<gir-type>:exists
         and $!map{$entry-name}<gir-type> eq 'class';

    $!map{$entry-name}<inheritable> = self!is-inheritable($entry-name);
    self!set-real-role-user($entry-name) if $!map{$entry-name}<roles>;

# No leaf testing. casting is not needed
#    # If there is a leaf and is False, then all parents are already set False
#    next if $!map{$entry-name}<leaf>:exists and ! $!map{$entry-name}<leaf>;
#
#    # Assume we are at the end, so leaf is True
#    $!map{$entry-name}<leaf> = True;
#
#    sub set-parent-leaf-false ( Str $parent = '' ) {
#      return unless ?$parent;
#
#      if $!map{$parent}<leaf>:exists and $!map{$parent}<leaf> {
##note "$parent leaf set False";
#        $!map{$parent}<leaf> = False;
#        set-parent-leaf-false($!map{$parent}<parent-gnome-name>);
#      }
#
#      elsif $!map{$parent}<leaf>:!exists {
##note "$parent leaf set False (<leaf> created";
#        $!map{$parent}<leaf> = False;
#      }
#    }
#
#    set-parent-leaf-false($!map{$entry-name}<parent-gnome-name>);
  }


  self!save-other($xml-namespace);
  self!save-map;
}

#-------------------------------------------------------------------------------
method !set-real-role-user( Str $entry-name ) {

  # Check all roles for this class
  for @($!map{$entry-name}<roles>) -> $role-name {
    my Hash $role-h = $!sas.search-name($role-name);

    # Never implement deprecated roles
    self!check-parent-role( $entry-name, $role-name)
      unless ?$role-h<deprecated>;
  }
}

#-------------------------------------------------------------------------------
method !check-parent-role ( Str $entry-name, Str $role-name ) {
  my $parent-entry = $!map{$entry-name}<parent-gnome-name>;

  # Stop when parent is GObject or GInitiallyUnowned. They have
  # no roles implemented
  if !$parent-entry or ($parent-entry ~~ any(<GObject GInitiallyUnowned>)) {
    $!map{$entry-name}<implement-roles> = []
      unless $!map{$entry-name}<implement-roles>:exists;

    # Add role name unless done before
    unless $!map{$entry-name}<implement-roles>.first($role-name) {
      $!map{$entry-name}<implement-roles>.push: $role-name;
      note "Implement $role-name in class $!map{$entry-name}<rname>"
        if $*verbose;
    }
  }

  # Search using parent entry when role name is found in roles array
  elsif ?$parent-entry and ?$!map{$parent-entry}<roles>.first($role-name) {
    self!check-parent-role( $parent-entry, $role-name);
  }

  # If not found in parents role array then this class must implement it
  else {
    $!map{$entry-name}<implement-roles> = []
      unless $!map{$entry-name}<implement-roles>:exists;

    # Add role name unless done before
    unless $!map{$entry-name}<implement-roles>.first($role-name) {
      $!map{$entry-name}<implement-roles>.push: $role-name;
      note "Implement $role-name in class $!map{$entry-name}<rname>"
        if $*verbose;
    }
  }
}

#-------------------------------------------------------------------------------
# Make a map of function, class and structure names to Raku names. Add some
# extra notes like type and location in hierarchy tree. Return True when element
# is deprecated or is a class, iface or private type
method !map-element (
  XML::Element $element, Str $namespace-name, Str $symbol-prefix, Str $id-prefix
  --> Bool
) {
  my Bool $deprecated = False;

  # Get attribute hash and the map key from some sort of identifier
  my Hash $attrs = $element.attribs;
  my Str $ctype = $attrs<c:type> //           # Most cases
                  $attrs<glib:type-name> //   # Some classes
                  $attrs<c:identifier> //     # Functions
                  $attrs<name> // ''          # Doc sections
                  ;

  return True if $ctype ~~ m/ [ Private || Class || Iface ] $/;

  # Check for this id. If undefined make some noise and return
  note "\n$?LINE NO IDENTIFIER FOUND FOR tag $element.name(); ", $attrs.gist
       unless ?$ctype;

  return True unless ?$ctype;

  # Gather data depending on the tag type
  given $element.name {
    when 'class' {
      my @roles = ();
      for $!xp.find( 'implements', :start($element), :to-list) -> $ie {
        @roles.push: $ie.attribs<name>;
      }
          
      my Str ( $parent-gnome-name, $parent-raku-name ) =
         self!set-names($attrs<parent> // '');

      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
#note "\n$?LINE {$element.attribs()<name>}, $fname";

      $!map{$ctype} = %(
        :rname($*work-data<raku-package> ~ '::' ~ $attrs<name>),
        :$parent-raku-name, :$parent-gnome-name, :@roles,
        :symbol-prefix($symbol-prefix ~ '_' ~ $attrs<c:symbol-prefix> ~ '_'),
        :gir-type<class>,
        :class-file($fname),
        :$deprecated,
      );
    }

    when 'function' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      my Str $rname = $attrs<name>;
      $rname ~~ s:g/ '_' /-/;
      $!map{$ctype} = %(
        :$rname,
        :gir-type<function>,
        :class-file($fname),
        :$deprecated,
      );
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

      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      $!map{$ctype} = %(
        :cname($alias-type-attribs<c:type>),
        :rname($alias-type-attribs<name>),
        :gir-type<alias>
        :class-file($fname),
        :$deprecated,
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

      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      $!map{$ctype} = %(
        :cname($const-type-attribs<c:type>),
        :rname($const-type-attribs<name>),
        :gir-type<constant>,
        :class-file($fname),
        :$deprecated,
      );
    }

    # 'struct'
    when 'record' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      my Str $rname = $ctype;
      my Str $np = $*work-data<name-prefix>;
      $rname ~~ s:i/^ $np //;
      $rname = $*work-data<raku-package> ~ '::' ~ $rname;
      $!map{$ctype} = %(
        :sname("N-$ctype"),
        :$rname,
        :gir-type<record>,
        :symbol-prefix(
           $symbol-prefix ~ '_' ~ ($attrs<c:symbol-prefix> // '') ~ '_'
        ),
        :class-file($fname),
        :$deprecated,
      );
    }

    when 'callback' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      $!map{$ctype} = %(
        :rname($attrs<name>),
        :gir-type<callback>,
        :class-file($fname),
        :$deprecated,
      );
    }

    when 'bitfield' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      $!map{$ctype} = %(
        :rname($ctype),
        :gir-type<bitfield>,
        :class-file($fname),
        :$deprecated,
      );
    }

    when 'docsection' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      $!map{$attrs<name>} = %(
        :rname($attrs<name>),
        :gir-type<docsection>,
        :class-file($fname),
        :$deprecated,
      );
    }

    when 'union' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      my Str $rname = $ctype;
      my Str $np = $*work-data<name-prefix>;
      $rname ~~ s:i/^ $np //;
      $rname = $*work-data<raku-package> ~ '::' ~ $rname;
      $!map{$ctype} = %(
        :sname("N-$ctype"),
        :$rname,
        :gir-type<union>,
        :class-file($fname),
        :$deprecated,
      );
    }

    # 'enum'
    when 'enumeration' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      $!map{$ctype} = %(
        :rname($ctype),
        :gir-type<enumeration>,
        :class-file($fname),
        :$deprecated,
      );
    }

    # 'role'
    when 'interface' {
      my Str $fname = self!get-source-file($element);
      $deprecated = ($fname eq 'deprecated');
      $!map{$ctype} = %(
        :gir-type<interface>, :!leaf,
        :rname($*work-data<raku-package> ~ '::' ~ $attrs<name>),
        :symbol-prefix($symbol-prefix ~ '_' ~ $attrs<c:symbol-prefix> ~ '_'),
        :class-file($fname),
        :$deprecated,
      );
    }

    # '#define'
    when 'function-macro' { }

    default {
      print 'Missed an element type: ', .note;
    }
  }

#`{{
note "$?LINE $ctype, $attrs.gist()" if $ctype = 'record';
  $!map{$ctype}<deprecated> = True
    if $attrs<deprecated>:exists and $attrs<deprecated> == 1;
  }
}}

  $deprecated
}

#-------------------------------------------------------------------------------
method !is-inheritable( Str $classname --> Bool ) {

  # Only inherit within the gtk packages
  return False unless $*work-data<raku-package> ~~ m/^ Gnome '::' Gtk /;

  # Current widget should not be a GtkWidget
  return False if $classname eq 'GtkWidget';

  self!is-inheritable-r($classname);
}

#-------------------------------------------------------------------------------
method !is-inheritable-r ( Str $classname --> Bool ) {

  my Str $parent = $!map{$classname}<parent-gnome-name> // '-';

  return True if $parent eq 'GtkWidget';
  return False if $parent ~~ m/ GInitiallyUnowned || GObject || '-' /;

  self!is-inheritable-r($parent);
}

#-------------------------------------------------------------------------------
method !get-source-file( XML::Element:D $element --> Str ) {
  my Str $fname = 'undefined-module-name';

  for <source-position doc> -> $tag-name {
    my XML::Element $sp = $!xp.find( $tag-name, :start($element), :!to-list);

    if ?$sp {
      # get name of file, drop extension and remove a few letters from front
      $fname = $sp.attribs<filename>;
      if $fname ~~ m/ deprecated / {
        $fname = 'deprecated';
      }

      else {
        $fname = $fname.IO.basename;
        $fname ~~ s/ \. <-[\.]>+ $//;

        # In Gtk and Gdk for version 3, the filenames are having the prefix
        # gtk or gdk before it
        if $*gnome-package.Str ~~ any(<Gtk3 Gdk3>) {
          my $name-prefix = $*work-data<name-prefix>;
          $fname ~~ s/^ $name-prefix //;
        }
      }

      last;
    }
  }

  $fname
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
    when / Pixbuf / {
      $gnome-name = "Gdk$naked-gnome-name";
    }

    when ?$naked-gnome-name {
      $gnome-name = "{ S/ \d $// with $*gnome-package.Str }$naked-gnome-name";
      $raku-name = "Gnome::{$*gnome-package.Str}::$naked-gnome-name";
    }
  }

#note "$?LINE $naked-gnome-name, $gnome-name, $raku-name";

  ( $gnome-name, $raku-name)
}

#-------------------------------------------------------------------------------
method !save-map ( ) {

  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  note "Save object map in '$fname'" if $*verbose;
  $fname.IO.spurt(save-yaml($!map));
}

#-------------------------------------------------------------------------------
method load-gir-file ( ) {
  my Str $file = $*work-data<gir>;
  $!xp .= new(:$file);
}

#-------------------------------------------------------------------------------
method load-map (
  $object-map-path, Str :$repo-file = 'repo-object-map.yaml' --> Hash
) {

#  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  my $fname = $object-map-path ~ $repo-file;
#  note "Load object map from '$fname'" if $*verbose;
  if $fname.IO.r {
    load-yaml($fname.IO.slurp)
  }

  else {
    %()
  }
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
