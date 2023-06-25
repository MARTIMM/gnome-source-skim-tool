

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

  # Classes or interfaces may have any other type. The other types are found
  # by looking up the filename set in the 'class-file' field. When there is
  # no class or interface defined, the types are gathered into one module.
  # The difference is mainly the complexity of the generated module. For
  # instance, classes and interfaces may have properties and signals.
  # Records and unions, however, can also have constructors, methods and
  # functions. There can be more unions and records defined in one file which
  # must be defined in separate raku modules. Only then it is possible to have
  # BUILD routines defined for each of them.
  if $!filedata<class>:exists {
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
    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

    require ::('Gnome::SourceSkimTool::Interface');
    my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }

  # If there is one record, generate a single raku module. The record
  # may have constructors and methods too
  elsif $!filedata<record>:exists and $!filedata<record>.keys.elems == 1 {
    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

    require ::('Gnome::SourceSkimTool::Record');
    my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }

  # If there is one union, generate a single raku module. The union
  # may have constructors and methods too
  elsif $!filedata<union>:exists and $!filedata<union>.keys.elems == 1 {
  }

  else {
    # No class or interface. This module becomes the mixture of all other types.
    my Bool $need-routine-caller = False;

    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    my Str $code = qq:to/RAKUMOD/;
      #TL:1:$*work-data<raku-class-name>:
      use v6;
      RAKUMOD

    $code ~= $!mod.set-unit-for-file;

    if $!filedata<docsection>:exists {
    }

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

    # There are more than one records, gather them all in this module
    if $!filedata<record>:exists {
    }

    # There are more than one unions, gather them all in this module
    if $!filedata<union>:exists {
    }

    if $!filedata<callback>:exists {
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
