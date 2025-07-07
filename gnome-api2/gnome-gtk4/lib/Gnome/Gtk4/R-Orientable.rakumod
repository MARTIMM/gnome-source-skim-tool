=comment Package: Gtk4, C-Source: orientable
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::R-Orientable:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-orientation => %(:is-symbol<gtk_orientable_get_orientation>,  :returns(GEnum), :cnv-return(GtkOrientation)),
  set-orientation => %(:is-symbol<gtk_orientable_set_orientation>, :parameters([GEnum]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_orientable_fallback-v2 (
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
