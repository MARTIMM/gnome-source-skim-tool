
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::GenerateDoc;
use Gnome::SourceSkimTool::Module;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::RecordModule:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::GenerateDoc $!grd;
has Gnome::SourceSkimTool::Module $!mod;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;
  $!sas .= new;

  # load data for this module
  note "Load module data from $*work-data<gir-module-path>repo-record.gir";
  $!xpath .= new(:file($*work-data<gir-record-file>));

  $!mod .= new(:$!xpath);
}

#-------------------------------------------------------------------------------
method generate-raku-record ( ) {

  my XML::Element $element = $!xpath.find('//record');
  die "//record not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  my ( $doc, $code);
  my Str $module-code = '';
  my Str $module-doc = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:
    use v6;

    {$!grd.pod-header('Record Description')}
    RAKUMOD

  note "Generate module description" if $*verbose;  
  $module-doc ~= $!grd.get-description( $element, $!xpath) if $*generate-doc;

  note "Set class unit" if $*verbose;
  $module-code ~= $!mod.set-unit-code($element) if $*generate-code;

  #note "Generate enumerations and bitmasks";
  #$module-code ~= $!mod.generate-enumerations-code if $*generate-code;
  #$module-doc ~= $!mod.generate-enumerations-doc if $*generate-doc;

  # Make a BUILD submethod
  note "Generate BUILD submethod" if $*verbose;  
  ( $doc, $code) = $!mod.generate-build( $element, %());
  $module-doc ~= $doc;
  $module-code ~= $code;

  note "Generate module methods" if $*verbose;  
  ( $doc, $code) = $!mod.generate-methods($element);

  # if there are methods, add the fallback routine and methods
  if ?$doc {
#    $module-code ~= self!add-deprecatable-method($element);
    $module-code ~= $code;
    $module-doc ~= $doc;
  }

  note "Generate module functions" if $*verbose;  
  $module-code ~= $!mod.generate-functions-code($element)
    if $*generate-code;
#  if ?$code {
#    $module-doc ~= $doc;
#    $module-code ~= $code;
#  }


  # Finish 'my Hash $methods' started in $!mod.generate-build()
  # and add necessary _fallback-v2() method. It is recognized in
  # class Gnome::N::TopLevelClassSupport.
  $module-code ~= q:to/RAKUMOD/;
    );

    #-------------------------------------------------------------------------------
    method _fallback-v2 (
      Str $n, Bool $_fallback-v2-ok is rw, *@arguments
    ) {
      my Str $name = S:g/ '-' /_/ with $n;
      if $methods{$name}:exists {
        my $native-object = self.get-native-object-no-reffing;
        $_fallback-v2-ok = True;
        return $!routine-caller.call-native-sub(
          $name, @arguments, $methods, :$native-object
        );
      }

      else {
        callsame;
      }
    }

    RAKUMOD

  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($module-code) if $*generate-code;
  note "Save pod doc";
  $*work-data<raku-module-doc-file>.IO.spurt($module-doc) if $*generate-doc;
}

#-------------------------------------------------------------------------------
method generate-raku-record-test ( ) {

}












=finish
#-------------------------------------------------------------------------------
method !add-deprecatable-method ( XML::Element $element --> Str ) {

  my Hash $meta-data = from-json('META6.json'.IO.slurp);
  my Str $version-now = $meta-data<version>;
  my @v = $version-now.split('.');
  @v[1] += 2;
  @v[2] = 0;
  my Str $version-dep = @v.join('.');


  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  my Array $roles = $h<implement-roles> // [];
  my $role-fallbacks = '';
  for @$roles -> $role {
    my Hash $role-h = $!sas.search-name($role);

    $role-fallbacks ~=
      "  \$s = self._$role-h<symbol-prefix>interface\(\$native-sub)\n" ~
      "    if !\$s and self.^can\('_$role-h<symbol-prefix>interface');\n";
  }
  $role-fallbacks ~= "\n" if ?$role-fallbacks;

  my Str $doc = '';

  my Str $pfix = $*work-data<sub-prefix>;
  my @pfix-parts = $pfix.split('_');

  my Str $pfix-dash = $*work-data<sub-prefix>;
  $pfix-dash ~~ s:g/ '_' /-/;
  $pfix-dash.chop(1);

  my Str $package = $*gnome-package.Str.lc;
  $package ~~ s/ \d //;

  my Str ( $mname, $set-class-name);
  $mname = "_{$pfix}interface";
  $set-class-name = '';

  $doc ~= q:to/EODEPR/;

    #`{{
      Older modules might still have it and must remove the method after
      deprecation date. New modules must not implement this.

    EODEPR

  $doc ~= "{HLSEPARATOR}\n";
  $doc ~= "method $mname " ~ '( Str $native-sub --> Callable ) {' ~ "\n";
  $doc ~= "  my Str \$pfix = '$*work-data<sub-prefix>';\n";

  $doc ~= q:to/EODEPR/;
      my @pfix-parts = $pfix.split('_');
      my Int $cfix = @pfix-parts.elems + 2;
      my Str $new-patt = $native-sub.subst( '-', '_', :g);

      my Callable $s;

      loop ( my Int $dash-count = 2; $dash-count < $cfix; $dash-count++ ) {
        my Str $tv = @pfix-parts[0 .. * - $dash-count].join('_');
        my Str $match = ?$tv ?? "{$tv}_$new-patt" !! "$tv$new-patt";
        try { $s = &::($match); }
        if ?$s {
          $match ~~ s/ $pfix //;
          $match ~~ s:g/ '_' /-/;
    EODEPR

  $doc ~= [~] '      Gnome::N::deprecate( "$native-sub", $match, ', "'",
              $version-now, "', '", $version-dep, "');\n";

  $doc ~= q:to/EODEPR/;

          last;
        }
      }

    EODEPR

  $doc ~= $role-fallbacks;
  $doc ~= $set-class-name;

  $doc ~= q:to/EODEPR/;

      $s
    }

    }}

    EODEPR

  $doc
}

