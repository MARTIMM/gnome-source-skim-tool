# Command to generate: generate.raku -t -c Glib quark
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
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix("g_quark_"));
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
  #intern-static-string => %( :type(Function),  :returns(Str), :parameters([Str])),
  #intern-string => %( :type(Function),  :returns(Str), :parameters([Str])),
  #from-static-string => %( :type(Function),  :returns(GQuark), :parameters([Str])),
  from-string => %( :type(Function),  :returns(GQuark), :parameters([Str])),
  to-string => %( :type(Function),  :returns(Str), :parameters([GQuark])),
  try-string => %( :type(Function),  :returns(GQuark), :parameters([Str])),

#`{{
  quark-from-static-string => %( :type(Function),  :returns(GQuark), :parameters([Str])),
  quark-from-string => %( :type(Function),  :returns(GQuark), :parameters([Str])),
  quark-to-string => %( :type(Function),  :returns(Str), :parameters([GQuark])),
  quark-try-string => %( :type(Function),  :returns(GQuark), :parameters([Str])),
}}
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
