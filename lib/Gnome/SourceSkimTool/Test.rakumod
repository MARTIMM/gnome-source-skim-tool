
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

    {$!grd.pod-header('Type Tests');}

    RAKUMOD

  self.add-import('Test');

  $code
}

#-------------------------------------------------------------------------------
method generate-enumerations-test ( Array:D $enum-names --> Str ) {

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
