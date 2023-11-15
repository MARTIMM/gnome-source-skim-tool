# Command to generate: generate.raku -v -c Glib error
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-Error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::T-Error:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library('libglib-2.0.so.0'));
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  clear-error => %( :type(Function), :is-symbol<g_clear_error>,  :parameters([ CArray[N-Error]])),
  prefix-error => %( :type(Function), :is-symbol<g_prefix_error>, :variable-list,  :parameters([ CArray[N-Error], Str])),
  prefix-error-literal => %( :type(Function), :is-symbol<g_prefix_error_literal>,  :parameters([ CArray[N-Error], Str])),
  propagate-error => %( :type(Function), :is-symbol<g_propagate_error>,  :parameters([ CArray[N-Error], N-Error])),
  propagate-prefixed-error => %( :type(Function), :is-symbol<g_propagate_prefixed_error>, :variable-list,  :parameters([ CArray[N-Error], N-Error, Str])),
  set-error => %( :type(Function), :is-symbol<g_set_error>, :variable-list,  :parameters([ CArray[N-Error], GQuark, gint, Str])),
  set-error-literal => %( :type(Function), :is-symbol<g_set_error_literal>,  :parameters([ CArray[N-Error], GQuark, gint, Str])),

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
