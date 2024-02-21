=comment Package: Gio, C-Source: action
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;
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

unit role Gnome::Gio::R-Action:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  activate => %(:is-symbol<g_action_activate>,  :parameters([N-Variant])),
  change-state => %(:is-symbol<g_action_change_state>,  :parameters([N-Variant])),
  get-enabled => %(:is-symbol<g_action_get_enabled>,  :returns(gboolean), :cnv-return(Bool)),
  get-name => %(:is-symbol<g_action_get_name>,  :returns(Str)),
  get-parameter-type => %(:is-symbol<g_action_get_parameter_type>,  :returns(N-VariantType)),
  get-state => %(:is-symbol<g_action_get_state>,  :returns(N-Variant)),
  get-state-hint => %(:is-symbol<g_action_get_state_hint>,  :returns(N-Variant)),
  get-state-type => %(:is-symbol<g_action_get_state_type>,  :returns(N-VariantType)),

  #--[Functions]----------------------------------------------------------------
  name-is-valid => %( :type(Function), :is-symbol<g_action_name_is_valid>,  :returns(gboolean), :parameters([Str])),
  parse-detailed-name => %( :type(Function), :is-symbol<g_action_parse_detailed_name>,  :returns(gboolean), :parameters([ Str, gchar-pptr, CArray[N-Variant], CArray[N-Error]])),
  print-detailed-name => %( :type(Function), :is-symbol<g_action_print_detailed_name>,  :returns(Str), :parameters([ Str, N-Variant])),
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
