=comment Package: Gtk4, C-Source: treemodelfilter
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::Object:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::Gtk4::R-TreeDragSource:api<2>;
use Gnome::Gtk4::R-TreeModel:api<2>;
#use Gnome::Gtk4::T-treemodel:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::TreeModelFilter:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gtk4::R-TreeDragSource;
also does Gnome::Gtk4::R-TreeModel;

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
    'Gnome::Gtk4::TreeModelFilter', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    
    # Signals from interfaces
    self._add_gtk_tree_drag_source_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_tree_drag_source_signal_types');
    self._add_gtk_tree_model_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_tree_model_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TreeModelFilter' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeModelFilter');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  clear-cache => %(:is-symbol<gtk_tree_model_filter_clear_cache>, :deprecated, :deprecated-version<4.10>, ),
  convert-child-iter-to-iter => %(:is-symbol<gtk_tree_model_filter_convert_child_iter_to_iter>, :returns(gboolean), :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  convert-child-path-to-path => %(:is-symbol<gtk_tree_model_filter_convert_child_path_to_path>, :returns(N-Object), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  convert-iter-to-child-iter => %(:is-symbol<gtk_tree_model_filter_convert_iter_to_child_iter>, :parameters([N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  convert-path-to-child-path => %(:is-symbol<gtk_tree_model_filter_convert_path_to_child_path>, :returns(N-Object), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-model => %(:is-symbol<gtk_tree_model_filter_get_model>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  refilter => %(:is-symbol<gtk_tree_model_filter_refilter>, :deprecated, :deprecated-version<4.10>, ),
  #set-modify-func => %(:is-symbol<gtk_tree_model_filter_set_modify_func>, :parameters([gint, , :( N-Object $model, N-Object $iter, N-Object $value, gint $column, gpointer $data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
  set-visible-column => %(:is-symbol<gtk_tree_model_filter_set_visible_column>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-visible-func => %(:is-symbol<gtk_tree_model_filter_set_visible_func>, :parameters([:( N-Object $model, N-Object $iter, gpointer $data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
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

    callsame;
  }
}
