# Command to generate: generate.raku -c Glib list
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-List:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
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
    #die X::Gnome.new(:message("Native object not defined"))
    #  unless self.is-valid;

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
  alloc => %( :type(Function),  :returns(N-List)),
  append => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer])),
  concat => %( :type(Function),  :returns(N-List), :parameters([ N-List, N-List])),
  copy => %( :type(Function),  :returns(N-List), :parameters([N-List])),
  copy-deep => %( :type(Function),  :returns(N-List), :parameters([ N-List, :( gpointer, gpointer --> gpointer ), gpointer])),
  delete-link => %( :type(Function),  :returns(N-List), :parameters([ N-List, N-List])),
  find => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer])),
  find-custom => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer, :( gpointer, gpointer --> gint )])),
  first => %( :type(Function),  :returns(N-List), :parameters([N-List])),
  foreach => %( :type(Function),  :parameters([ N-List, :( gpointer, gpointer ), gpointer])),
  free => %( :type(Function),  :parameters([N-List])),
  free-full => %( :type(Function),  :parameters([ N-List, :( gpointer )])),
  free-one => %( :type(Function),  :parameters([N-List])),
  index => %( :type(Function),  :returns(gint), :parameters([ N-List, gpointer])),
  insert => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer, gint])),
  insert-before => %( :type(Function),  :returns(N-List), :parameters([ N-List, N-List, gpointer])),
  insert-before-link => %( :type(Function),  :returns(N-List), :parameters([ N-List, N-List, N-List])),
  insert-sorted => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer, :( gpointer, gpointer --> gint )])),
  insert-sorted-with-data => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer, :( gpointer, gpointer, gpointer --> gint ), gpointer])),
  last => %( :type(Function),  :returns(N-List), :parameters([N-List])),
  length => %( :type(Function),  :returns(guint), :parameters([N-List])),
  nth => %( :type(Function),  :returns(N-List), :parameters([ N-List, guint])),
  nth-data => %( :type(Function),  :returns(gpointer), :parameters([ N-List, guint])),
  nth-prev => %( :type(Function),  :returns(N-List), :parameters([ N-List, guint])),
  position => %( :type(Function),  :returns(gint), :parameters([ N-List, N-List])),
  prepend => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer])),
  remove => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer])),
  remove-all => %( :type(Function),  :returns(N-List), :parameters([ N-List, gpointer])),
  remove-link => %( :type(Function),  :returns(N-List), :parameters([ N-List, N-List])),
  reverse => %( :type(Function),  :returns(N-List), :parameters([N-List])),
  sort => %( :type(Function),  :returns(N-List), :parameters([ N-List, :( gpointer, gpointer --> gint )])),
  sort-with-data => %( :type(Function),  :returns(N-List), :parameters([ N-List, :( gpointer, gpointer, gpointer --> gint ), gpointer])),
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
