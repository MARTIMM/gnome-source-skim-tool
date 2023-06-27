
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Interface:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;
  $!sas .= new;

  # load data for this module
  note "Load module data from $*work-data<gir-interface-file>" if $*verbose;
  $!xpath .= new(:file($*work-data<gir-interface-file>));

  $!mod .= new(:$!xpath);
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//interface');
  die "//interface not found in $*work-data<gir-interface-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:
    use v6;
    RAKUMOD

#  my Str $doc = qq:to/RAKUMOD/;
#    #TL:1:$*work-data<raku-class-name>:
#    use v6;
#
#    {$!grd.pod-header('Role Description')}
#    RAKUMOD

#  note "Generate module description" if $*verbose;  
#  $doc ~= $!grd.get-description( $element, $!xpath) if $*generate-doc;

  note "Set role unit" if $*verbose;
  $code ~= $!mod.set-unit($element);

  note "Generate enumerations and bitmasks";
  $code ~= $!mod.generate-enumerations-code;
  $code ~= $!mod.generate-bitfield-code;

  # Roles do not have a BUILD
  note "Generate role initialization method" if $*verbose;  
  $code ~= $!mod.generate-role-init( $element, $!xpath);

  $code ~= $!mod.generate-callables( $element, $!xpath);
#`{{
  note "Generate module methods" if $*verbose;  
  ( $doc, $code) = $!mod.generate-methods($element);

  # if there are methods, add the fallback routine and methods
  if ?$doc {
#    $code ~= self!add-deprecatable-method($element);
    $code ~= $code;
    $doc ~= $doc;
  }

  note "Generate module functions" if $*verbose;  
  $code ~= $!mod.generate-functions-code($element)
    if $*generate-code;
#  if ?$code {
#    $doc ~= $doc;
#    $code ~= $code;
#  }

  # Finish 'my Hash $methods' started in $!mod.generate-build()
  # and add necessary _fallback-v2() method. It is recognized in
  # class Gnome::N::TopLevelClassSupport.
  $code ~= q:to/RAKUMOD/;
    );

    #-------------------------------------------------------------------------------
    # This method is called from user class and can provide the $routine-caller
    # variable. Class calls this routine as self.XYZRole::_fallback-v2()
    method _fallback-v2 (
      Str $n, Bool $_fallback-v2-ok is rw, Callable $routine-caller, @arguments
    ) {
      my Str $name = S:g/ '-' /_/ with $n;
      if $methods{$name}:exists {
        my $native-object = self.get-native-object-no-reffing;
        $_fallback-v2-ok = True;
        return $routine-caller.call-native-sub(
          $name, @arguments, $methods, :$native-object
        );
      }
    }

    RAKUMOD
}}

  # Add the signal doc here
#  $doc ~= $sig-info<doc> if $*generate-doc;

#  note "Generate module properties" if $*verbose;  
#  $doc ~= $!grd.generate-properties( $element, $!xpath) if $*generate-doc;

  $code = $!mod.substitute-MODULE-IMPORTS($code);

  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($code) if $*generate-code;
#  note "Save pod doc";
#  $*work-data<raku-module-doc-file>.IO.spurt($doc) if $*generate-doc;
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

}

#-------------------------------------------------------------------------------
method generate-test ( ) {

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
