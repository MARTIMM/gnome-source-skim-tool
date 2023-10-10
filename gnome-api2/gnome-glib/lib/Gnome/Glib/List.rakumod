# Command to generate: generate.raku -c Glib list record
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-GList:api<2>;
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
    
    # may be undefined in list
    #die X::Gnome.new(:message("Native object not defined"))
    #  unless self.is-valid;
    #self._set-native-object(N-GObject.new);

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
  alloc => %( :type(Function),  :returns(N-GList)),
  append => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer])),
  concat => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, N-GList])),
  copy => %( :type(Function),  :returns(N-GList), :parameters([N-GList])),
  #copy-deep => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, , gpointer])),
  delete-link => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, N-GList])),
  find => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer])),
  #find-custom => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer, ])),
  first => %( :type(Function),  :returns(N-GList), :parameters([N-GList])),
  #foreach => %( :type(Function),  :parameters([ N-GList, , gpointer])),
  free => %( :type(Function),  :parameters([N-GList])),
#  free-1 => %( :type(Function),  :parameters([N-GList])),
  #free-full => %( :type(Function),  :parameters([ N-GList, ])),
  index => %( :type(Function),  :returns(gint), :parameters([ N-GList, gpointer])),
  insert => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer, gint])),
  insert-before => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, N-GList, gpointer])),
  insert-before-link => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, N-GList, N-GList])),
  #insert-sorted => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer, ])),
  #insert-sorted-with-data => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer, , gpointer])),
  last => %( :type(Function),  :returns(N-GList), :parameters([N-GList])),
  length => %( :type(Function),  :returns(guint), :parameters([N-GList])),
  nth => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, guint])),
  nth-data => %( :type(Function),  :returns(gpointer), :parameters([ N-GList, guint])),
  nth-prev => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, guint])),
  position => %( :type(Function),  :returns(gint), :parameters([ N-GList, N-GList])),
  prepend => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer])),
  remove => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer])),
  remove-all => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, gpointer])),
  remove-link => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, N-GList])),
  reverse => %( :type(Function),  :returns(N-GList), :parameters([N-GList])),
  #sort => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, ])),
  #sort-with-data => %( :type(Function),  :returns(N-GList), :parameters([ N-GList, , gpointer])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
#note "$?LINE $name, $methods{$name}.gist()";
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
