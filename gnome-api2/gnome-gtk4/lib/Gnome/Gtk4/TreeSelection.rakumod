=comment Package: Gtk4, C-Source: treeselection
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::GObject::Object:api<2>;

use Gnome::Glib::T-list:api<2>;

use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::T-enums:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::TreeSelection:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

# Add signal registration helper
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {
  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TreeSelection' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeSelection');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  count-selected-rows => %(:is-symbol<gtk_tree_selection_count_selected_rows>,  :returns(gint)),
  get-mode => %(:is-symbol<gtk_tree_selection_get_mode>,  :returns(GEnum), :cnv-return(GtkSelectionMode)),
#  get-select-function => %(:is-symbol<gtk_tree_selection_get_select_function>,  :returns(), :cnv-return(( N-Object $selection, N-Object $model, N-TreePath $path, gboolean $path-currently-selected, gpointer $data --> gboolean ))),
  get-selected => %(:is-symbol<gtk_tree_selection_get_selected>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[N-Object], N-TreeIter])),
  get-selected-rows => %(:is-symbol<gtk_tree_selection_get_selected_rows>,  :returns(N-List), :parameters([CArray[N-Object]])),
  get-tree-view => %(:is-symbol<gtk_tree_selection_get_tree_view>,  :returns(N-Object)),
  get-user-data => %(:is-symbol<gtk_tree_selection_get_user_data>,  :returns(gpointer)),
  iter-is-selected => %(:is-symbol<gtk_tree_selection_iter_is_selected>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  path-is-selected => %(:is-symbol<gtk_tree_selection_path_is_selected>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath])),
  select-all => %(:is-symbol<gtk_tree_selection_select_all>, ),
  select-iter => %(:is-symbol<gtk_tree_selection_select_iter>,  :parameters([N-TreeIter])),
  select-path => %(:is-symbol<gtk_tree_selection_select_path>,  :parameters([N-TreePath])),
  select-range => %(:is-symbol<gtk_tree_selection_select_range>,  :parameters([N-TreePath, N-TreePath])),
  selected-foreach => %(:is-symbol<gtk_tree_selection_selected_foreach>,  :parameters([:( N-Object $model, N-TreePath $path, N-TreeIter $iter, gpointer $data ), gpointer])),
  set-mode => %(:is-symbol<gtk_tree_selection_set_mode>,  :parameters([GEnum])),
  #set-select-function => %(:is-symbol<gtk_tree_selection_set_select_function>,  :parameters([:( N-Object $selection, N-Object $model, N-TreePath $path, gboolean $path-currently-selected, gpointer $data --> gboolean ), gpointer, ])),
  unselect-all => %(:is-symbol<gtk_tree_selection_unselect_all>, ),
  unselect-iter => %(:is-symbol<gtk_tree_selection_unselect_iter>,  :parameters([N-TreeIter])),
  unselect-path => %(:is-symbol<gtk_tree_selection_unselect_path>,  :parameters([N-TreePath])),
  unselect-range => %(:is-symbol<gtk_tree_selection_unselect_range>,  :parameters([N-TreePath, N-TreePath])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw, *@arguments, *%options
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
      );

      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        ),
        |%options
      );
    }

    elsif $methods{$name}<type>:exists and $methods{$name}<type> eq 'Function' {
      return $!routine-caller.call-native-sub( $name, @arguments, $methods);
    }

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, $native-object
      );
    }
  }

  else {
    callsame;
  }
}
