
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
        $!other<interface>.push: $element;
      }
    }

#note "$?LINE: $namespace-name, $symbol-prefix, $id-prefix";
    self!map-element( $element, $namespace-name, $symbol-prefix, $id-prefix);
  }

  # Before we save the map find out which classes are at the bottom (≡ leaf)
  # Also we want to know which classes will be inheritable
  for $!map.keys -> $entry-name {
    # Skip all other types
    next unless $!map{$entry-name}<gir-type> eq 'class';
    $!map{$entry-name}<inheritable> = self!is-inheritable($entry-name);

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
#  note "$?LINE: ", $element.name, ', ', $attrs<name> if $*verbose;

  given $element.name {
    when 'class' {
      my @roles = ();
      for $!xp.find( 'implements', :start($element), :to-list) -> $ie {
        @roles.push: $ie.attribs<name>;
      }
          
      my Str ( $parent-gnome-name, $parent-raku-name ) =
         self!set-names($attrs<parent> // '');

#`{{
      my Bool $inheritable = False;
      $inheritable = True if $attrs<c:type> ne 'GtkWidget'
                     and $*work-data<raku-package> ~~ m/ '::Gtk' /;
}}

      $!map{$attrs<c:type> // $attrs<glib:type-name>} = %(
        :rname($*work-data<raku-package> ~ '::' ~ $attrs<name>),
        :$parent-raku-name, :$parent-gnome-name, :@roles,
        :symbol-prefix($symbol-prefix ~ '_' ~ $attrs<c:symbol-prefix> ~ '_'),
#        :inheritable(self!is-inheritable($element)),
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
      my XML::Element $d = $!xp.find( 'doc', :start($element));
      my $d-filename = '';
      $d-filename = $d.attribs<filename>.IO.basename if ?$d;
      $d-filename ~~ s/ \. <-[\.]>+ $//;
      $!map{$attrs<c:type>} = %(
        :rname($attrs<c:type>), # keep name as c:type not name!
        :gir-type<bitfield>,
        :class-file($d-filename),
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
      my XML::Element $d = $!xp.find( 'doc', :start($element));
      my $d-filename = '';
      $d-filename = $d.attribs<filename>.IO.basename if ?$d;
      $d-filename ~~ s/ \. <-[\.]>+ $//;
      $!map{$attrs<c:type>} = %(
        :rname($attrs<c:type>), # keep rname as c:type not name!
        :gir-type<enumeration>,
        :class-file($d-filename),
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
#note "test inherit $classname -> $parent";
  return True if $parent eq 'GtkWidget';
  return False if $parent ~~ m/ GInitiallyUnowned || GObject || '-' /;

  self!is-inheritable-r($parent);
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

#-------------------------------------------------------------------------------
method load-map (
  $object-map-path, Str :$repo-file = 'repo-object-map.yaml' --> Hash
) {

#  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  my $fname = $object-map-path ~ $repo-file;
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
