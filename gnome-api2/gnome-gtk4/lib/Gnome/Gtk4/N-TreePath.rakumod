=comment Package: Gtk4, C-Source: treemodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::N-TreePath:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
class N-TreePath:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TreePath' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreePath');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-treepath => %( :type(Constructor), :is-symbol<gtk_tree_path_new>, :returns(N-TreePath), ),
  new-first => %( :type(Constructor), :is-symbol<gtk_tree_path_new_first>, :returns(N-TreePath), ),
  new-from-indices => %( :type(Constructor), :is-symbol<gtk_tree_path_new_from_indices>, :returns(N-TreePath), :variable-list, :parameters([ gint])),
  new-from-indicesv => %( :type(Constructor), :is-symbol<gtk_tree_path_new_from_indicesv>, :returns(N-TreePath), :parameters([ gint-ptr, gsize])),
  new-from-string => %( :type(Constructor), :is-symbol<gtk_tree_path_new_from_string>, :returns(N-TreePath), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  append-index => %(:is-symbol<gtk_tree_path_append_index>,  :parameters([gint])),
  compare => %(:is-symbol<gtk_tree_path_compare>,  :returns(gint), :parameters([N-TreePath])),
  copy => %(:is-symbol<gtk_tree_path_copy>,  :returns(N-TreePath)),
  down => %(:is-symbol<gtk_tree_path_down>, ),
  free => %(:is-symbol<gtk_tree_path_free>, ),
  get-depth => %(:is-symbol<gtk_tree_path_get_depth>,  :returns(gint)),
  get-indices => %(:is-symbol<gtk_tree_path_get_indices>,  :returns(gint-ptr)),
  get-indices-with-depth => %(:is-symbol<gtk_tree_path_get_indices_with_depth>,  :returns(gint-ptr), :parameters([gint-ptr])),
  is-ancestor => %(:is-symbol<gtk_tree_path_is_ancestor>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath])),
  is-descendant => %(:is-symbol<gtk_tree_path_is_descendant>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TreePath])),
  next => %(:is-symbol<gtk_tree_path_next>, ),
  prepend-index => %(:is-symbol<gtk_tree_path_prepend_index>,  :parameters([gint])),
  prev => %(:is-symbol<gtk_tree_path_prev>,  :returns(gboolean), :cnv-return(Bool)),
  to-string => %(:is-symbol<gtk_tree_path_to_string>,  :returns(Str)),
  up => %(:is-symbol<gtk_tree_path_up>,  :returns(gboolean), :cnv-return(Bool)),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
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
