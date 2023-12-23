=comment Package: Glib, C-Source: quark
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

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::T-Quark:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(glib-lib()));
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  intern-static-string => %( :type(Function), :is-symbol<g_intern_static_string>,  :returns(Str), :parameters([Str])),
  intern-string => %( :type(Function), :is-symbol<g_intern_string>,  :returns(Str), :parameters([Str])),
  from-static-string => %( :type(Function), :is-symbol<g_quark_from_static_string>,  :returns(GQuark), :parameters([Str])),
  from-string => %( :type(Function), :is-symbol<g_quark_from_string>,  :returns(GQuark), :parameters([Str])),
  to-string => %( :type(Function), :is-symbol<g_quark_to_string>,  :returns(Str), :parameters([GQuark])),
  try-string => %( :type(Function), :is-symbol<g_quark_try_string>,  :returns(GQuark), :parameters([Str])),

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
