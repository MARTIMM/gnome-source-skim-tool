=comment Package: Glib, C-Source: array
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::Glib::T-array:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-Bytes:auth<github:MARTIMM>:api<2>;
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

  # Initialize helper
  $!routine-caller .= new(:library(glib-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::Bytes' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GBytes');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
  self._fallback-v2( 'unref', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-bytes => %( :type(Constructor), :is-symbol<g_bytes_new>, :returns(N-Object), :parameters([ gpointer, gsize])),
  new-static => %( :type(Constructor), :is-symbol<g_bytes_new_static>, :returns(N-Object), :parameters([ gpointer, gsize])),
  new-take => %( :type(Constructor), :is-symbol<g_bytes_new_take>, :returns(N-Object), :parameters([ gpointer, gsize])),
  #new-with-free-func => %( :type(Constructor), :is-symbol<g_bytes_new_with_free_func>, :returns(N-Object), :parameters([ gpointer, gsize, , gpointer])),

  #--[Methods]------------------------------------------------------------------
  compare => %(:is-symbol<g_bytes_compare>,  :returns(gint), :parameters([gpointer])),
  equal => %(:is-symbol<g_bytes_equal>,  :returns(gboolean), :cnv-return(Bool), :parameters([gpointer])),
  get-data => %(:is-symbol<g_bytes_get_data>,  :returns(gpointer), :parameters([CArray[gsize]])),
  get-region => %(:is-symbol<g_bytes_get_region>,  :returns(gpointer), :parameters([gsize, gsize, gsize])),
  get-size => %(:is-symbol<g_bytes_get_size>,  :returns(gsize)),
  hash => %(:is-symbol<g_bytes_hash>,  :returns(guint)),
  new-from-bytes => %(:is-symbol<g_bytes_new_from_bytes>,  :returns(N-Object), :parameters([gsize, gsize])),
  ref => %(:is-symbol<g_bytes_ref>,  :returns(N-Object)),
  unref => %(:is-symbol<g_bytes_unref>, ),
  unref-to-array => %(:is-symbol<g_bytes_unref_to_array>,  :returns(N-Object)),
  unref-to-data => %(:is-symbol<g_bytes_unref_to_data>,  :returns(gpointer), :parameters([CArray[gsize]])),
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
        :library(glib-lib())
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
