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

unit class Gnome::Glib::N-ByteArray:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Glib::ByteArray' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GByteArray');
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

  #--[Functions]----------------------------------------------------------------
  #append => %( :type(Function), :is-symbol<g_byte_array_append>,  :returns(N-Object), :parameters([ N-Object, , guint])),
  #free => %( :type(Function), :is-symbol<g_byte_array_free>,  :parameters([ N-Object, gboolean])),
  free-to-bytes => %( :type(Function), :is-symbol<g_byte_array_free_to_bytes>,  :returns(N-Object), :parameters([N-Object])),
  new => %( :type(Function), :is-symbol<g_byte_array_new>,  :returns(N-Object)),
  #new-take => %( :type(Function), :is-symbol<g_byte_array_new_take>,  :returns(N-Object), :parameters([ , gsize])),
  #prepend => %( :type(Function), :is-symbol<g_byte_array_prepend>,  :returns(N-Object), :parameters([ N-Object, , guint])),
  ref => %( :type(Function), :is-symbol<g_byte_array_ref>,  :returns(N-Object), :parameters([N-Object])),
  remove-index => %( :type(Function), :is-symbol<g_byte_array_remove_index>,  :returns(N-Object), :parameters([ N-Object, guint])),
  remove-index-fast => %( :type(Function), :is-symbol<g_byte_array_remove_index_fast>,  :returns(N-Object), :parameters([ N-Object, guint])),
  remove-range => %( :type(Function), :is-symbol<g_byte_array_remove_range>,  :returns(N-Object), :parameters([ N-Object, guint, guint])),
  set-size => %( :type(Function), :is-symbol<g_byte_array_set_size>,  :returns(N-Object), :parameters([ N-Object, guint])),
  sized-new => %( :type(Function), :is-symbol<g_byte_array_sized_new>,  :returns(N-Object), :parameters([guint])),
  sort => %( :type(Function), :is-symbol<g_byte_array_sort>,  :parameters([ N-Object, :( gpointer $a, gpointer $b --> gint )])),
  sort-with-data => %( :type(Function), :is-symbol<g_byte_array_sort_with_data>,  :parameters([ N-Object, :( gpointer $a, gpointer $b, gpointer $user-data --> gint ), gpointer])),
  #steal => %( :type(Function), :is-symbol<g_byte_array_steal>,  :parameters([ N-Object, CArray[gsize]])),
  unref => %( :type(Function), :is-symbol<g_byte_array_unref>,  :parameters([N-Object])),
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
