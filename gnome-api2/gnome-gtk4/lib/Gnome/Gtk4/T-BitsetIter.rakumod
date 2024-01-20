=comment Package: Gtk4, C-Source: bitset
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::N-Bitset:api<2>;
use Gnome::Gtk4::N-BitsetIter:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-BitsetIter:auth<github:MARTIMM>:api<2>;
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
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  bitset-iter-init-at => %( :type(Function), :is-symbol<gtk_bitset_iter_init_at>,  :returns(gboolean), :parameters([ N-BitsetIter, N-Bitset, guint, gint-ptr])),
  bitset-iter-init-first => %( :type(Function), :is-symbol<gtk_bitset_iter_init_first>,  :returns(gboolean), :parameters([ N-BitsetIter, N-Bitset, gint-ptr])),
  bitset-iter-init-last => %( :type(Function), :is-symbol<gtk_bitset_iter_init_last>,  :returns(gboolean), :parameters([ N-BitsetIter, N-Bitset, gint-ptr])),

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
