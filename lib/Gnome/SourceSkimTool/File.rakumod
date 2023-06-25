

use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::Code;
#use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Prepare;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::File:auth<github:MARTIMM>;

#has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::Code $!mod;
#has Gnome::SourceSkimTool::Doc $!grd;

has XML::XPath $!xpath;

has Str $!filename;
has Hash $!filedata;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {
  $!mod .= new;

  self!get-data-from-filename;
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  if $*verbose {
    note "\nTypes found in file $!filename";
    for $!filedata.kv -> $t, $h {
      note "  $t: $h.keys()";
    }
  }

  # Classes, interfaces, records and unions may have any of the following and
  # must be generated in below order. Indented parts are to be found within
  # classes, interfaces, records or unions. Also, these types are generated in
  # their separate modules. When there are no classes, interfaces, records or
  # unions, the resulting module is a mixture of what is found in the file.
  #
  # docsections
  #   description, class/role unit build
  # aliases
  # constants
  # enums
  # bitfields
  #   constructors
  #   methods
  #   functions
  #   callbacks

  my Bool $found-ciru = False; # ciru ≡ class, interface, record, union
  if $!filedata<class>:exists {
    $found-ciru = True;

    # set use mark
    # class unit

    # constants
    # enums
    # bitmasks
    # records
    # unions

    # build

    # constructors
    # methods
    # functions

    # fallback
    # substitute use mark

    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku class from ", $*work-data<raku-class-name> if $*verbose;

    require ::('Gnome::SourceSkimTool::Class');
    my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }

  elsif $!filedata<interface>:exists {
    $found-ciru = True;

    # set use mark
    # class unit

    # constants
    # enums
    # bitmasks
    # records
    # unions

    # build

    # constructors
    # methods
    # functions

    # fallback
    # substitute use mark

    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

    require ::('Gnome::SourceSkimTool::Interface');
    my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }

  elsif $!filedata<record>:exists {
    $found-ciru = True;

    # set use mark
    # class unit

    # constants
    # enums
    # bitmasks
    # records
    # unions

    # build

    # constructors
    # methods
    # functions

    # fallback
    # substitute use mark
  }

  elsif $!filedata<union>:exists {
    $found-ciru = True;

    # set use mark
    # class unit

    # constants
    # enums
    # bitmasks
    # records
    # unions

    # build

    # constructors
    # methods
    # functions

    # fallback
    # substitute use mark
  }

  # No class, interface, record or union found. This module becomes the
  # mixture of all other types.
  unless $found-ciru {
    my Bool $need-routine-caller = False;

    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    my Str $code = qq:to/RAKUMOD/;
      #TL:1:$*work-data<raku-class-name>:
      use v6;
      RAKUMOD

    $code ~= $!mod.set-unit-for-file;

    # Process types one by one so that it becomes a neet order in the result
    if $!filedata<constant>:exists {
    }

    if $!filedata<enumeration>:exists {
      my Array $enum-names = [];
      $enum-names = [$!filedata<enumeration>.keys];
      $code ~= $!mod.generate-enumerations-code(:$enum-names);
    }

    if $!filedata<bitfield>:exists {
      my Array $bitfield-names = [];
      $bitfield-names = [$!filedata<bitfield>.keys];
      $code ~= $!mod.generate-bitfield-code(:$bitfield-names);
    }

    if $!filedata<callback>:exists {
    }

    if $!filedata<docsection>:exists {
    }

    if $!filedata<function>:exists {
      $need-routine-caller = True;
    }

    $code = $!mod.substitute-MODULE-IMPORTS( $code, :$need-routine-caller);

    note "Save module";
    $*work-data<raku-module-file>.IO.spurt($code) if $*generate-code;
  }
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {
}

#-------------------------------------------------------------------------------
method generate-test ( ) {
}

#-------------------------------------------------------------------------------
# Fill the Hash $!filedata with data from a repo-object-map.yaml where the
# 'class-file' field of every object must match $filename. The data is reordered
# to have its type as its toplevel key.
method !get-data-from-filename ( ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  my Hash $h := $*object-maps{$package};
  $!filedata = %();


  for $h.kv -> $k, $v {
    next unless $v<class-file>:exists and $v<class-file> eq $!filename;

    # reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}
