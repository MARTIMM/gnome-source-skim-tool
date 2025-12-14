=comment Package: Gtk4, C-Source: treesortable
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::T-treemodel:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-TreeSortable:auth<github:MARTIMM>:api<2>;

#TM:1:_add_gtk_tree_sortable_signal_types:
method _add_gtk_tree_sortable_signal_types ( Str $class-name ) {
  self.add-signal-types( $class-name,
    :w0<sort-column-changed>,
  );
}


#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-sort-column-id => %(:is-symbol<gtk_tree_sortable_get_sort_column_id>, :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr, GEnum]), :deprecated, :deprecated-version<4.10>, ),
  has-default-sort-func => %(:is-symbol<gtk_tree_sortable_has_default_sort_func>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  set-default-sort-func => %(:is-symbol<gtk_tree_sortable_set_default_sort_func>, :parameters([:( N-Object $model, N-Object $a, N-Object $b, gpointer $user-data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
  set-sort-column-id => %(:is-symbol<gtk_tree_sortable_set_sort_column_id>, :parameters([gint, GEnum]), :deprecated, :deprecated-version<4.10>, ),
  set-sort-func => %(:is-symbol<gtk_tree_sortable_set_sort_func>, :parameters([gint, :( N-Object $model, N-Object $a, N-Object $b, gpointer $user-data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
  sort-column-changed => %(:is-symbol<gtk_tree_sortable_sort_column_changed>, :deprecated, :deprecated-version<4.10>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _do_gtk_tree_sortable_fallback-v2 (
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
