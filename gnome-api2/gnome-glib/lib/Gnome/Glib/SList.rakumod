# Command to generate: generate.raku -t -c Glib slist
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-GSList:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::SList:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_slist_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Glib::SList' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    #die X::Gnome.new(:message("Native object not defined"))
    #  unless self.is-valid;

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
  alloc => %( :type(Function),  :returns(N-GSList)),
  append => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer])),
  concat => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, N-GSList])),
  copy => %( :type(Function),  :returns(N-GSList), :parameters([N-GSList])),
  #copy-deep => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, Callable $handler ( gpointer, gpointer --> gpointer ) , gpointer])),
  delete-link => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, N-GSList])),
  find => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer])),
  #find-custom => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer, Callable $handler ( gpointer, gpointer --> gint ) ])),
  #foreach => %( :type(Function),  :parameters([ N-GSList, Callable $handler ( gpointer, gpointer ) , gpointer])),
  free => %( :type(Function),  :parameters([N-GSList])),
  free-one => %( :type(Function),  :parameters([N-GSList])),
  #free-full => %( :type(Function),  :parameters([ N-GSList, Callable $handler ( gpointer ) ])),
  index => %( :type(Function),  :returns(gint), :parameters([ N-GSList, gpointer])),
  insert => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer, gint])),
  insert-before => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, N-GSList, gpointer])),
  #insert-sorted => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer, Callable $handler ( gpointer, gpointer --> gint ) ])),
  #insert-sorted-with-data => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer, Callable $handler ( gpointer, gpointer, gpointer --> gint ) , gpointer])),
  last => %( :type(Function),  :returns(N-GSList), :parameters([N-GSList])),
  length => %( :type(Function),  :returns(guint), :parameters([N-GSList])),
  nth => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, guint])),
  nth-data => %( :type(Function),  :returns(gpointer), :parameters([ N-GSList, guint])),
  position => %( :type(Function),  :returns(gint), :parameters([ N-GSList, N-GSList])),
  prepend => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer])),
  remove => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer])),
  remove-all => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, gpointer])),
  remove-link => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, N-GSList])),
  reverse => %( :type(Function),  :returns(N-GSList), :parameters([N-GSList])),
  #sort => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, Callable $handler ( gpointer, gpointer --> gint ) ])),
  #sort-with-data => %( :type(Function),  :returns(N-GSList), :parameters([ N-GSList, Callable $handler ( gpointer, gpointer, gpointer --> gint ) , gpointer])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(glib-lib()), :sub-prefix<g_s_list_>
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
