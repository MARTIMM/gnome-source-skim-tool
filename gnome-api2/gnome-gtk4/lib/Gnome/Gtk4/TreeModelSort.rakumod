=comment Package: Gtk4, C-Source: treemodelsort
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::R-TreeDragSource:api<2>;
use Gnome::Gtk4::R-TreeModel:api<2>;
use Gnome::Gtk4::R-TreeSortable:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::TreeModelSort:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gtk4::R-TreeDragSource;
also does Gnome::Gtk4::R-TreeModel;
also does Gnome::Gtk4::R-TreeSortable;

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
    
    # Signals from interfaces
    self._add_gtk_tree_drag_source_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_tree_drag_source_signal_types');
    self._add_gtk_tree_model_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_tree_model_signal_types');
    self._add_gtk_tree_sortable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_tree_sortable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TreeModelSort' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeModelSort');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-with-model => %( :type(Constructor), :is-symbol<gtk_tree_model_sort_new_with_model>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  clear-cache => %(:is-symbol<gtk_tree_model_sort_clear_cache>, ),
  convert-child-iter-to-iter => %(:is-symbol<gtk_tree_model_sort_convert_child_iter_to_iter>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter, N-TreeIter])),
  convert-child-path-to-path => %(:is-symbol<gtk_tree_model_sort_convert_child_path_to_path>,  :returns(N-TreePath), :parameters([N-TreePath])),
  convert-iter-to-child-iter => %(:is-symbol<gtk_tree_model_sort_convert_iter_to_child_iter>,  :parameters([N-TreeIter, N-TreeIter])),
  convert-path-to-child-path => %(:is-symbol<gtk_tree_model_sort_convert_path_to_child_path>,  :returns(N-TreePath), :parameters([N-TreePath])),
  get-model => %(:is-symbol<gtk_tree_model_sort_get_model>,  :returns(N-Object)),
  iter-is-valid => %(:is-symbol<gtk_tree_model_sort_iter_is_valid>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  reset-default-sort-func => %(:is-symbol<gtk_tree_model_sort_reset_default_sort_func>, ),
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
    $r = self._do_gtk_tree_drag_source_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_tree_drag_source_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_tree_model_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_tree_model_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_tree_sortable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_tree_sortable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
