# Command to generate: generate.raku -c -t Gio file
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

unit class Gnome::Gio::T-File:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(gio-lib()), :sub-prefix("g_"));
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
  file-new-for-commandline-arg => %( :type(Function),  :returns(N-GObject), :parameters([Str])),
  file-new-for-commandline-arg-and-cwd => %( :type(Function),  :returns(N-GObject), :parameters([ Str, Str])),
  file-new-for-path => %( :type(Function),  :returns(N-GObject), :parameters([Str])),
  file-new-for-uri => %( :type(Function),  :returns(N-GObject), :parameters([Str])),
  file-new-tmp => %( :type(Function),  :returns(N-GObject), :parameters([ Str, CArray[N-GObject]])),
  file-parse-name => %( :type(Function),  :returns(N-GObject), :parameters([Str])),

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
