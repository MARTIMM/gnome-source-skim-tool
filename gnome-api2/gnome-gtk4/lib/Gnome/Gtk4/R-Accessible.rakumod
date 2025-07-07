=comment Package: Gtk4, C-Source: accessible
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gtk4::T-accessible:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::R-Accessible:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  announce => %(:is-symbol<gtk_accessible_announce>, :parameters([Str, GEnum]), ),
  get-accessible-parent => %(:is-symbol<gtk_accessible_get_accessible_parent>, :returns(N-Object), ),
  get-accessible-role => %(:is-symbol<gtk_accessible_get_accessible_role>,  :returns(GEnum), :cnv-return(GtkAccessibleRole)),
  get-at-context => %(:is-symbol<gtk_accessible_get_at_context>, :returns(N-Object), ),
  get-bounds => %(:is-symbol<gtk_accessible_get_bounds>, :returns(gboolean), :parameters([gint-ptr, gint-ptr, gint-ptr, gint-ptr]), ),
  get-first-accessible-child => %(:is-symbol<gtk_accessible_get_first_accessible_child>, :returns(N-Object), ),
  get-next-accessible-sibling => %(:is-symbol<gtk_accessible_get_next_accessible_sibling>, :returns(N-Object), ),
  get-platform-state => %(:is-symbol<gtk_accessible_get_platform_state>, :returns(gboolean), :parameters([GEnum]), ),
  reset-property => %(:is-symbol<gtk_accessible_reset_property>, :parameters([GEnum]), ),
  reset-relation => %(:is-symbol<gtk_accessible_reset_relation>, :parameters([GEnum]), ),
  reset-state => %(:is-symbol<gtk_accessible_reset_state>, :parameters([GEnum]), ),
  set-accessible-parent => %(:is-symbol<gtk_accessible_set_accessible_parent>, :parameters([N-Object, N-Object]), ),
  update-next-accessible-sibling => %(:is-symbol<gtk_accessible_update_next_accessible_sibling>, :parameters([N-Object]), ),
  update-property => %(:is-symbol<gtk_accessible_update_property>, :variable-list, :parameters([GEnum]), ),
  update-property-value => %(:is-symbol<gtk_accessible_update_property_value>, :parameters([gint, GEnum, N-Object]), ),
  update-relation => %(:is-symbol<gtk_accessible_update_relation>, :variable-list, :parameters([GEnum]), ),
  update-relation-value => %(:is-symbol<gtk_accessible_update_relation_value>, :parameters([gint, GEnum, N-Object]), ),
  update-state => %(:is-symbol<gtk_accessible_update_state>, :variable-list, :parameters([GEnum]), ),
  update-state-value => %(:is-symbol<gtk_accessible_update_state_value>, :parameters([gint, GEnum, N-Object]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_accessible_fallback-v2 (
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
