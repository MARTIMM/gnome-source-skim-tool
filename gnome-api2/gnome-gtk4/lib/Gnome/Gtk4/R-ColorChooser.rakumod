=comment Package: Gtk4, C-Source: colorchooser
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::Gdk4::N-RGBA:api<2>;
use Gnome::Gdk4::T-rgba:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-ColorChooser:auth<github:MARTIMM>:api<2>;

#TM:1:_add_gtk_color_chooser_signal_types:
method _add_gtk_color_chooser_signal_types ( Str $class-name ) {
  self.add-signal-types( $class-name,
    :w1<color-activated>,
  );
}


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  add-palette => %(:is-symbol<gtk_color_chooser_add_palette>, :parameters([GEnum, gint, gint, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-rgba => %(:is-symbol<gtk_color_chooser_get_rgba>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-use-alpha => %(:is-symbol<gtk_color_chooser_get_use_alpha>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  set-rgba => %(:is-symbol<gtk_color_chooser_set_rgba>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  set-use-alpha => %(:is-symbol<gtk_color_chooser_set_use_alpha>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_color_chooser_fallback-v2 (
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
