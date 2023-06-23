

use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::SearchAndSubstitute;
#use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Prepare;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::File:auth<github:MARTIMM>;

#has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
#has Gnome::SourceSkimTool::Doc $!grd;


has XML::XPath $!xpath;

has Str $!filename;
has Str $!unit-name;
has Hash $!filedata;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {
  self!get-data-from-filename;
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

for $!filedata.kv -> $t, $h {
  note "$?LINE: $t, $h.keys()";
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

    say "Generate Raku module from class data in ",
        $*work-data<raku-class-name> if $*verbose;

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

  elsif $!filedata<union> {
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
