=comment Package: Gtk4, C-Source: treednd
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::T-treemodel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-TreeDragSource:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  drag-data-delete => %(:is-symbol<gtk_tree_drag_source_drag_data_delete>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  drag-data-get => %(:is-symbol<gtk_tree_drag_source_drag_data_get>, :returns(N-Object), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  row-draggable => %(:is-symbol<gtk_tree_drag_source_row_draggable>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_tree_drag_source_fallback-v2 (
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
