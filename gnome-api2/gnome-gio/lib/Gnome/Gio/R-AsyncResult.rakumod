=comment Package: Gio, C-Source: asyncresult
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::R-AsyncResult:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-source-object => %(:is-symbol<g_async_result_get_source_object>,  :returns(N-Object)),
  get-user-data => %(:is-symbol<g_async_result_get_user_data>,  :returns(gpointer)),
  is-tagged => %(:is-symbol<g_async_result_is_tagged>,  :returns(gboolean), :cnv-return(Bool), :parameters([gpointer])),
  legacy-propagate-error => %(:is-symbol<g_async_result_legacy_propagate_error>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[N-Error]])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_g_async_result_fallback-v2 (
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
