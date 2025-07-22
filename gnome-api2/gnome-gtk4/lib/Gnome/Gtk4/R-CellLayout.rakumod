=comment Package: Gtk4, C-Source: celllayout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Glib::N-List:api<2>;
use Gnome::Glib::T-list:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::T-treemodel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-CellLayout:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  add-attribute => %(:is-symbol<gtk_cell_layout_add_attribute>, :parameters([N-Object, Str, gint]), :deprecated, :deprecated-version<4.10>, ),
  clear => %(:is-symbol<gtk_cell_layout_clear>, :deprecated, :deprecated-version<4.10>, ),
  clear-attributes => %(:is-symbol<gtk_cell_layout_clear_attributes>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-area => %(:is-symbol<gtk_cell_layout_get_area>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-cells => %(:is-symbol<gtk_cell_layout_get_cells>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  pack-end => %(:is-symbol<gtk_cell_layout_pack_end>, :parameters([N-Object, gboolean]), :deprecated, :deprecated-version<4.10>, ),
  pack-start => %(:is-symbol<gtk_cell_layout_pack_start>, :parameters([N-Object, gboolean]), :deprecated, :deprecated-version<4.10>, ),
  reorder => %(:is-symbol<gtk_cell_layout_reorder>, :parameters([N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  set-attributes => %(:is-symbol<gtk_cell_layout_set_attributes>, :variable-list, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  set-cell-data-func => %(:is-symbol<gtk_cell_layout_set_cell_data_func>, :parameters([N-Object, :( N-Object $cell-layout, N-Object $cell, N-Object $tree-model, N-Object $iter, gpointer $data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_cell_layout_fallback-v2 (
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
