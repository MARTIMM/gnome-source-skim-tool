=comment Package: Gtk4, C-Source: liststore
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::Object:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
use Gnome::Gtk4::R-TreeDragDest:api<2>;
use Gnome::Gtk4::R-TreeDragSource:api<2>;
use Gnome::Gtk4::R-TreeModel:api<2>;
use Gnome::Gtk4::R-TreeSortable:api<2>;
use Gnome::Gtk4::T-treemodel:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ListStore:auth<github:MARTIMM>:api<2>;
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

  Gnome::N::deprecate(
    'Gnome::Gtk4::ListStore', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

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
  if self.^name eq 'Gnome::Gtk4::ListStore' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkListStore');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-liststore => %( :type(Constructor), :is-symbol<gtk_list_store_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :variable-list, :parameters([ gint]), ),
  #newv => %( :type(Constructor), :is-symbol<gtk_list_store_newv>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ gint, ]), ),

  #--[Methods]------------------------------------------------------------------
  append => %(:is-symbol<gtk_list_store_append>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  clear => %(:is-symbol<gtk_list_store_clear>, :deprecated, :deprecated-version<4.10>, ),
  insert => %(:is-symbol<gtk_list_store_insert>, :parameters([N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  insert-after => %(:is-symbol<gtk_list_store_insert_after>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  insert-before => %(:is-symbol<gtk_list_store_insert_before>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  insert-with-values => %(:is-symbol<gtk_list_store_insert_with_values>, :variable-list, :parameters([N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  insert-with-valuesv => %(:is-symbol<gtk_list_store_insert_with_valuesv>, :parameters([N-Object, gint, gint-ptr, N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  iter-is-valid => %(:is-symbol<gtk_list_store_iter_is_valid>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  move-after => %(:is-symbol<gtk_list_store_move_after>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  move-before => %(:is-symbol<gtk_list_store_move_before>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  prepend => %(:is-symbol<gtk_list_store_prepend>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  remove => %(:is-symbol<gtk_list_store_remove>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  reorder => %(:is-symbol<gtk_list_store_reorder>, :parameters([gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
  set => %(:is-symbol<gtk_list_store_set>, :variable-list, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  #set-column-types => %(:is-symbol<gtk_list_store_set_column_types>, :parameters([gint, ]), :deprecated, :deprecated-version<4.10>, ),
  #set-valist => %(:is-symbol<gtk_list_store_set_valist>, :parameters([N-Object, ]), :deprecated, :deprecated-version<4.10>, ),
  set-value => %(:is-symbol<gtk_list_store_set_value>, :parameters([N-Object, gint, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  set-valuesv => %(:is-symbol<gtk_list_store_set_valuesv>, :parameters([N-Object, gint-ptr, N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  swap => %(:is-symbol<gtk_list_store_swap>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
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
