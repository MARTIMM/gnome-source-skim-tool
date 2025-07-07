=comment Package: Gtk4, C-Source: actionable
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::T-variant:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::R-Actionable:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-action-name => %(:is-symbol<gtk_actionable_get_action_name>, :returns(Str), ),
  get-action-target-value => %(:is-symbol<gtk_actionable_get_action_target_value>, :returns(N-Object), ),
  set-action-name => %(:is-symbol<gtk_actionable_set_action_name>, :parameters([Str]), ),
  set-action-target => %(:is-symbol<gtk_actionable_set_action_target>, :variable-list, :parameters([Str]), ),
  set-action-target-value => %(:is-symbol<gtk_actionable_set_action_target_value>, :parameters([N-Object]), ),
  set-detailed-action-name => %(:is-symbol<gtk_actionable_set_detailed_action_name>, :parameters([Str]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_actionable_fallback-v2 (
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
