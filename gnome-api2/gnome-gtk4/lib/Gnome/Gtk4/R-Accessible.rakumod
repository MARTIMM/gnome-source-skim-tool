=comment Package: Gtk4, C-Source: accessible
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-Value:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-Accessible:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-accessible-role => %(:is-symbol<gtk_accessible_get_accessible_role>,  :returns(GEnum), :cnv-return(GtkAccessibleRole)),
  reset-property => %(:is-symbol<gtk_accessible_reset_property>,  :parameters([GEnum])),
  reset-relation => %(:is-symbol<gtk_accessible_reset_relation>,  :parameters([GEnum])),
  reset-state => %(:is-symbol<gtk_accessible_reset_state>,  :parameters([GEnum])),
  update-property => %(:is-symbol<gtk_accessible_update_property>, :variable-list,  :parameters([GEnum])),
  update-property-value => %(:is-symbol<gtk_accessible_update_property_value>,  :parameters([gint, GEnum, N-Value])),
  update-relation => %(:is-symbol<gtk_accessible_update_relation>, :variable-list,  :parameters([GEnum])),
  update-relation-value => %(:is-symbol<gtk_accessible_update_relation_value>,  :parameters([gint, GEnum, N-Value])),
  update-state => %(:is-symbol<gtk_accessible_update_state>, :variable-list,  :parameters([GEnum])),
  update-state-value => %(:is-symbol<gtk_accessible_update_state_value>,  :parameters([gint, GEnum, N-Value])),
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
