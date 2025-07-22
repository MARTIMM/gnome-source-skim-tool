=comment Package: Gtk4, C-Source: scrollable
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::N-Border:api<2>;
use Gnome::Gtk4::T-border:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-Scrollable:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-border => %(:is-symbol<gtk_scrollable_get_border>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  get-hadjustment => %(:is-symbol<gtk_scrollable_get_hadjustment>, :returns(N-Object), ),
  get-hscroll-policy => %(:is-symbol<gtk_scrollable_get_hscroll_policy>,  :returns(GEnum), :cnv-return(GtkScrollablePolicy)),
  get-vadjustment => %(:is-symbol<gtk_scrollable_get_vadjustment>, :returns(N-Object), ),
  get-vscroll-policy => %(:is-symbol<gtk_scrollable_get_vscroll_policy>,  :returns(GEnum), :cnv-return(GtkScrollablePolicy)),
  set-hadjustment => %(:is-symbol<gtk_scrollable_set_hadjustment>, :parameters([N-Object]), ),
  set-hscroll-policy => %(:is-symbol<gtk_scrollable_set_hscroll_policy>, :parameters([GEnum]), ),
  set-vadjustment => %(:is-symbol<gtk_scrollable_set_vadjustment>, :parameters([N-Object]), ),
  set-vscroll-policy => %(:is-symbol<gtk_scrollable_set_vscroll_policy>, :parameters([GEnum]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_scrollable_fallback-v2 (
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
