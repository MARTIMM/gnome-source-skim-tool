=comment Package: Gio, C-Source: actiongroup
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::T-variant:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::Glib::T-varianttype:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gio::R-ActionGroup:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  action-added => %(:is-symbol<g_action_group_action_added>,  :parameters([Str])),
  action-enabled-changed => %(:is-symbol<g_action_group_action_enabled_changed>,  :parameters([Str, gboolean])),
  action-removed => %(:is-symbol<g_action_group_action_removed>,  :parameters([Str])),
  action-state-changed => %(:is-symbol<g_action_group_action_state_changed>,  :parameters([Str, N-Variant])),
  activate-action => %(:is-symbol<g_action_group_activate_action>,  :parameters([Str, N-Variant])),
  change-action-state => %(:is-symbol<g_action_group_change_action_state>,  :parameters([Str, N-Variant])),
  get-action-enabled => %(:is-symbol<g_action_group_get_action_enabled>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  get-action-parameter-type => %(:is-symbol<g_action_group_get_action_parameter_type>,  :returns(N-VariantType), :parameters([Str])),
  get-action-state => %(:is-symbol<g_action_group_get_action_state>,  :returns(N-Variant), :parameters([Str])),
  get-action-state-hint => %(:is-symbol<g_action_group_get_action_state_hint>,  :returns(N-Variant), :parameters([Str])),
  get-action-state-type => %(:is-symbol<g_action_group_get_action_state_type>,  :returns(N-VariantType), :parameters([Str])),
  has-action => %(:is-symbol<g_action_group_has_action>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  list-actions => %(:is-symbol<g_action_group_list_actions>,  :returns(gchar-pptr)),
  #query-action => %(:is-symbol<g_action_group_query_action>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, , CArray[N-VariantType], CArray[N-VariantType], CArray[N-Variant], CArray[N-Variant]])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 (
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
