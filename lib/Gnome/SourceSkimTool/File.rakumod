

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

has Hash $!filedata;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  self!get-data-from-filename($*gnome-file);
}

#-------------------------------------------------------------------------------
method generate-raku-module-code ( ) {

for $!filedata.kv -> $t, $h {
  note "$?LINE: $t, $h.keys()";
}

  # classes, interfaces, records and unions may have any of the following and
  # must be generated in below order. Indented parts are to be found within
  # classes, interfaces, records or unions. Also, these types are generated in
  # their separate modules. When there are no classes, interfaces, records or
  # unions, the resulting module is a lumpsum of what is found in the file.
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

  
}

#-------------------------------------------------------------------------------
method generate-raku-module-doc ( ) {
}

#-------------------------------------------------------------------------------
method generate-raku-module-test ( ) {
}

#-------------------------------------------------------------------------------
method !get-data-from-filename ( Str $filename ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  my Hash $h := $*object-maps{$package};
  $!filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<class-file>:exists and $v<class-file> eq $filename;

    # reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}
