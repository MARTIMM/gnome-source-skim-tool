
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;

use XML;
use XML::XPath;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Test:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::Doc $!grd;

has Str $!filename;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {

  $!grd .= new;
  $!sas .= new;
}

#`{{
#-------------------------------------------------------------------------------
method set-unit ( XML::Element $element --> Str ) {

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  # Check for parent class. There are never more than one.
  my Str $parent = $h<parent-raku-name> // '';
  if ?$parent {
    # Misc is deprecated so shortcut to Widget
    $parent = 'Gnome::Gtk3::Widget' if $parent ~~ m/ \:\: Misc $/;
    $*external-modules.push: $parent;
  }

  my Bool $is-role = (($h<gir-type> // '' ) eq 'interface') // False;
  my Bool $is-class = (($h<gir-type> // '' ) eq 'class') // False;

  # If the object is a class
  if $is-class {
    # Check for roles to implement
    my Array $roles = $h<implement-roles>//[];
    for @$roles -> $role {
      my Hash $role-h = $!sas.search-name($role);
      $*external-modules.push: $role-h<class-name>;
    }
  }

  my Str $code = qq:to/RAKUMOD/;

    {$!grd.pod-header('Module Imports')}
    __MODULE__IMPORTS__

    {$!grd.pod-header(($is-role ?? 'Role' !! 'Class') ~ ' Tests');}
    RAKUMOD

  $code
}
}}

#-------------------------------------------------------------------------------
# This setup is for more simple structures like records, functions,
# enumerations, etc. There is no need for inheritence, BUILD, signals or
# properties.
method set-unit-for-file ( Str $class-name --> Str ) {

  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line

    #TL:1:$class-name:
    {$!grd.pod-header('Module Imports');}
    __MODULE__IMPORTS__
    RAKUMOD

  self.add-import('Test');

  $code
}

#-------------------------------------------------------------------------------
method generate-function-tests ( Str $class-name, Hash $hcs --> Str ) {

  return '' unless ?$hcs;

  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all functions from the Hash
  my Str $code = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR( 'Standalone Functions', 2);}
    subtest 'functions', \{
      my $class-name \$cname .= new;

    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

     # Get method name, drop the prefix and substitute '_'
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $symbol-prefix //;
    $hash-fname ~~ s:g/ '_' /-/;

    # Get parameter lists
    my Str (
      $par-list #, $call-list, #$own, $raku-list, $returns-doc, $items-doc, 
    ) =  '';
    my @rv-list = ();

    for @($curr-function<parameters>) -> $parameter {

#      self!get-types(
#        $parameter, #$raku-list, 
#        $call-list, #$items-doc,
#        @rv-list #, $returns-doc
#      );

      # Get a list of types for the arguments
      $par-list ~= ", $parameter<raku-ntype>";
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] ' :parameters([', $par-list, ']),'
              !! '';


    # Return type
    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my Str $returns;
    my $xtype = $curr-function<return-raku-ntype>;
    my ( $rnt0, $rnt1) = $xtype.split(':');
    if ?$rnt1 {
      $returns = " :returns\($rnt0\), :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = " :returns\($rnt0\),";
    }

    else {
      $returns = '';
    }

    if ?$returns {
      $code ~= Q:qq:to/EOSUB/;
          #TF:0:$hash-fname
          #my \$return-value = \$cname.$hash-fname\($par-list\);
          #is \$return-value, …, 'function .$hash-fname\(\)-> \$return-value';

        EOSUB
    }

    else {
      $code ~= Q:qq:to/EOSUB/;
          #TF:0:$hash-fname
          lives-ok \{
            #\$cname.$hash-fname\($par-list\);
          \}, 'function .$hash-fname\(\)';

        EOSUB
    }

#note "$?LINE $hash-fname, {$returns//'-'}, {$par-list//'-'}";
#TM:0:$hash-fname
#    $code ~= [~] '  ', $hash-fname, ' => %( :type(Function),',
#                 $returns, $par-list, "),\n";

  }

  $code ~= "};\n\n";
  $code
}

#-------------------------------------------------------------------------------
method generate-enumeration-tests ( Array:D $enum-names --> Str ) {

  # Return empty string if no enums found.
  return '' unless ?$enum-names;
#note "$?LINE e names: $enum-names.gist()";

  # Open enumerations file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-enumeration.gir';
  my XML::XPath $xpath .= new(:$file);

  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Enumerations');}
    EOENUM

  # For each of the found names
  for $enum-names.sort -> $enum-name {
    my Str $name = $enum-name;
    my Str $package = $*gnome-package.Str;
    $package ~~ s/ \d+ $//;
    $name ~~ s/^ $package //;

    # Get the XML element of the enum data
    my XML::Element $e = $xpath.find(
      '//enumeration[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOENUM/;
      {HLSEPARATOR}
      #TE:1:$enum-name
      subtest '$enum-name', \{
      EOENUM

    my $member-count = 0;
    my @members = $xpath.find( 'member', :start($e), :to-list);
    for @members -> $m {
      my Str $enum-item = $m.attribs<c:identifier>;
      $code ~= qq:to/EOENUM/;
          #TE:1:$enum-item
          is $enum-item.value, $member-count, 'enum $enum-item = $member-count';

        EOENUM
      $member-count++;

#      # Only test a few entries
#      last if $member-count > 3;
    }

    $code ~= "};\n\n";
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-bitfield-tests ( Array:D $bitfield-names --> Str ) {

  # Return empty string if no bitfields found.
  return '' unless ?$bitfield-names;
#note "$?LINE e names: $bitfield-names.gist()";

  # Open bitfields file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-bitfield.gir';
  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOBFIELD/;
    {HLSEPARATOR}
    {SEPARATOR('Bitfields');}
    EOBFIELD

  # For each of the found names
  for $bitfield-names.sort -> $bitfield-name {
    my Str $name = $bitfield-name;
#    my Str $package = $*gnome-package.Str;
#    $package ~~ s/ \d+ $//;
#    $name ~~ s/^ $package //;
note "$?LINE $bitfield-name, $name";
    # Get the XML element of the bitfield data
    my XML::Element $e = $xpath.find(
      '//bitfield[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOBFIELD/;
      {HLSEPARATOR}
      #TE:1:$bitfield-name
      subtest '$bitfield-name', \{
      EOBFIELD

#   $code ~= "enum $bitfield-name is export \(\n  ";

#    my Str $member-name-list = '';
    my @members = $xpath.find( 'member', :start($e), :to-list);
#    my @l = ();
    for @members -> $m {
#note "$?LINE $m.attribs()<c:identifier>, $m.attribs()<value>";
#      @l.push: [~] ':', $m.attribs<c:identifier>, '(', $m.attribs<value>, ')';
      my Str $bitfield-item = $m.attribs<c:identifier>;
      my Str $bitfield-value = $m.attribs<value>;
      $code ~= qq:to/EOBFIELD/;
          #TE:1:$bitfield-item
          is $bitfield-item.value, $bitfield-value, 'bitfield $bitfield-item = $bitfield-value';

        EOBFIELD
    }

#      # Only test a few entries
#      last if $member-count > 3;

#    $code ~= @l.join(', ') ~ "\n\);\n\n";

    $code ~= "};\n\n";
  }
#note "$?LINE $code";
#exit;
  $code
}

#-------------------------------------------------------------------------------
method generate-constant-tests ( @constants --> Str ) {
  
  # Return empty string if no enums found.
  return '' unless ?@constants;

  # Open constants file for xpath
#  my Str $file = $*work-data<gir-module-path> ~ 'repo-constant.gir';
#  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOCONST/;
    {$!grd.pod-header('Constants');}
    subtest 'constants', \{
    EOCONST

  # For each of the found names
  for @constants -> $constant {
#note "$?LINE ", $constant.gist;
#    my Str $name = $constant-name;
#    my Str $package = $*gnome-package.Str;
#    $package ~~ s/ \d+ $//;
#    $name ~~ s/^ $package //;

    # Get the XML element of the constant data
#    my XML::Element $e = $xpath.find(
#      '//constant[@name="' ~ $constant[0] ~ '"]', :!to-list
#    );

    my Str $value = $constant[2];
    $value = "'$value'" if $constant[1] ~~ / char /;

#TE:0:$constant[0]
#      {HLSEPARATOR}

#    $code ~= "constant $constant[0] is export = $value;\n";

    $code ~= qq:to/EOCONST/;
      #TE:1:$constant[0]
      is $constant[0], $value, "constant $constant[0] = $value";

      EOCONST

#    my Str $edoc =
#      ($xpath.find( 'doc/text()', :start($e), :!to-list) // '').Str;
#    my Str $s = self.modify-text($edoc);
#    $doc = self.cleanup($s);

#    my Str $member-name-list = '';
#    my @members = $xpath.find( 'member', :start($e), :to-list);
#    my @l = ();
#    for @members -> $m {
#      @l.push: [~] ':', $m.attribs<c:identifier>, '(', $m.attribs<value>, ')';
#    }

#    $code ~= @l.join(', ') ~ "\n\);\n";

  }
#note "$?LINE $code";
#exit;
  $code ~= "};\n\n";
}

#-------------------------------------------------------------------------------
# Fill in the __MODULE__IMPORTS__ string inserted at the start of the code
# generation. It is the place where the 'use' statements must come.
method substitute-MODULE-IMPORTS ( Str $code is copy --> Str ) {

  note "Set modules to import" if $*verbose;
  my $import = '';
  for @$*external-modules -> $m {
    if $m ~~ m/ [ NativeCall || 'Gnome::N::' ] / {
      $import ~= "use $m;\n";
    }
  }

  $import ~= "\n";

  for @$*external-modules.sort -> $m {
    unless $m ~~ m/ [ NativeCall || 'Gnome::N::' ] / {
      # For the moment only Gtk gets changed for :api<2>
      if $m ~~ m/ '::' [ Gtk || Gdk ] / {
        $import ~= "use $m\:api\<2\>;\n";
      }

      else {
        # Other modules may need name changes
        $import ~= "use $m;\n";
      }
    }
  }

  $code ~~ s/__MODULE__IMPORTS__/$import/;

  $code
}

#-------------------------------------------------------------------------------
method add-import ( Str $import ) {
  # Add only when $import is not in the array or when $import is not this class
  $*external-modules.push: $import unless $*external-modules.first($import);
}
