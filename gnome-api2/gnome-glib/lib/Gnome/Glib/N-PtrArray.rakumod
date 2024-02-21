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

unit class Gnome::Glib::N-PtrArray:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Glib::PtrArray' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GPtrArray');
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
  add => %( :type(Function), :is-symbol<g_ptr_array_add>,  :parameters([ N-Object, gpointer])),
  copy => %( :type(Function), :is-symbol<g_ptr_array_copy>,  :returns(N-Object), :parameters([ N-Object, :( gpointer $src, gpointer $data --> gpointer ), gpointer])),
  extend => %( :type(Function), :is-symbol<g_ptr_array_extend>,  :parameters([ N-Object, N-Object, :( gpointer $src, gpointer $data --> gpointer ), gpointer])),
  extend-and-steal => %( :type(Function), :is-symbol<g_ptr_array_extend_and_steal>,  :parameters([ N-Object, N-Object])),
  find => %( :type(Function), :is-symbol<g_ptr_array_find>,  :returns(gboolean), :parameters([ N-Object, gpointer, gint-ptr])),
  find-with-equal-func => %( :type(Function), :is-symbol<g_ptr_array_find_with_equal_func>,  :returns(gboolean), :parameters([ N-Object, gpointer, :( gpointer $a, gpointer $b --> gboolean ), gint-ptr])),
  foreach => %( :type(Function), :is-symbol<g_ptr_array_foreach>,  :parameters([ N-Object, :( gpointer $data, gpointer $user-data ), gpointer])),
  free => %( :type(Function), :is-symbol<g_ptr_array_free>,  :returns(CArray[gpointer]), :parameters([ N-Object, gboolean])),
  insert => %( :type(Function), :is-symbol<g_ptr_array_insert>,  :parameters([ N-Object, gint, gpointer])),
  new => %( :type(Function), :is-symbol<g_ptr_array_new>,  :returns(N-Object)),
  new-full => %( :type(Function), :is-symbol<g_ptr_array_new_full>,  :returns(N-Object), :parameters([ guint, :( gpointer $data )])),
  new-with-free-func => %( :type(Function), :is-symbol<g_ptr_array_new_with_free_func>,  :returns(N-Object), :parameters([:( gpointer $data )])),
  ref => %( :type(Function), :is-symbol<g_ptr_array_ref>,  :returns(N-Object), :parameters([N-Object])),
  remove => %( :type(Function), :is-symbol<g_ptr_array_remove>,  :returns(gboolean), :parameters([ N-Object, gpointer])),
  remove-fast => %( :type(Function), :is-symbol<g_ptr_array_remove_fast>,  :returns(gboolean), :parameters([ N-Object, gpointer])),
  remove-index => %( :type(Function), :is-symbol<g_ptr_array_remove_index>,  :returns(gpointer), :parameters([ N-Object, guint])),
  remove-index-fast => %( :type(Function), :is-symbol<g_ptr_array_remove_index_fast>,  :returns(gpointer), :parameters([ N-Object, guint])),
  remove-range => %( :type(Function), :is-symbol<g_ptr_array_remove_range>,  :returns(N-Object), :parameters([ N-Object, guint, guint])),
  set-free-func => %( :type(Function), :is-symbol<g_ptr_array_set_free_func>,  :parameters([ N-Object, :( gpointer $data )])),
  set-size => %( :type(Function), :is-symbol<g_ptr_array_set_size>,  :parameters([ N-Object, gint])),
  sized-new => %( :type(Function), :is-symbol<g_ptr_array_sized_new>,  :returns(N-Object), :parameters([guint])),
  sort => %( :type(Function), :is-symbol<g_ptr_array_sort>,  :parameters([ N-Object, :( gpointer $a, gpointer $b --> gint )])),
  sort-with-data => %( :type(Function), :is-symbol<g_ptr_array_sort_with_data>,  :parameters([ N-Object, :( gpointer $a, gpointer $b, gpointer $user-data --> gint ), gpointer])),
  steal => %( :type(Function), :is-symbol<g_ptr_array_steal>,  :returns(CArray[gpointer]), :parameters([ N-Object, CArray[gsize]])),
  steal-index => %( :type(Function), :is-symbol<g_ptr_array_steal_index>,  :returns(gpointer), :parameters([ N-Object, guint])),
  steal-index-fast => %( :type(Function), :is-symbol<g_ptr_array_steal_index_fast>,  :returns(gpointer), :parameters([ N-Object, guint])),
  unref => %( :type(Function), :is-symbol<g_ptr_array_unref>,  :parameters([N-Object])),
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
