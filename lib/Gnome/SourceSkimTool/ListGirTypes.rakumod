
use Gnome::SourceSkimTool::SkimGtkDoc;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::ListGirTypes:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method list-types ( ) {
  my Hash $gir-types = %();

  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;
  my Hash $object-map =
    $s.load-map($*work-data<gir-module-path>);
  
  for $object-map.kv -> $k, $v {
    $gir-types{$v<gir-type>} //= 0;
    $gir-types{$v<gir-type>}++;
  }

  say "\nList of types in the Gnome Introspection Repository";
  for $gir-types.keys.sort -> $k {
    say "  Type $k has $gir-types{$k} objects";
  }
}

#-------------------------------------------------------------------------------
method list-type-objects ( Str $type ) {
  my Hash $gir-objects = %();

  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;
  my Hash $object-map =
    $s.load-map($*work-data<gir-module-path>);
  
  for $object-map.kv -> $k, $v {
    if $v<gir-type> eq $type {
      $gir-objects{$k} = 1;
    }
  }

  say "\nList of objects of type $type";
  for $gir-objects.keys.sort -> $k {
    say "  $k";
  }
}