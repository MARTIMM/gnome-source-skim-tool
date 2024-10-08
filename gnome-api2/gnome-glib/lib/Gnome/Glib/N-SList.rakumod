=comment Package: Glib, C-Source: slist
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-slist:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-SList:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Glib::SList' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GSList');
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
  alloc => %( :type(Function), :is-symbol<g_slist_alloc>,  :returns(N-Object)),
  append => %( :type(Function), :is-symbol<g_slist_append>,  :returns(N-Object), :parameters([ N-Object, gpointer])),
  concat => %( :type(Function), :is-symbol<g_slist_concat>,  :returns(N-Object), :parameters([ N-Object, N-Object])),
  copy => %( :type(Function), :is-symbol<g_slist_copy>,  :returns(N-Object), :parameters([N-Object])),
  copy-deep => %( :type(Function), :is-symbol<g_slist_copy_deep>,  :returns(N-Object), :parameters([ N-Object, :( gpointer $src, gpointer $data --> gpointer ), gpointer])),
  delete-link => %( :type(Function), :is-symbol<g_slist_delete_link>,  :returns(N-Object), :parameters([ N-Object, N-Object])),
  find => %( :type(Function), :is-symbol<g_slist_find>,  :returns(N-Object), :parameters([ N-Object, gpointer])),
  find-custom => %( :type(Function), :is-symbol<g_slist_find_custom>,  :returns(N-Object), :parameters([ N-Object, gpointer, :( gpointer $a, gpointer $b --> gint )])),
  foreach => %( :type(Function), :is-symbol<g_slist_foreach>,  :parameters([ N-Object, :( gpointer $data, gpointer $user-data ), gpointer])),
  free => %( :type(Function), :is-symbol<g_slist_free>,  :parameters([N-Object])),
  free-full => %( :type(Function), :is-symbol<g_slist_free_full>,  :parameters([ N-Object, :( gpointer $data )])),
  free1 => %( :type(Function), :is-symbol<g_slist_free1>,  :parameters([N-Object])),
  index => %( :type(Function), :is-symbol<g_slist_index>,  :returns(gint), :parameters([ N-Object, gpointer])),
  insert => %( :type(Function), :is-symbol<g_slist_insert>,  :returns(N-Object), :parameters([ N-Object, gpointer, gint])),
  insert-before => %( :type(Function), :is-symbol<g_slist_insert_before>,  :returns(N-Object), :parameters([ N-Object, N-Object, gpointer])),
  insert-sorted => %( :type(Function), :is-symbol<g_slist_insert_sorted>,  :returns(N-Object), :parameters([ N-Object, gpointer, :( gpointer $a, gpointer $b --> gint )])),
  insert-sorted-with-data => %( :type(Function), :is-symbol<g_slist_insert_sorted_with_data>,  :returns(N-Object), :parameters([ N-Object, gpointer, :( gpointer $a, gpointer $b, gpointer $user-data --> gint ), gpointer])),
  last => %( :type(Function), :is-symbol<g_slist_last>,  :returns(N-Object), :parameters([N-Object])),
  length => %( :type(Function), :is-symbol<g_slist_length>,  :returns(guint), :parameters([N-Object])),
  nth => %( :type(Function), :is-symbol<g_slist_nth>,  :returns(N-Object), :parameters([ N-Object, guint])),
  nth-data => %( :type(Function), :is-symbol<g_slist_nth_data>,  :returns(gpointer), :parameters([ N-Object, guint])),
  position => %( :type(Function), :is-symbol<g_slist_position>,  :returns(gint), :parameters([ N-Object, N-Object])),
  prepend => %( :type(Function), :is-symbol<g_slist_prepend>,  :returns(N-Object), :parameters([ N-Object, gpointer])),
  remove => %( :type(Function), :is-symbol<g_slist_remove>,  :returns(N-Object), :parameters([ N-Object, gpointer])),
  remove-all => %( :type(Function), :is-symbol<g_slist_remove_all>,  :returns(N-Object), :parameters([ N-Object, gpointer])),
  remove-link => %( :type(Function), :is-symbol<g_slist_remove_link>,  :returns(N-Object), :parameters([ N-Object, N-Object])),
  reverse => %( :type(Function), :is-symbol<g_slist_reverse>,  :returns(N-Object), :parameters([N-Object])),
  sort => %( :type(Function), :is-symbol<g_slist_sort>,  :returns(N-Object), :parameters([ N-Object, :( gpointer $a, gpointer $b --> gint )])),
  sort-with-data => %( :type(Function), :is-symbol<g_slist_sort_with_data>,  :returns(N-Object), :parameters([ N-Object, :( gpointer $a, gpointer $b, gpointer $user-data --> gint ), gpointer])),
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
