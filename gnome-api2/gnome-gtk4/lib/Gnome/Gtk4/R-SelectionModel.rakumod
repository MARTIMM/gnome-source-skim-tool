=comment Package: Gtk4, C-Source: selectionmodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::R-SelectionModel:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-selection => %(:is-symbol<gtk_selection_model_get_selection>, :returns(N-Object), ),
  get-selection-in-range => %(:is-symbol<gtk_selection_model_get_selection_in_range>, :returns(N-Object), :parameters([guint, guint]), ),
  is-selected => %(:is-symbol<gtk_selection_model_is_selected>, :returns(gboolean), :parameters([guint]), ),
  select-all => %(:is-symbol<gtk_selection_model_select_all>, :returns(gboolean), ),
  select-item => %(:is-symbol<gtk_selection_model_select_item>, :returns(gboolean), :parameters([guint, gboolean]), ),
  select-range => %(:is-symbol<gtk_selection_model_select_range>, :returns(gboolean), :parameters([guint, guint, gboolean]), ),
  selection-changed => %(:is-symbol<gtk_selection_model_selection_changed>, :parameters([guint, guint]), ),
  set-selection => %(:is-symbol<gtk_selection_model_set_selection>, :returns(gboolean), :parameters([N-Object, N-Object]), ),
  unselect-all => %(:is-symbol<gtk_selection_model_unselect_all>, :returns(gboolean), ),
  unselect-item => %(:is-symbol<gtk_selection_model_unselect_item>, :returns(gboolean), :parameters([guint]), ),
  unselect-range => %(:is-symbol<gtk_selection_model_unselect_range>, :returns(gboolean), :parameters([guint, guint]), ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_selection_model_fallback-v2 (
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
