# Command to generate: generate.raku -c Glib main
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-MainContext:api<2>;
use Gnome::Glib::N-MainLoop:api<2>;
#use Gnome::Glib::N-Source:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::T-MainContext:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GMainContextFlags is export (
  :G_MAIN_CONTEXT_FLAGS_NONE(0), :G_MAIN_CONTEXT_FLAGS_OWNERLESS_POLLING(1)
);

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant G_PRIORITY_DEFAULT is export = 0;
constant G_SOURCE_CONTINUE is export = true;
constant G_PRIORITY_HIGH_IDLE is export = 100;
constant G_PRIORITY_HIGH is export = -100;
constant G_PRIORITY_DEFAULT_IDLE is export = 200;
constant G_PRIORITY_LOW is export = 300;
constant G_SOURCE_REMOVE is export = false;



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
  $!routine-caller .= new( :library(glib-lib()), :sub-prefix("g_"));
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  #child-watch-add => %( :type(Function),  :returns(guint), :parameters([ , :( , gint, gpointer ), gpointer])),
  #child-watch-add-full => %( :type(Function),  :returns(guint), :parameters([ gint, , :( , gint, gpointer ), gpointer, :( gpointer )])),
  #child-watch-source-new => %( :type(Function),  :returns(N-Source )),
  clear-handle-id => %( :type(Function),  :parameters([ gint-ptr, :( guint )])),
  get-monotonic-time => %( :type(Function),  :returns(gint64)),
  get-real-time => %( :type(Function),  :returns(gint64)),
  idle-add => %( :type(Function),  :returns(guint), :parameters([ :( gpointer --> gboolean ), gpointer])),
  idle-add-full => %( :type(Function),  :returns(guint), :parameters([ gint, :( gpointer --> gboolean ), gpointer, :( gpointer )])),
  idle-remove-by-data => %( :type(Function),  :returns(gboolean), :parameters([gpointer])),
  #idle-source-new => %( :type(Function),  :returns(N-Source )),
  #main-current-source => %( :type(Function),  :returns(N-Source )),
  main-depth => %( :type(Function),  :returns(gint)),
  timeout-add => %( :type(Function),  :returns(guint), :parameters([ guint, :( gpointer --> gboolean ), gpointer])),
  timeout-add-full => %( :type(Function),  :returns(guint), :parameters([ gint, guint, :( gpointer --> gboolean ), gpointer, :( gpointer )])),
  timeout-add-seconds => %( :type(Function),  :returns(guint), :parameters([ guint, :( gpointer --> gboolean ), gpointer])),
  timeout-add-seconds-full => %( :type(Function),  :returns(guint), :parameters([ gint, guint, :( gpointer --> gboolean ), gpointer, :( gpointer )])),
  #timeout-source-new => %( :type(Function),  :returns(N-Source ), :parameters([guint])),
  #timeout-source-new-seconds => %( :type(Function),  :returns(N-Source ), :parameters([guint])),

);

# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
