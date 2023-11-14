# Command to generate: generate.raku -v -c Glib list
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-List:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::List:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_list_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::List' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GList');
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
  alloc => %( :type(Function), :is-symbol<g_list_alloc>,  :returns(N-List)),
  append => %( :type(Function), :is-symbol<g_list_append>,  :returns(N-List), :parameters([ N-List, gpointer])),
  concat => %( :type(Function), :is-symbol<g_list_concat>,  :returns(N-List), :parameters([ N-List, N-List])),
  copy => %( :type(Function), :is-symbol<g_list_copy>,  :returns(N-List), :parameters([N-List])),
  copy-deep => %( :type(Function), :is-symbol<g_list_copy_deep>,  :returns(N-List), :parameters([ N-List, :( gpointer $src, gpointer $data --> gpointer ), gpointer])),
  delete-link => %( :type(Function), :is-symbol<g_list_delete_link>,  :returns(N-List), :parameters([ N-List, N-List])),
  find => %( :type(Function), :is-symbol<g_list_find>,  :returns(N-List), :parameters([ N-List, gpointer])),
  find-custom => %( :type(Function), :is-symbol<g_list_find_custom>,  :returns(N-List), :parameters([ N-List, gpointer, :( gpointer $a, gpointer $b --> gint )])),
  first => %( :type(Function), :is-symbol<g_list_first>,  :returns(N-List), :parameters([N-List])),
  foreach => %( :type(Function), :is-symbol<g_list_foreach>,  :parameters([ N-List, :( gpointer $data, gpointer $user-data ), gpointer])),
  free => %( :type(Function), :is-symbol<g_list_free>,  :parameters([N-List])),
  free-full => %( :type(Function), :is-symbol<g_list_free_full>,  :parameters([ N-List, :( gpointer $data )])),
  free-one => %( :type(Function), :is-symbol<g_list_free_one>,  :parameters([N-List])),
  index => %( :type(Function), :is-symbol<g_list_index>,  :returns(gint), :parameters([ N-List, gpointer])),
  insert => %( :type(Function), :is-symbol<g_list_insert>,  :returns(N-List), :parameters([ N-List, gpointer, gint])),
  insert-before => %( :type(Function), :is-symbol<g_list_insert_before>,  :returns(N-List), :parameters([ N-List, N-List, gpointer])),
  insert-before-link => %( :type(Function), :is-symbol<g_list_insert_before_link>,  :returns(N-List), :parameters([ N-List, N-List, N-List])),
  insert-sorted => %( :type(Function), :is-symbol<g_list_insert_sorted>,  :returns(N-List), :parameters([ N-List, gpointer, :( gpointer $a, gpointer $b --> gint )])),
  insert-sorted-with-data => %( :type(Function), :is-symbol<g_list_insert_sorted_with_data>,  :returns(N-List), :parameters([ N-List, gpointer, :( gpointer $a, gpointer $b, gpointer $user-data --> gint ), gpointer])),
  last => %( :type(Function), :is-symbol<g_list_last>,  :returns(N-List), :parameters([N-List])),
  length => %( :type(Function), :is-symbol<g_list_length>,  :returns(guint), :parameters([N-List])),
  nth => %( :type(Function), :is-symbol<g_list_nth>,  :returns(N-List), :parameters([ N-List, guint])),
  nth-data => %( :type(Function), :is-symbol<g_list_nth_data>,  :returns(gpointer), :parameters([ N-List, guint])),
  nth-prev => %( :type(Function), :is-symbol<g_list_nth_prev>,  :returns(N-List), :parameters([ N-List, guint])),
  position => %( :type(Function), :is-symbol<g_list_position>,  :returns(gint), :parameters([ N-List, N-List])),
  prepend => %( :type(Function), :is-symbol<g_list_prepend>,  :returns(N-List), :parameters([ N-List, gpointer])),
  remove => %( :type(Function), :is-symbol<g_list_remove>,  :returns(N-List), :parameters([ N-List, gpointer])),
  remove-all => %( :type(Function), :is-symbol<g_list_remove_all>,  :returns(N-List), :parameters([ N-List, gpointer])),
  remove-link => %( :type(Function), :is-symbol<g_list_remove_link>,  :returns(N-List), :parameters([ N-List, N-List])),
  reverse => %( :type(Function), :is-symbol<g_list_reverse>,  :returns(N-List), :parameters([N-List])),
  sort => %( :type(Function), :is-symbol<g_list_sort>,  :returns(N-List), :parameters([ N-List, :( gpointer $a, gpointer $b --> gint )])),
  sort-with-data => %( :type(Function), :is-symbol<g_list_sort_with_data>,  :returns(N-List), :parameters([ N-List, :( gpointer $a, gpointer $b, gpointer $user-data --> gint ), gpointer])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(glib-lib()), :sub-prefix<g_list_>
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
