# Command to generate: generate.raku -v -d -c Pango gravity
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
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
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new(:library('libpango-1.0.so.0'));
}

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
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  #gravity-get-for-matrix => %( :type(Function), :is-symbol<pango_gravity_get_for_matrix>,  :returns(GEnum) :parameters([N-Matrix ])),
  #gravity-get-for-script => %( :type(Function), :is-symbol<pango_gravity_get_for_script>,  :returns(GEnum) :parameters([ PangoScript , PangoGravity, PangoGravityHint])),
  #gravity-get-for-script-and-width => %( :type(Function), :is-symbol<pango_gravity_get_for_script_and_width>,  :returns(GEnum) :parameters([ PangoScript , gboolean, PangoGravity, PangoGravityHint])),
  gravity-to-rotation => %( :type(Function), :is-symbol<pango_gravity_to_rotation>,  :returns(gdouble), :parameters([PangoGravity])),

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
