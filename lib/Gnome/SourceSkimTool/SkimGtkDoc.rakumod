
use XML;
use XML::XPath;
use YAMLish;

#use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Code;


#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Code $!mod;

has Hash $!map;
has Hash $!other;
has XML::XPath $!xp;

has Hash $!fname-class;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

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

  $!fname-class = %();

  $!mod .= new; #(:$!xpath);
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
    # element is deprecated or is a *class, *iface or *private type.
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
        note "Save class $name" if $*verbose;
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
        note "Save record $name" if $*verbose;
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
        note "Save union $name" if $*verbose;
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
        note "Save interface $name" if $*verbose;
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

  # Set the map entry in $*object-maps with up to date data so it
  # does not get loaded when searching for names
  my Str $map-name = S/ \d+ $// with $*gnome-package.Str;
  $*object-maps{$map-name} := $!map;

  # Check all roles for this class
  for @($!map{$entry-name}<roles>) -> $role-class-name {
#    my Str $role-name = S:g/ '::' \w+ // with $role-class-name;
#    my Hash $role-h = $!mod.search-name($role-name);

    # Never implement deprecated roles
    self!check-parent-role( $entry-name, $role-class-name);
#      unless ?$role-h<deprecated>;
  }
}

#-------------------------------------------------------------------------------
method !check-parent-role ( Str $entry-name, Str $role-class-name ) {
  my $parent-entry = $!map{$entry-name}<parent-gnome-name>;

  # Stop when parent is GObject or GInitiallyUnowned. They have
  # no roles implemented
  if !$parent-entry or ($parent-entry ~~ any(<GObject GInitiallyUnowned>)) {
    self.implement-role( $entry-name, $role-class-name);
  }

  # Search using parent entry when role name is found in roles array
  elsif ?$parent-entry and
        ?$!map{$parent-entry}<roles>.first($role-class-name)
  {
    self!check-parent-role( $parent-entry, $role-class-name);
  }

  # If not found in parents role array then this class must implement it
  else {
    self.implement-role( $entry-name, $role-class-name);
  }
}

#-------------------------------------------------------------------------------
# Add role to be implemented by this class
method implement-role ( Str $entry-name, Str $role-class-name) {
  # Add array unless it exists
  $!map{$entry-name}<implement-roles> = []
    unless $!map{$entry-name}<implement-roles>:exists;

  # Add role name unless done before
  unless $!map{$entry-name}<implement-roles>.first($role-class-name) {
    $!map{$entry-name}<implement-roles>.push: $role-class-name;
    self.set-implentors( $entry-name, $role-class-name);
  }
}

#-------------------------------------------------------------------------------
# Add implementor to the role
method set-implentors ( Str $entry-name, Str $role-class-name is copy ) {
  my Str $raku-package = $*work-data<raku-package>;
  my Hash $role-h = $!mod.search-name($role-class-name);
  if ?$role-h {
    my Str $gnome-name = $role-h<gnome-name>;

    # Add array unless it exists
    $!map{$gnome-name}<implementors> = []
      unless $!map{$gnome-name}<implementors>:exists;

    # Add implementor name unless done before
    unless
      $!map{$gnome-name}<implementors>.first($!map{$entry-name}<class-name>)
    {
      $!map{$gnome-name}<implementors>.push: $!map{$entry-name}<class-name>;
    }
  }
}

#-------------------------------------------------------------------------------
# Make a map of function, class and structure names to Raku names. Add some
# extra notes like type and location in hierarchy tree. Return True when element
# is deprecated or is a class, iface or private type
method !map-element (
  XML::Element $element, Str $namespace-name,
  Str $symbol-prefix is copy, Str $id-prefix
  --> Bool
) {
#  my Str $map-name = S/ \d+ $// with $*gnome-package.Str;
  my Bool $deprecated = False;
  my Str (
    $source-filename, $module-filename, $structure-filename,
    $class-name, $gnome-name, $structure-name,
  );

  # Get attribute hash
  my Hash $attrs = $element.attribs;

  # Return if element is marked as disguised. We don't need those.
  return True if $attrs<disguised>:exists and $attrs<disguised> == 1;

  # Map key from some sort of identifier
  my Str $ctype = $attrs<c:type> //           # Most cases
                  $attrs<glib:type-name> //   # Some classes
                  $attrs<c:identifier> //     # Functions
                  $attrs<name> // ''          # Doc sections
                  ;
  # Return when an element ends in specific words.
  return True if $ctype ~~ m/ [ Private || Class || Iface ] $/;

  # Check for this id. If undefined make some noise and return
  unless ?$ctype {
    note "\nNO IDENTIFIER FOUND FOR tag $element.name(); ", $attrs.gist;
    return True;
  }

  $gnome-name = $ctype;
  $symbol-prefix = [~] $symbol-prefix, '_', $attrs<c:symbol-prefix> // '', '_';
  $symbol-prefix ~~ s/^ 'g,glib' /g/;
#note "$?LINE $symbol-prefix";

  # Gather data depending on the tag type
  given $element.name {
    when 'class' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if ( $deprecated and $attrs<name> ne 'Misc' );

      $class-name = $*work-data<raku-package> ~ '::' ~ $attrs<name>;
      $module-filename = "$*work-data<result-mods>$attrs<name>.rakumod";
      self!map-class-to-fname( $source-filename, $attrs<name>);

      my @roles = ();
      for $!xp.find( 'implements', :start($element), :to-list) -> $ie {
        # Roles with a dot in the name come from other packages
        # snd must be implemented there.
        my Str $role-name = $ie.attribs<name>;
#note "$?LINE $map-name, $role-name";
        unless $role-name ~~ m/ '.' / {
          @roles.push: $*work-data<raku-package> ~ '::R-' ~ $role-name; #"$map-name$role-name";
        }
      }

      my Str ( $parent-gnome-name, $parent-raku-name ) =
         self!set-names($attrs<parent> // '');

#note "\n$?LINE {$element.attribs()<name>}, $module-filename";

      $!map{$ctype} = %(
        :gir-type<class>,

        :$source-filename,
        :$module-filename,
        :$class-name,
        :$gnome-name,

        :$parent-raku-name, :$parent-gnome-name, :@roles,
        :$symbol-prefix,
      );
    }

    # 'role'
    when 'interface' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

      my Str $np = $*work-data<name-prefix>;

      $class-name = $*work-data<raku-package> ~ '::R-' ~ $attrs<name>;
      $module-filename = "$*work-data<result-mods>R-$attrs<name>.rakumod";
      self!map-class-to-fname( $source-filename, $attrs<name>);

      $!map{$ctype} = %(
        :gir-type<interface>,

        :$source-filename,
        :$module-filename,
        :$class-name,
        :$gnome-name,

        :$symbol-prefix,
      );
    }

    # 'struct'
    when 'record' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

#      my Str $np = $*work-data<name-prefix>;
#      my Str $record-prefix = 'N-';
#      $class-name ~~ s:i/^ $np //;
      my Str $container-class = $source-filename.tc;
      my Str $record-class = "N-$ctype";
      $class-name = [~] $*work-data<raku-package>, '::', $container-class;

#      $module-filename = "$*work-data<result-mods>$attrs<name>.rakumod";
#      $structure-name = "$*work-data<raku-package>::N-$ctype";
#      $structure-name = [~] $*work-data<raku-package>, '::', $container-class,
#                        '::', $record-prefix, ;
#      $structure-filename = [~] $*work-data<result-mods>, '/', $container-class,
#                                '/', $record-class, '.rakumod';

      $!map{$ctype} = %(
        :gir-type<record>,

        :$source-filename,
#        :$module-filename,
        :$class-name,
        :$gnome-name,
#        :$structure-name,
#        :$structure-filename,
        :$container-class,
        :$record-class,

        :$symbol-prefix,
      );
    }

    when 'union' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

#      my Str $np = $*work-data<name-prefix>;
#      $class-name = $ctype;
#      $class-name ~~ s:i/^ $np //;
#      $class-name = $*work-data<raku-package> ~ '::' ~ $class-name;
      my Str $container-class = $source-filename.tc;
      my Str $union-class = "N-$ctype";
      $class-name = [~] $*work-data<raku-package>, '::', $container-class;

#      $module-filename = "$*work-data<result-mods>$attrs<name>.rakumod";
#      $structure-name = "$*work-data<raku-package>::N-$ctype";
#      $structure-filename = "$*work-data<result-mods>N-$ctype.rakumod";
#      $structure-filename = [~] $*work-data<result-mods>, '/', $container-class,
#                                '/', $union-class, '.rakumod';

      $!map{$ctype} = %(
        :gir-type<union>,

        :$source-filename,
#        :$module-filename,
        :$class-name,
        :$gnome-name,
#        :$structure-name,
#        :$structure-filename,
        :$container-class,
        :$union-class,

        :$symbol-prefix,
      );
    }

    # The functions popping up here are callables defined outside class,
    # interface, record or union. The functions must be added to a type module
    when 'function' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

      my Str $type-name = $*work-data<gnome-name>;
      my Str $name-prefix = $*work-data<name-prefix>;
      $type-name ~~ s:i/^ $name-prefix //;
      $type-name = 'T-' ~ $type-name;
#      $module-filename = "$*work-data<result-mods>$type-name.rakumod";
      $class-name = $*work-data<raku-package> ~ '::' ~ $type-name;

      my Str $function-name = $attrs<name>;
#      $function-name ~~ s:g/ '_' /-/;

      $!map{$ctype} = %(
        :gir-type<function>,

        :$source-filename,
#        :$module-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
        :$function-name,
      );
    }

    when 'constant' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

      # Search for type elements in constant
      my Hash $const-type-attribs;
      for $element.nodes -> $n {
        if $n ~~ XML::Element and $n.name eq 'type' {
          # Get the type and c:type attributes
          $const-type-attribs = $n.attribs;
          last;
        }
      }

      my Str $type-name = $*work-data<gnome-name>;
      my Str $name-prefix = $*work-data<name-prefix>;
      $type-name ~~ s:i/^ $name-prefix //;
      $type-name = 'T-' ~ $type-name;
#      $module-filename = "$*work-data<result-mods>$type-name.rakumod";
      $class-name = $*work-data<raku-package> ~ '::' ~ $type-name;

      $!map{$ctype} = %(
        :gir-type<constant>,

        :$source-filename,
#        :$module-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
        :constant-type($const-type-attribs<c:type>),
        :constant-value($attrs<value>),
      );
    }

    # 'enum'
    when 'enumeration' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

      my Str $type-name = $*work-data<gnome-name>;
      my Str $name-prefix = $*work-data<name-prefix>;
      $type-name ~~ s:i/^ $name-prefix //;
      $type-name = 'T-' ~ $type-name;
#      $module-filename = "$*work-data<result-mods>$type-name.rakumod";
      $class-name = $*work-data<raku-package> ~ '::' ~ $type-name;

      $!map{$ctype} = %(
        :gir-type<enumeration>,

        :$source-filename,
#        :$module-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
      );
    }

    when 'bitfield' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

      my Str $type-name = $*work-data<gnome-name>;
      my Str $name-prefix = $*work-data<name-prefix>;
      $type-name ~~ s:i/^ $name-prefix //;
      $type-name = 'T-' ~ $type-name;
#      $module-filename = "$*work-data<result-mods>$type-name.rakumod";
      $class-name = $*work-data<raku-package> ~ '::' ~ $type-name;

      $!map{$ctype} = %(
        :gir-type<bitfield>,

        :$source-filename,
#        :$module-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
      );
    }

    when 'docsection' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

#      $class-name = $source-filename.tc;
#      $class-name = $*work-data<raku-package> ~ '::T-' ~ $class-name;

      $module-filename = "$*work-data<result-mods>D-$attrs<name>.rakumod";

      $!map{$attrs<name>} = %(
        :gir-type<docsection>,

        :$source-filename,
        :$module-filename,
#        :$class-name,
        :$gnome-name,
      );
    }

    when 'callback' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

      my Str $callback-name = $attrs<name>;
      $!map{$ctype} = %(
        :gir-type<callback>,

        :$source-filename,
        :$gnome-name,
        :$callback-name,
      );
    }

    # 'typedef'
    when 'alias' {
      $source-filename = self!get-source-file($element);
      $deprecated = ($source-filename eq 'deprecated');
      return $deprecated if $deprecated;

      my Hash $alias-type-attribs;
      for $element.nodes -> $n {
        if $n ~~ XML::Element and $n.name eq 'type' {
          $alias-type-attribs = $n.attribs;
          last;
        }
      }

      $!map{$ctype} = %(
        :gir-type<alias>,

        :$source-filename,

        :cname($alias-type-attribs<c:type>),
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
  my Str $module-filename = 'undefined-module-name';

  for <source-position doc> -> $tag-name {
    my XML::Element $sp = $!xp.find( $tag-name, :start($element), :!to-list);

    if ?$sp {
      # get name of file, drop extension and remove a few letters from front
      $module-filename = $sp.attribs<filename>;
      if $module-filename ~~ m/ deprecated / {
        $module-filename = 'deprecated';
      }

      else {
        $module-filename = $module-filename.IO.basename;
        $module-filename ~~ s/ \. <-[\.]>+ $//;

        # In Gtk and Gdk for version 3, the filenames are having the prefix
        # 'gtk' or 'gdk' before it. Glib, GObject and Gio has a 'g' prefixed.
        if $*gnome-package.Str ~~ any(<Gtk3 Gdk3 Glib GObject Gio Atk Pango>) {
          my $name-prefix = $*work-data<name-prefix>;
          $module-filename ~~ s/^ $name-prefix <[_-]>? //;
        }
      }

      last;
    }
  }

  $module-filename
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
  note "Save object map" if $*verbose;
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
method !map-class-to-fname ( $filename, $class-name ) {
  unless $!fname-class{$filename}:exists {
    $!fname-class{$filename} = $class-name;
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
      note "Save $section" if $*verbose;
      $xml-file.IO.spurt($content);
    }
  }
}
