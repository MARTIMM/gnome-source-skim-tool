=comment Package: Gtk4, C-Source: treestore
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::GObject::T-value:api<2>;

use Gnome::GObject::Object:api<2>;

use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
use Gnome::Gtk4::R-TreeDragDest:api<2>;
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

unit class Gnome::Gtk4::TreeStore:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gtk4::R-Buildable;
also does Gnome::Gtk4::R-TreeDragDest;
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
    self._add_gtk_buildable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_buildable_signal_types');
    self._add_gtk_tree_drag_dest_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_tree_drag_dest_signal_types');
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
  if self.^name eq 'Gnome::Gtk4::TreeStore' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeStore');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-treestore => %( :type(Constructor), :is-symbol<gtk_tree_store_new>, :returns(N-Object), :variable-list, :parameters([ gint])),
  #newv => %( :type(Constructor), :is-symbol<gtk_tree_store_newv>, :returns(N-Object), :parameters([ gint, ])),

  #--[Methods]------------------------------------------------------------------
  append => %(:is-symbol<gtk_tree_store_append>,  :parameters([N-TreeIter, N-TreeIter])),
  clear => %(:is-symbol<gtk_tree_store_clear>, ),
  insert => %(:is-symbol<gtk_tree_store_insert>,  :parameters([N-TreeIter, N-TreeIter, gint])),
  insert-after => %(:is-symbol<gtk_tree_store_insert_after>,  :parameters([N-TreeIter, N-TreeIter, N-TreeIter])),
  insert-before => %(:is-symbol<gtk_tree_store_insert_before>,  :parameters([N-TreeIter, N-TreeIter, N-TreeIter])),
  insert-with-values => %(:is-symbol<gtk_tree_store_insert_with_values>, :variable-list,  :parameters([N-TreeIter, N-TreeIter, gint])),
  insert-with-valuesv => %(:is-symbol<gtk_tree_store_insert_with_valuesv>,  :parameters([N-TreeIter, N-TreeIter, gint, gint-ptr, N-Value, gint])),
  is-ancestor => %(:is-symbol<gtk_tree_store_is_ancestor>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter, N-TreeIter])),
  iter-depth => %(:is-symbol<gtk_tree_store_iter_depth>,  :returns(gint), :parameters([N-TreeIter])),
  iter-is-valid => %(:is-symbol<gtk_tree_store_iter_is_valid>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  move-after => %(:is-symbol<gtk_tree_store_move_after>,  :parameters([N-TreeIter, N-TreeIter])),
  move-before => %(:is-symbol<gtk_tree_store_move_before>,  :parameters([N-TreeIter, N-TreeIter])),
  prepend => %(:is-symbol<gtk_tree_store_prepend>,  :parameters([N-TreeIter, N-TreeIter])),
  remove => %(:is-symbol<gtk_tree_store_remove>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreeIter])),
  reorder => %(:is-symbol<gtk_tree_store_reorder>,  :parameters([N-TreeIter, gint-ptr])),
  set => %(:is-symbol<gtk_tree_store_set>, :variable-list,  :parameters([N-TreeIter])),
  #set-column-types => %(:is-symbol<gtk_tree_store_set_column_types>,  :parameters([gint, ])),
  #set-valist => %(:is-symbol<gtk_tree_store_set_valist>,  :parameters([N-TreeIter, ])),
  set-value => %(:is-symbol<gtk_tree_store_set_value>,  :parameters([N-TreeIter, gint, N-Value])),
  set-valuesv => %(:is-symbol<gtk_tree_store_set_valuesv>,  :parameters([N-TreeIter, gint-ptr, N-Value, gint])),
  swap => %(:is-symbol<gtk_tree_store_swap>,  :parameters([N-TreeIter, N-TreeIter])),
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
    $r = self._do_gtk_buildable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_buildable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_tree_drag_dest_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_tree_drag_dest_fallback-v2');
    return $r if $_fallback-v2-ok;

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
