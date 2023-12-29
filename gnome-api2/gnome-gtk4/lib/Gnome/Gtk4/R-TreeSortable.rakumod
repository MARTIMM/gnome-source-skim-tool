=comment Package: Gtk4, C-Source: treesortable
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;


#-------------------------------------------------------------------------------
#--[Role Declaration]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit role Gnome::Gtk4::R-TreeSortable:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-sort-column-id => %(:is-symbol<gtk_tree_sortable_get_sort_column_id>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr, GEnum])),
  has-default-sort-func => %(:is-symbol<gtk_tree_sortable_has_default_sort_func>,  :returns(gboolean), :cnv-return(Bool)),
  #set-default-sort-func => %(:is-symbol<gtk_tree_sortable_set_default_sort_func>,  :parameters([:( N-Object $model, N-TreeIter $a, N-TreeIter $b, gpointer $user-data --> gint ), gpointer, ])),
  set-sort-column-id => %(:is-symbol<gtk_tree_sortable_set_sort_column_id>,  :parameters([gint, GEnum])),
  #set-sort-func => %(:is-symbol<gtk_tree_sortable_set_sort_func>,  :parameters([gint, :( N-Object $model, N-TreeIter $a, N-TreeIter $b, gpointer $user-data --> gint ), gpointer, ])),
  sort-column-changed => %(:is-symbol<gtk_tree_sortable_sort_column_changed>, ),
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
