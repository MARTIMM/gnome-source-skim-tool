=comment Package: Gtk4, C-Source: native
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::R-Native:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-renderer => %(:is-symbol<gtk_native_get_renderer>, :returns(N-Object), ),
  get-surface => %(:is-symbol<gtk_native_get_surface>, :returns(N-Object), ),
  get-surface-transform => %(:is-symbol<gtk_native_get_surface_transform>, :parameters([CArray[gdouble], CArray[gdouble]]), ),
  realize => %(:is-symbol<gtk_native_realize>, ),
  unrealize => %(:is-symbol<gtk_native_unrealize>, ),

  #--[Functions]----------------------------------------------------------------
  get-for-surface => %( :type(Function), :is-symbol<gtk_native_get_for_surface>, :returns(N-Object), :parameters([N-Object]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_native_fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw,
  Gnome::N::GnomeRoutineCaller $routine-caller, @arguments, $native-object
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $routine-caller.call-native-sub(
      $name, @arguments, $methods, $native-object
    );
  }
}
