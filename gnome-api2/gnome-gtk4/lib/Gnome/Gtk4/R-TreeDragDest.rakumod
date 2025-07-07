=comment Package: Gtk4, C-Source: treednd
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::T-value:api<2>;
#use Gnome::Gtk4::T-treemodel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::R-TreeDragDest:auth<github:MARTIMM>:api<2>;


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  drag-data-received => %(:is-symbol<gtk_tree_drag_dest_drag_data_received>, :returns(gboolean), :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  row-drop-possible => %(:is-symbol<gtk_tree_drag_dest_row_drop_possible>, :returns(gboolean), :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_tree_drag_dest_fallback-v2 (
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
