=comment Package: Gsk4, C-Source: path
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gsk4::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::T-path:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));
}

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GskPathForeachFlags is export (
  :GSK_PATH_FOREACH_ALLOW_ONLY_LINES(0), :GSK_PATH_FOREACH_ALLOW_QUAD(1), :GSK_PATH_FOREACH_ALLOW_CUBIC(2), :GSK_PATH_FOREACH_ALLOW_CONIC(4)
);

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  path-parse => %( :type(Function), :is-symbol<gsk_path_parse>,  :returns(N-Object), :parameters([Str])),

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
