
use XML;
use XML::XPath;
use YAMLish;

#use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Resolve;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGirSource:auth<github:MARTIMM>;

#has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Resolve $!solve;

has Hash $!map;
has Hash $!other;
has XML::XPath $!xp;

has Hash $!fname-class;
has Instant $!gir-modification-time;
has Gnome::SourceSkimTool::Code $!code;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  # the sections like :function are arrays of XML::Element's
  $!other = %(
    :function([]),
    :callback([]),
    :bitfield([]),
    :enumeration([]),
    :constant([]),
    :docsection([]),
  );

  $!fname-class = %();

#  $!mod .= new;
  $!solve .= new;
  
  $!code .= new(:skim-init);
}

#-------------------------------------------------------------------------------
method make-subgirs-from-gir ( Str $module = '' ) {

  # Make start of xml by taking the <package> and <namespace> elements.
  # some gir files mention two packages. we take only one
  my XML::Element $e = $!xp.find( '/repository/package', :to-list)[0];
  my Str $xml-namespace = self!devise-xml-namespace;

  $e = $!xp.find( '/repository/namespace');
  my $attribs = $e.attribs;
  $*namespace-name = $attribs<name>;
  $*symbol-prefix = $attribs<c:symbol-prefixes>;
  $*lib-version = $attribs<version>;

  # Glib strays of from standard, must correct it. Gio and GObject are correct
  $*symbol-prefix ~~ s/^ g <[.,]> .* /g/;

  my Str $id-prefix = $attribs<c:identifier-prefixes>;

  # Gather all data
  my @elements = ($!xp.find( '/repository/namespace/*', :to-list));
  for @elements -> $element {

    my $attrs = $element.attribs;
    my Str $element-name = self.test-for-oddities( $element.name, $attrs);
#note "$?LINE $attrs.gist(), $element-name";

    # Ignore the entry when the item is moved to some other module
    next if $attrs<moved-to>:exists;
    next if $attrs<introspectable>:exists and $attrs<introspectable> eq 0;
    next if $attrs<disguised>:exists and $attrs<disguised> == 1;
    next if $element-name ~~ m/^ glib \:/;

    my Str $name = self!check-pixbuf($attrs<name>);
    if $name ~~ m/ [ Class || Private || Iface || Interface ] $/ {
#      note "$?LINE $name, $attrs.gist(), $element.name()";
      next;
    }

    # If module defined then skip all but this module
    if ?$module {
      if $module !~~ m/$name/ {
        next;
      }
    }
#note "$?LINE $name, $element-name";

    # Map an element into the repo-object-map.
    self!map-element( $element, $*namespace-name, $*symbol-prefix, $id-prefix);
#    my Str $element-name = self.test-for-oddities( $element.name, $attrs);
#next unless $element-name eq 'class';
#  }

#  # Use the data to generate gir and yaml files
#  for @elements -> $element {
#    my $attrs = $element.attribs;

#    # Ignore the entry when the item is moved to some other module
#    next if $attrs<moved-to>:exists;
#    my Str $element-name = self.test-for-oddities( $element.name, $attrs);
    given $element-name {
      # Save the class info in separate gir files
      when 'class' {
        my Str $name = self!check-pixbuf($attrs<name>);
#note "$?LINE $name";
#next unless $name eq 'AboutDialog';
        my $xml-file = "$*work-data<gir-module-path>C-$name.gir";
#`{{
}}
        if ($xml-file.IO ~~ :!e) or
           ($xml-file.IO.modified > $!gir-modification-time)
        {
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

          if $element.name ne 'class' {
            $xml ~~ s/ '<interface ' /\<class /;
            $xml ~~ s/ \<\/interface\> /\<\/class\>/;
          }
#`{{
}}
          note "Save class $name" if $*verbose;
          $xml-file.IO.spurt($xml);
#TODO write-yaml must be called later. Need gir files, still to be written!!!!!!!
#          self!write-yaml( $xml-file, $xml, $element-name);
        }
      }

      # Records are structures in C. There are fields for the structure,
      # constructors, methods and functions.
      when 'record' {
        my Str $name = self!check-pixbuf($attrs<name>);
        my $xml-file = "$*work-data<gir-module-path>R-$name.gir";
#`{{
}}
        if ($xml-file.IO ~~ :!e) or
           ($xml-file.IO.modified > $!gir-modification-time)
        {
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
#`{{
}}
          note "Save record R-$name" if $*verbose;
          $xml-file.IO.spurt($xml);
#          self!write-yaml( $xml-file, $xml, $element-name);
        }
      }

      when 'union' {
        my Str $name = self!check-pixbuf($attrs<name>);
        if ?$name {
          my Str $name-prefix = $*work-data<name-prefix>;
          $name ~~ s:i/^ $name-prefix //;

          my $xml-file = "$*work-data<gir-module-path>U-$name.gir";
#`{{
}}
          if ($xml-file.IO ~~ :!e) or
            ($xml-file.IO.modified > $!gir-modification-time)
          {
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
#`{{
}}
            note "Save union U-$name" if $*verbose;
            $xml-file.IO.spurt($xml);
#            self!write-yaml( $xml-file, $xml, $element-name);
          }
        }
      }

      when 'interface' {
        my Str $name = self!check-pixbuf($attrs<name>);
        my $xml-file = "$*work-data<gir-module-path>I-$name.gir";
#`{{
}}
        if ($xml-file.IO ~~ :!e) or
           ($xml-file.IO.modified > $!gir-modification-time)
        {
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
#`{{
}}
          note "Save interface I-$name" if $*verbose;
          $xml-file.IO.spurt($xml);
#          self!write-yaml( $xml-file, $xml, $element-name);
        }
      }

      # Only stand alone functions. Functions within other
      # elements are not saved here.
      when 'function' {
        $!other<function>.push: $element;
      }

      when 'constant' {
        $!other<constant>.push: $element;
      }

      when 'docsection' {
        $!other<docsection>.push: $element;
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
    }
  }

  # Find out which classes will be inheritable. It is now decided to only
  # have decendents from GtkWidget be able to inherit.
  #
  # The classes which implement a role (a C-interface) must be checked if the
  # parent has also the same role. Only the top most class can implement this
  # role in Raku. All decendents will have access to the methods and signals
  # defined in that role.
  for $!map.keys -> $entry-name {
    next unless $!map{$entry-name}<gir-type>:exists;

    # A type name is the bare name of an object without any prefixes of gnome.
    # Those are found on class, interface, record and union. The rest of the
    # gir types must read it from the filename map created above while
    # processing the XML. There are situations where there are only simple
    # types defined in the sources and a name must be created from the source
    # filename with its first letter uppercased.
    my Str $type-name =
      $!fname-class{$!map{$entry-name}<source-filename>} //
        $!map{$entry-name}<source-filename>.tc;

    if $!map{$entry-name}<gir-type> ~~ any(
         <function constant enumeration bitfield docsection callback>
       ) {
      $!map{$entry-name}<type-name> //= $type-name;
      $!map{$entry-name}<type-letter> //= 'T';
    }

    elsif $!map{$entry-name}<gir-type> eq 'class' {
      $!map{$entry-name}<inheritable> = self!is-inheritable($entry-name);
      self!set-real-role-user($entry-name) if $!map{$entry-name}<roles>;
    }

    if $!map{$entry-name}<gir-type> ~~ any(
         <function constant enumeration bitfield docsection callback>
    ) {
       my Str $type-name = $!map{$entry-name}<source-filename>;
       $!map{$entry-name}<type-letter> = 'T';
    }

    # else {} ignore rest
  }

  self!save-other($xml-namespace);
#  self.save-map;
}

#-------------------------------------------------------------------------------
method !devise-xml-namespace ( --> Str ) {
  # Create start of xml by taking the <package> and <namespace> elements.
  # some gir files mention two packages. we take only one
  my XML::Element $e = $!xp.find( '/repository/package', :to-list)[0];
  my Str $xml-namespace = "  $e.Str()\n      <namespace\n";

  # Get info from namespace
  $e = $!xp.find( '/repository/namespace');

  # Add attributes to the xml start
  my $attribs = $e.attribs;
  for $attribs.kv -> $k, $v {
    $xml-namespace ~= "            $k=\"$v\"\n";
  }
  $xml-namespace ~= "      >\n";

  $xml-namespace
}

#-------------------------------------------------------------------------------
method make-yaml-from-subgirs ( Str $module = '' ) {
  #self.load-map;

#note "$?LINE $*work-data<gir-module-path>";

  for dir($*work-data<gir-module-path>).sort -> $xml-file {
    next if $xml-file.Str ~~ m/^ repo '-' /;
    next if $xml-file.Str !~~ m/ \. gir $/;

    # If module defined then skip all but this module
    if ?$module {
      my Str $bname = $xml-file.basename;

      # Basename still has .gir at the end.
      if $bname !~~ m/$module \. gir $/ {
        next;
      }
    }

    my Str $xml = $xml-file.IO.slurp;
    $!xp .= new(:$xml);

    # Needed when previous calls are skipped
    unless $*namespace-name {
      my XML::Element $e = $!xp.find( '/repository/namespace');
      my $attribs = $e.attribs;
      $*namespace-name = $attribs<name>;
      $*symbol-prefix = $attribs<c:symbol-prefixes>;
      $*lib-version = $attribs<version>;
    }

    # There should only be one element
    my @elements = ($!xp.find( '/repository/namespace/*', :to-list));

    for @elements -> $element {
      next unless $element.name ~~ any(<class interface record union>);
      my $attrs = $element.attribs;
      my Str $element-name = $element.name;
      self!write-yaml( $xml-file, $xml, $element-name, $module);
    }
  }

#`{{
  # Find out which classes will be inheritable. It is now decided to only
  # have decendents from GtkWidget be able to inherit.
  #
  # The classes which implement a role (a C-interface) must be checked if the
  # parent has also the same role. Only the top most class can implement this
  # role in Raku. All decendents will have access to the methods and signals
  # defined in that role.
  for $!map.keys -> $entry-name {
    next unless $!map{$entry-name}<gir-type>:exists;

    # A type name is the bare name of an object without any prefixes of gnome.
    # Those are found on class, interface, record and union. The rest of the
    # gir types must read it from the filename map created above while
    # processing the XML. There are situations where there are only simple
    # types defined in the sources and a name must be created from the source
    # filename with its first letter uppercased.
    my Str $type-name =
      $!fname-class{$!map{$entry-name}<source-filename>} //
        $!map{$entry-name}<source-filename>.tc;

    if $!map{$entry-name}<gir-type> ~~ any(
         <function constant enumeration bitfield docsection callback>
       ) {
      $!map{$entry-name}<type-name> //= $type-name;
      $!map{$entry-name}<type-letter> //= 'T';
    }

    elsif $!map{$entry-name}<gir-type> eq 'class' {
      $!map{$entry-name}<inheritable> = self!is-inheritable($entry-name);
      self!set-real-role-user($entry-name) if $!map{$entry-name}<roles>;
    }

    if $!map{$entry-name}<gir-type> ~~ any(
         <function constant enumeration bitfield docsection callback>
    ) {
       my Str $type-name = $!map{$entry-name}<source-filename>;
       $!map{$entry-name}<type-letter> = 'T';
    }

    # else {} ignore rest
  }

  self!save-other($xml-namespace);
  self!save-map;
}}
}

#-------------------------------------------------------------------------------
method !write-yaml (
  Str() $xml-file, Str $xml, Str $element-name, Str $module = ''
) {

  # Get previously saved yaml data of element
  my $yaml-file = $xml-file;
  $yaml-file ~~ s/ \. gir $/.yaml/;
  my Hash $element-data = %();
  $element-data = load-yaml($yaml-file.IO.slurp) if $yaml-file.IO ~~ :r;
#note "$?LINE $element-data.keys.gist()";
  # Add/Change new data in 
  my XML::XPath $xp .= new(:$xml);
  if self!get-data( $xp, $element-data, $element-name, $module) {
    # Save data if data is meaningful
    note "Write $element-name to $yaml-file.IO.basename()" if $*verbose;
    $yaml-file.IO.spurt(save-yaml($element-data));
  }
}

#-------------------------------------------------------------------------------
method !get-data (
  XML::XPath $xp, Hash $element-data,
  Str $element-name, Str $module = ''
  --> Bool
) {
  # Setup basic info
  $element-data<version> = $*lib-version;
  $element-data<namespace-name> = $*namespace-name;
  $element-data<symbol-prefix> = $*symbol-prefix;

  # Search for the name
  my XML::Element $element = $xp.find('//' ~ $element-name);
  die "$element-name not found" unless ?$element;

  # Get the attributes
  my Hash $attrs = $element.attribs;

  # Return if element is marked as disguised. We don't need those.
  return False if $attrs<disguised>:exists and $attrs<disguised> == 1;

  # Map key from some sort of identifier
  my Str $ctype = self!get-name($attrs);
  my Str $raku-type =$ctype;
  $raku-type ~~ s/^ $*namespace-name//;

  # Return when an element ends in specific words. Most of those are records.
  return False if $ctype ~~ m/ [ Private || Class || Iface || Interface ] $/;

  note "\nProcessing $raku-type" if $*verbose;

  # Get Hash of current object
  $element-data{$raku-type} //= %();
  my Hash $ed-name = $element-data{$raku-type};

  # Get detected info and merge
  for $!map{$ctype}.kv -> $k, $v {
    $ed-name{$k} //= $v;
  }

  $ed-name<parent> = $attrs<parent>;
  $ed-name<version> = $attrs<version> if ?$attrs<version>;
  $ed-name<checks> //= %(
    :handcorrected-docs(0), :enough-tests(0),
    :nbr-tests(0), :no-implement(0)
  );
# temporary
#$ed-name<checks><enough-tests> = 0;
#note "$?LINE $ed-name<checks>.raku()";

  $ed-name<checks><nbr-tests> = self!get-nbr-tests( $ed-name, $module);

  # Check for module file to set $modules-generated
  my Str $prefix = $ed-name<type-letter>:exists
        ?? $ed-name<type-letter> ~ '-' !! '';
  my Str $lib-path =
    [~] $*api2root, 'gnome-', $*gnome-package.Str.lc, '/lib/Gnome/';
  my Int $modules-generated =
    "$lib-path$*gnome-package.Str()/$prefix$raku-type.rakumod".IO.r ?? 1 !! 0;
  $ed-name<checks><modules-generated> = $modules-generated;

  # Fill in some missing data before calling for routine search. The used call
  # .get-native-subs() from Gnome::SourceSkimTool::Code is used to generate
  # code, doc and tests. The init is a bit different, hence the missing values.
  $*work-data<gnome-name> = $ed-name<gnome-name>;
  $*work-data<raku-name> = $ed-name<class-name>;
  $*work-data<sub-prefix> = $ed-name<symbol-prefix>;

  $ed-name<routines> //= %();
  my Hash $routines = $ed-name<routines>;
  my Hash $r = self!get-routines( $xp, $element, $raku-type);
  for $r.keys -> $rtype {
    for $r{$rtype}.keys -> $rname {
      my Hash $rdata = $r{$rtype}{$rname};

      # Copy all fields if they aren't there
      for $rdata.keys -> $rfield {
        $routines{$rtype}{$rname}{$rfield} = $rdata{$rfield};
      }

      # Only missing-type = True is stored
      my Int $not-missing = $rdata<missing-type>:exists ?? 0 !! 1;

      # Add field for generation info depending on 
      # missing parameters or version > first release
      $routines{$rtype}{$rname}<generated> //=
        ?$rdata<version> ?? 0 !! $not-missing +& $modules-generated +& 1;
    }
  }

  True
}

#-------------------------------------------------------------------------------
method !get-nbr-tests ( Hash $ed-name, Str $module = '' --> UInt ) {
  my UInt $tests = 0;

  my Str $test-file = $*work-data<result-tests>;
  if ?$ed-name<type-letter> {
    $test-file ~= [~] '/', $ed-name<type-letter>, '-', $module, '.rakutest';
  }

  else {
    $test-file ~= "/$module.rakutest";
  }

#note "$?LINE $*work-data.gist()\n$test-file";
  my Str $t = $test-file.IO.slurp;
  $t ~~ s:g/ '#' \` '{{' .*? '}}' //;
  $t ~~ s:g/'#' .*? $$//;
  $t ~~ s/ \= finish .* //;

  for $t.lines -> $line {
    $tests++ if $line ~~ m/^ \s* [
          ok | nok | is | isnt |
          is\-approx| is\-approx\-calculate | is\-deeply |
          cmp\-ok | isa\-ok | can\-ok | does\-ok |
          like | unlike | use\-ok | dies\-ok | lives\-ok |
          eval\-dies\-ok | eval\-lives\-ok | exits\-ok |
          throws\-like | fails\-like
        ] /;
  }

  $tests
}

#-------------------------------------------------------------------------------
method !get-routines (
  XML::XPath $xp, XML::Element $element, Str $raku-type --> Hash
) {
  my Hash $routines = %();
  $routines<constructors> =
    $!code.get-native-subs( $element, $xp, :routine-type<constructor>);
  $routines<methods> =
    $!code.get-native-subs( $element, $xp, :routine-type<method>);
  $routines<functions> =
    $!code.get-native-subs( $element, $xp, :routine-type<function>);
  
  for <constructors methods functions> -> $rtype {
    for $routines{$rtype}.keys -> $rname {
      my Hash $rdata = $routines{$rtype}{$rname};

      # Remove empty version fields. These have the version from the
      # start of the distribution. E.g. Gtk4 has version 4.0 at the start.
      $rdata<version>:delete unless ?$rdata<version>;

      # Always remove deprecated, deprecated-version is sufficient.
      $rdata<deprecated>:delete;
      $rdata<deprecated-version>:delete unless $rdata<deprecated-version>;

      # Other fields not needed when False, empty, or missing.
      $rdata<missing-type>:delete unless $rdata<missing-type>;
      $rdata<variable-list>:delete unless $rdata<variable-list>;
    }
  }

  for $routines<constructors>.keys -> $rname {
    # Change the name of the 'new' method.
    if $rname eq 'new' {
      my $method-name = $raku-type.lc;
      $routines<constructors>{"new-$method-name"} =
        $routines<constructors>{$rname}:delete;

      # There will only be one 'new'
      last;
    }
  }

#  # The first parameter in a method in the Raku implementation is hidden
#  for $routines<methods>.keys -> $rname {
#    $routines<methods>{$rname}<parameters>.shift;
#  }

  $routines
}

#-------------------------------------------------------------------------------
method !set-real-role-user( Str $entry-name ) {

  # Set the map entry in $*object-maps with up to date data so it
  # does not get loaded when searching for names
  my Str $map-name = S/ \d+ $// with $*gnome-package.Str;
  $*object-maps{$map-name} := $!map;

  # Check all roles for this class
  for @($!map{$entry-name}<roles>) -> $role-class-name {
    self!check-parent-role( $entry-name, $role-class-name);
  }
}

#-------------------------------------------------------------------------------
method !check-parent-role ( Str $entry-name, Str $role-class-name ) {
  my $parent-entry = $!map{$entry-name}<parent-gnome-name>;
#note "$?LINE check-parent-role $entry-name, Str $role-class-name";

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
#note "$?LINE implement-role $entry-name, $role-class-name";
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
  my Hash $role-h = $!solve.search-name($role-class-name);
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
# extra notes like type and location in hierarchy tree.
# $element; toplevel at 'repository/namespace'
method !map-element (
  XML::Element $element, Str $*namespace-name,
  Str $*symbol-prefix is copy, Str $id-prefix
#  --> Bool
) {
  my Bool $deprecated;
  my Str $deprecated-version;
  my Str ( $source-filename, $class-name, $gnome-name);

  # Get attribute hash
  my Hash $attrs = $element.attribs;

#  # Return if element is marked as disguised. We don't need those.
#  return False if $attrs<disguised>:exists and $attrs<disguised> == 1;

  # Map key from some sort of identifier
  my Str $ctype = self!get-name($attrs);

#  # Return when an element ends in specific words. Most of those are records.
#  return False if $ctype ~~ m/ [ Private || Class || Iface || Interface ] $/;
#  return if $ctype ~~ m/ [ Private || Iface || Interface ] $/;

  # Check for this id. If undefined make some noise and return
  unless ?$ctype {
    note "\nNO IDENTIFIER FOUND FOR tag $element.name(); ", $attrs.gist;
    return;
  }

  $gnome-name = $ctype;
  $*symbol-prefix =
    [~] $*symbol-prefix, '_', $attrs<c:symbol-prefix> // '', '_';
  $*symbol-prefix ~~ s/^ 'g,glib' /g/;

  # Gather data depending on the tag type
  my Str $element-name = self.test-for-oddities( $element.name, $attrs);
  given $element-name {
    when 'class' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf($attrs<name>);
      $class-name = $*work-data<raku-package> ~ '::' ~ $type-name;
      self!map-class-to-fname( $source-filename, $attrs<name>);

      my @roles = ();
      for $!xp.find( 'implements', :start($element), :to-list) -> $ie {
        # Roles with a dot in the name come from other packages
        # and must be implemented there.
        my Str $role-name = $ie.attribs<name>;
        unless $role-name ~~ m/ '.' / {
          @roles.push: $*work-data<raku-package> ~ '::R-' ~ $role-name;
        }
      }

      my Str ( $parent-gnome-name, $parent-raku-name ) =
         self!set-names($attrs<parent> // '');

      $!map{$ctype} = %(
        :gir-type<class>,

        :$source-filename,
        :$class-name,
        :$gnome-name,
        :$type-name,
        :type-letter(''),

        :$parent-raku-name, :$parent-gnome-name, :@roles,
        :$*symbol-prefix,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    # 'role'
    when 'interface' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $np = $*work-data<name-prefix>;

      my Str $type-name = self!check-pixbuf($attrs<name>);
      $class-name = $*work-data<raku-package> ~ '::R-' ~ $type-name;
      self!map-class-to-fname( $source-filename, $attrs<name>);

      $!map{$ctype} = %(
        :gir-type<interface>,

        :$source-filename,
        :$class-name,
        :$gnome-name,
        :$type-name,
        :type-letter('R'),

        :$*symbol-prefix,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    # 'struct'
    when 'record' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf($attrs<name>);
      my Str $record-class = 'N-' ~ $type-name;
      my Str $name-prefix = $*work-data<name-prefix>;
      $record-class ~~ s:i/ 'N-' $name-prefix /N-/;
      $class-name = [~] $*work-data<raku-package>, '::', $record-class;
      self!map-class-to-fname( $source-filename, $attrs<name>);

      $!map{$ctype} = %(
        :gir-type<record>,

        :$source-filename,
        :$class-name,
        :$record-class,
        :$gnome-name,
        :$type-name,
        :type-letter('N'),

        :$*symbol-prefix,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    when 'union' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf($attrs<name>);
      my Str $union-class = 'N-' ~ $type-name;
      my Str $name-prefix = $*work-data<name-prefix>;
      $union-class ~~ s:i/ 'N-' $name-prefix /N-/;
      $class-name = [~] $*work-data<raku-package>, '::', $union-class;
      self!map-class-to-fname( $source-filename, $attrs<name>);

      $!map{$ctype} = %(
        :gir-type<union>,

        :$source-filename,
        :$class-name,
        :$union-class,
        :$gnome-name,
        :$type-name,
        :type-letter('N'),

        :$*symbol-prefix,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    # The functions popping up here are callables defined outside class,
    # interface, record or union. The functions must be added to a type module
    when 'function' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf($source-filename).lc;
      $class-name = $*work-data<raku-package> ~ '::' ~ 'T-' ~ $type-name;

      my Str $function-name = $attrs<name>;

      $!map{$ctype} = %(
        :gir-type<function>,

        :$source-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
        :$function-name,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    when 'constant' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      # Search for type elements in constant
      my Hash $const-type-attribs;
      for $element.nodes -> $n {
        if $n ~~ XML::Element and $n.name eq 'type' {
          # Get the type and c:type attributes
          $const-type-attribs = $n.attribs;
          last;
        }
      }

      my Str $type-name = self!check-pixbuf-type($source-filename).lc;
      $class-name = $*work-data<raku-package> ~ '::' ~ 'T-' ~ $type-name;

      $!map{$ctype} = %(
        :gir-type<constant>,

        :$source-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
        :constant-type($const-type-attribs<c:type>),
        :constant-value($attrs<value>),
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    # 'enum'
    when 'enumeration' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf-type($source-filename).lc;
      $class-name = $*work-data<raku-package> ~ '::' ~ 'T-' ~ $type-name;

      $!map{$ctype} = %(
        :gir-type<enumeration>,

        :$source-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    when 'bitfield' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf-type($source-filename).lc;
      $class-name = $*work-data<raku-package> ~ '::' ~ 'T-' ~ $type-name;

      $!map{$ctype} = %(
        :gir-type<bitfield>,

        :$source-filename,
        :$class-name,
        :$type-name,
        :$gnome-name,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    when 'docsection' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf-type($source-filename);
      $class-name = $*work-data<raku-package> ~ '::' ~ 'D-' ~ $type-name;
      $!map{$attrs<name>} = %(
        :gir-type<docsection>,

        :$type-name,
        :$class-name,
        :$source-filename,
        :$gnome-name,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    when 'callback' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

      my Str $type-name = self!check-pixbuf-type($source-filename).lc;
      $class-name = $*work-data<raku-package> ~ '::' ~ 'T-' ~ $type-name;
      my Str $callback-name = $attrs<name>;
      $!map{$ctype} = %(
        :gir-type<callback>,

        :$type-name,
        :$class-name,
        :$source-filename,
        :$gnome-name,
        :$callback-name,
      );

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    # 'typedef'
    when 'alias' {
      ( $deprecated, $deprecated-version, $source-filename) =
        self!get-source-file($element);

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

      $!map{$ctype}<deprecated> = $deprecated if $deprecated;
      $!map{$ctype}<deprecated-version> = $deprecated-version
        if ?$deprecated-version;
    }

    # '#define'
    when 'function-macro' { }

    default {
      say 'Unprocessed element type: ', $_;
    }
  }

#  $deprecated
}

#-------------------------------------------------------------------------------
method !get-name ( Hash $attrs --> Str ) {
  # Map key from some sort of identifier
  my Str $ctype = $attrs<c:type> //           # Most cases
                  $attrs<glib:type-name> //   # Some classes
                  $attrs<c:identifier> //     # Functions
                  $attrs<name> // ''          # Doc sections
                  ;

  $ctype
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
# Test for items which must be converted into another type. E.g. GFile in Gio is
# marked as an interface but there is no example of its use anywhere.
# In api<1> I already decided it to become a Raku class instead of a role.
method test-for-oddities ( Str $element-name is copy, Hash $attribs --> Str ) {
  if $*gnome-package.Str eq 'Gio' and
     $element-name eq 'interface' and 
     $attribs<name> eq 'File'
  {
    $element-name = 'class';
  }

  $element-name
}

#-------------------------------------------------------------------------------
method !get-source-file( XML::Element:D $element --> List ) {
  my Str $module-filename = 'undefined-module-name';

  my Hash $attribs = $element.attribs;
  my Bool $deprecated = ?$attribs<deprecated>;
  my Str $deprecated-version =
    $deprecated ?? $attribs<deprecated-version> !! '';

  # A filename can be found in the 'source-position' or 'doc' element
  for <source-position doc> -> $tag-name {
    my XML::Element $sp = $!xp.find( $tag-name, :start($element), :!to-list);

    if ?$sp {
      # get name of file, drop extension and remove a few letters from front
      $module-filename = $sp.attribs<filename>;
      $deprecated = True if $module-filename ~~ m/ deprecated /;

#      else {
        $module-filename = $module-filename.IO.basename;
        # drop extension and optional version postfixes
        $module-filename ~~ s/ \. <-[\.]>+ $//;
        $module-filename ~~ s/ <[-.\d]>+ $//;

        # In Gtk and Gdk for version 3 and 4, the filenames are having the
        # prefix 'gtk' or 'gdk' before it. Glib, GObject and Gio have a 'g'
        # prefixed. Graphene has 'graphene-' and GdkPixbuf has 'gdk-pixbuf-'.
        if $*gnome-package.Str ~~ any(<
          Gtk3 Gdk3 Gtk4 Gdk4 Gsk4 Glib GObject Gio Atk
          Graphene Pango PangoCairo
        >) {
          my $name-prefix = $*work-data<name-prefix>;
          $module-filename ~~ s/^ $name-prefix <[_-]>? //;
        }

        else { # GdkPixbuf
          $module-filename ~~ s/^ 'gdk-pixbuf-' //;
        }
#      }

      last;
    }
  }

  ( $deprecated, $deprecated-version, $module-filename)
}

#-------------------------------------------------------------------------------
method !check-pixbuf ( Str $name is copy --> Str ) {
#print "$?LINE $name --> ";
  given $name {
    when 'GdkPixbuf'        { $name = 'Pixbuf'; }
    when m/^ Pixbuf \w+ /   { $name ~~ s/^ Pixbuf //; }
    default                 { }
  }

#note $name;
  $name
}

#-------------------------------------------------------------------------------
method !check-pixbuf-type ( Str $source-filename ) {
  my Str $type-name;
  if $source-filename ~~ m/^ 'gdk-pixbuf' / {
    my Str $c = $source-filename;
    $c ~~ s:g/ '-' (<[a..z]>) /$0.uc()/;
    $c .= tc;
    $c ~~ s/ GdkPixbuf //;
    $type-name = ?$c ?? $c !! 'Pixbuf';
#note "$?LINE $source-filename, $c, $type-name";
  }

  else {
    $type-name = $source-filename.tc;
  }

  $type-name
}

#-------------------------------------------------------------------------------
# This $naked-gnome-name is a name without a package name or one seperated with 
# a dot. Convert it into two names. E.g.
#   Widget ==> ( GtkWidget, Gnome::Gtk3::Widget)
#   Atk.Component ==> ( AtkComponent, Gnome::Atk::Component)
method !set-names ( Str $naked-gnome-name is copy --> List ) {

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

  ( $gnome-name, $raku-name)
}

#-------------------------------------------------------------------------------
method load-map ( ) {
  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  if $fname.IO ~~ :r {
    note "Load object map $fname" if $*verbose;
    $!map = load-yaml($fname.IO.slurp);
  }

  else {
    $!map = %();
  }
}

#`{{
#-------------------------------------------------------------------------------
method !load-object ( ) {
  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  if $fname.IO ~~ :r {
    note "Load object map $fname" if $*verbose;
    $!map = load-yaml($fname.IO.slurp);
  }

  else {
    $!map = %();
  }
}
  }}

#-------------------------------------------------------------------------------
method save-map ( ) {
  my $fname = $*work-data<gir-module-path> ~ 'repo-object-map.yaml';
  note "Save object map $fname" if $*verbose;
  $fname.IO.spurt(save-yaml($!map));
}

#-------------------------------------------------------------------------------
# Read the XML file found at /usr/share/gir-1.0. Return result in
# an XML::XPath object.
method load-gir-file ( --> XML::XPath ) {
  my Str $file = $*work-data<gir>;
  if $file.IO ~~ :r {
    $!gir-modification-time = $file.IO.modified;
    $!xp .= new(:$file);
  }

  else {
    die "Gir file $*work-data<gir> not found";
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
