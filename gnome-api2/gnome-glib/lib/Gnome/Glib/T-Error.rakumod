# Command to generate: gnome-source-skim-tool.raku -c -v Glib error
use v6;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::Error:api<2>;
use Gnome::Glib::Error::N-GError:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;

use Gnome::N::TopLevelClassSupport:api<2>;

use Gnome::N::GnomeRoutineCaller:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::T-Error:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;


#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix<g_>);
}

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  clear-error => %( :type(Function), ),
  prefix-error => %( :type(Function), :variable-list,  :parameters([ CArray[N-GError], Str])),
  prefix-error-literal => %( :type(Function),  :parameters([ CArray[N-GError], Str])),
  propagate-error => %( :type(Function),  :parameters([ CArray[N-GError], N-GError])),
  propagate-prefixed-error => %( :type(Function), :variable-list,  :parameters([ CArray[N-GError], N-GError, Str])),
  set-error => %( :type(Function), :variable-list,  :parameters([ CArray[N-GError], GQuark, gint, Str])),
  set-error-literal => %( :type(Function),  :parameters([ CArray[N-GError], GQuark, gint, Str])),

);

# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    my $native-object = self.get-native-object-no-reffing;
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods, :$native-object
    );
  }

  else {
    callsame;
  }
}
