=comment Package: Gtk4, C-Source: treemodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::Gtk4::T-treemodel:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::N-TreeRowReference:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  Gnome::N::deprecate(
    'Gnome::Gtk4::N-TreeRowReference', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );


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
  new-treerowreference => %( :type(Constructor), :is-symbol<gtk_tree_row_reference_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ N-Object, N-Object]), ),
  new-proxy => %( :type(Constructor), :is-symbol<gtk_tree_row_reference_new_proxy>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ N-Object, N-Object, N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  copy => %(:is-symbol<gtk_tree_row_reference_copy>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  free => %(:is-symbol<gtk_tree_row_reference_free>, :deprecated, :deprecated-version<4.10>, ),
  get-model => %(:is-symbol<gtk_tree_row_reference_get_model>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  get-path => %(:is-symbol<gtk_tree_row_reference_get_path>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  valid => %(:is-symbol<gtk_tree_row_reference_valid>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),

  #--[Functions]----------------------------------------------------------------
  deleted => %( :type(Function), :is-symbol<gtk_tree_row_reference_deleted>, :parameters([ N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  inserted => %( :type(Function), :is-symbol<gtk_tree_row_reference_inserted>, :parameters([ N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  reordered => %( :type(Function), :is-symbol<gtk_tree_row_reference_reordered>, :parameters([ N-Object, N-Object, N-Object, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),
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
