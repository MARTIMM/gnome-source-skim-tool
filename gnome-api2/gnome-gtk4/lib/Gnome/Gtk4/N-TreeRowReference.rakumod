=comment Package: Gtk4, C-Source: treemodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::N-TreePath:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::N-TreeRowReference:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
class N-TreeRowReference:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

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
  if self.^name eq 'Gnome::Gtk4::TreeRowReference' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTreeRowReference');
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
  new-treerowreference => %( :type(Constructor), :is-symbol<gtk_tree_row_reference_new>, :returns(N-TreeRowReference), :parameters([ N-Object, N-TreePath])),
  new-proxy => %( :type(Constructor), :is-symbol<gtk_tree_row_reference_new_proxy>, :returns(N-TreeRowReference), :parameters([ N-Object, N-Object, N-TreePath])),

  #--[Methods]------------------------------------------------------------------
  copy => %(:is-symbol<gtk_tree_row_reference_copy>,  :returns(N-TreeRowReference)),
  free => %(:is-symbol<gtk_tree_row_reference_free>, ),
  get-model => %(:is-symbol<gtk_tree_row_reference_get_model>,  :returns(N-Object)),
  get-path => %(:is-symbol<gtk_tree_row_reference_get_path>,  :returns(N-TreePath)),
  valid => %(:is-symbol<gtk_tree_row_reference_valid>,  :returns(gboolean), :cnv-return(Bool)),

  #--[Functions]----------------------------------------------------------------
  deleted => %( :type(Function), :is-symbol<gtk_tree_row_reference_deleted>,  :parameters([ N-Object, N-TreePath])),
  inserted => %( :type(Function), :is-symbol<gtk_tree_row_reference_inserted>,  :parameters([ N-Object, N-TreePath])),
  reordered => %( :type(Function), :is-symbol<gtk_tree_row_reference_reordered>,  :parameters([ N-Object, N-TreePath, N-TreeIter, gint-ptr])),
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

      # Check the function name. 
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
