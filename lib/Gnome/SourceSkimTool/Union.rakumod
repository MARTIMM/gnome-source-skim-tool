
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Union:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;

  # load data for this module
  note "Load module data from $*work-data<gir-union-file>" if $*verbose;
  $!xpath .= new(:file($*work-data<gir-union-file>));

  $!mod .= new; #(:$!xpath);
}

#-------------------------------------------------------------------------------
# In a <union> there might be constructors, methods, functions or fields
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//union');
  die "//union not found in $*work-data<gir-union-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $callable-code ~= $!mod.generate-callables( $element, $!xpath);
  if ?$callable-code {
  
#TL:1:$*work-data<raku-class-name>:
    my Str $code = qq:to/RAKUMOD/;
      # Command to generate: $*command-line
      use v6;
      RAKUMOD

    note "Set class unit" if $*verbose;
    $code ~= $!mod.set-unit($element);

  #  note "Generate enumerations and bitmasks";
  #  $code ~= $!mod.generate-enumerations-code;
  #  $code ~= $!mod.generate-bitfield-code;

  #  # Generate record structures if there are any. Structures are stored
  #  # in separate files.
  #  my @records = $!xpath.find( 'record', :start($element), :to-list);
  #note "$?LINE @records.elems()";
  #  for @records -> $record {
  #    $!mod.generate-structure( $record, $!xpath);
  #  }
  
    # Generate union structure. Unions are stored in separate files.
  #  $!mod.generate-union( $element, $!xpath);

    # Make a BUILD submethod
    note "Generate BUILD submethod" if $*verbose;
  #  ( $doc, $code) = $!mod.generate-build( $element, %());
  #  $module-doc ~= $doc;
  #  $module-code ~= $code;
    $code ~= $!mod.make-build-submethod( $element, $!xpath);

    $code ~= $callable-code;

  #`{{
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
  }}

    $code = $!mod.substitute-MODULE-IMPORTS($code);

    my Str $fname = "$*work-data<result-path>$*gnome-class.rakumod";
    note "Save union module in ", $fname.IO.basename;
    "$*work-data<result-path>$*gnome-class.rakumod".IO.spurt($code);
  }

#  else {
#    my Str $fname = "$*work-data<result-path>$*gnome-class.rakumod";
#    note "Union module {$fname.IO.basename} is not saved due to lack of routines";
#  }

#  $*work-data<raku-module-file>.IO.spurt($code);
#  note "Save pod doc";
#  $*work-data<raku-module-doc-file>.IO.spurt($module-doc) if $*generate-doc;
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {
#`{{
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
  $module-code ~= $!mod.set-unit($element) if $*generate-code;

  #note "Generate enumerations and bitmasks";
  #$module-code ~= $!mod.generate-enumerations-code if $*generate-code;
  #$module-doc ~= $!mod.generate-enumerations-doc if $*generate-doc;

  # Generate structure if there is one
  $module-code ~= $!mod.generate-structure($element) if $*generate-code;

  # Make a BUILD submethod
  note "Generate BUILD submethod" if $*verbose;  
  ( $doc, $code) = $!mod.generate-build( $element, %());
  $module-doc ~= $doc;
  $module-code ~= $code;

  $module-code ~= $!mod.generate-callables($element) if $*generate-code;
#`{{
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
}}

  $code = $!mod.substitute-MODULE-IMPORTS($code);

  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($module-code) if $*generate-code;
  note "Save pod doc";
  $*work-data<raku-module-doc-file>.IO.spurt($module-doc) if $*generate-doc;
}}
}

#-------------------------------------------------------------------------------
method generate-test ( ) {

}
