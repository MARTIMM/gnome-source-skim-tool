=comment Package: Gio, C-Source: listmodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gio::R-ListModel:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[role init method]-----------------------------------------------------------
#-------------------------------------------------------------------------------
method _add_g_list_model_signal_types ( $classname ) {
  self.add-signal-types( $classname,
    :w3<items-changed>
  );
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-item => %(:is-symbol<g_list_model_get_item>,  :returns(gpointer), :parameters([guint])),
  get-item-type => %(:is-symbol<g_list_model_get_item_type>,  :returns(GType)),
  get-n-items => %(:is-symbol<g_list_model_get_n_items>,  :returns(guint)),
  get-object => %(:is-symbol<g_list_model_get_object>,  :returns(N-Object), :parameters([guint])),
  items-changed => %(:is-symbol<g_list_model_items_changed>,  :parameters([guint, guint, guint])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_g_list_model_fallback-v2 (
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
