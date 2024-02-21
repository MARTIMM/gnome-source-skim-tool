=comment Package: Glib, C-Source: error
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

unit class Gnome::Glib::T-error:auth<github:MARTIMM>:api<2>;
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
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Error:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has GQuark $.domain;
  has gint $.code;
  has Str $.message;

  submethod BUILD (
    GQuark :$!domain, gint :$!code, 
  ) {
  }

  submethod TWEAK (
    Str :$message, 
  ) {
    $!message := $message
  }

  method COERCE ( $no --> N-Error ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Error, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  clear-error => %( :type(Function), :is-symbol<g_clear_error>,  :parameters([CArray[N-Error]])),
  prefix-error => %( :type(Function), :is-symbol<g_prefix_error>, :variable-list,  :parameters([ CArray[N-Error], Str])),
  prefix-error-literal => %( :type(Function), :is-symbol<g_prefix_error_literal>,  :parameters([ CArray[N-Error], Str])),
  propagate-error => %( :type(Function), :is-symbol<g_propagate_error>,  :parameters([ CArray[N-Error], N-Object])),
  propagate-prefixed-error => %( :type(Function), :is-symbol<g_propagate_prefixed_error>, :variable-list,  :parameters([ CArray[N-Error], N-Object, Str])),
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
