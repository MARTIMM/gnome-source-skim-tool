# Command to generate: generate.raku -c -t Pango gravity
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
#use Gnome::Pango::N-Matrix:api<2>;
#use Gnome::Pango::T-Script:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::T-Gravity:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum PangoGravity is export <
  PANGO_GRAVITY_SOUTH PANGO_GRAVITY_EAST PANGO_GRAVITY_NORTH PANGO_GRAVITY_WEST PANGO_GRAVITY_AUTO 
>;

enum PangoGravityHint is export <
  PANGO_GRAVITY_HINT_NATURAL PANGO_GRAVITY_HINT_STRONG PANGO_GRAVITY_HINT_LINE 
>;



#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new( :library(pango-lib()), :sub-prefix("pango_"));
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  #gravity-get-for-matrix => %( :type(Function),  :returns(GEnum) :parameters([N-Matrix ])),
  #gravity-get-for-script => %( :type(Function),  :returns(GEnum) :parameters([ PangoScript , PangoGravity, PangoGravityHint])),
  #gravity-get-for-script-and-width => %( :type(Function),  :returns(GEnum) :parameters([ PangoScript , gboolean, PangoGravity, PangoGravityHint])),
  gravity-to-rotation => %( :type(Function),  :returns(gdouble), :parameters([PangoGravity])),

);

# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
