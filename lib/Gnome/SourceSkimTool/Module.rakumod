
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
#use Gnome::SourceSkimTool::GenerateDoc;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Module:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
#has Gnome::SourceSkimTool::GenerateDoc $!grd;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

#  $!grd .= new;
  $!sas .= new;
}

#-------------------------------------------------------------------------------
method set-unit ( XML::Element $class-element, Hash $sig-info --> Str ) {

  # Insert a commented import of enums module
  my Str ( $imports, $also) = '' xx 3;
  if $*gnome-package.Str ~~ / '3' $/ {
    $imports = "#use Gnome::Gtk3::Enums;\n";
  }

  elsif $*gnome-package.Str ~~ / '4' $/ {
    $imports = "#use Gnome::Gtk4::Enums;\n";
  }

  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  # Check for parent class. There are never more than one.
  my Str $parent = $h<parent-raku-name> // '';
  if ?$parent {
    $imports ~= "use $parent;\n";
    $also ~= "also is $parent;\n";
  }

  # Check for roles to implement
  my Array $roles = $h<implement-roles>//[];
  for @$roles -> $role {
    my Hash $role-h = $!sas.search-name($role);
#note "$?LINE role=$role -> $role-h.gist()";
    $imports ~= "use $role-h<rname>;\n";
    $also ~= "also does $role-h<rname>;\n";
  }


  my Str $code = qq:to/RAKUMOD/;

    {HLSEPARATOR}
    {SEPARATOR('Module Imports');}
    {HLSEPARATOR}
    use NativeCall;

    use Gnome::N::NativeLib;
    use Gnome::N::N-GObject;
    use Gnome::N::GlibToRakuTypes;
    #use Gnome::N::TopLevelClassSupport;
    $imports
    
    #use Gnome::Glib::List;
    #use Gnome::Glib::SList;
    #use Gnome::Glib::Error;

    {HLSEPARATOR}
    {SEPARATOR('Role Declaration');}
    {HLSEPARATOR}
    unit role $*work-data<raku-class-name>:auth<github:MARTIMM>;
    $also
    RAKUMOD

  $code
}
