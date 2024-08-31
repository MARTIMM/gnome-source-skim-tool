=comment Package: Gio, C-Source: simpleasyncresult
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::T-simpleasyncresult:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gio-lib()));
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  simple-async-report-error-in-idle => %( :type(Function), :is-symbol<g_simple_async_report_error_in_idle>, :variable-list,  :parameters([ N-Object, :( N-Object $source-object, N-Object $res, gpointer $data ), gpointer, GQuark, gint, Str]),:deprecated, :deprecated-version<2.46>, ),
  simple-async-report-gerror-in-idle => %( :type(Function), :is-symbol<g_simple_async_report_gerror_in_idle>,  :parameters([ N-Object, :( N-Object $source-object, N-Object $res, gpointer $data ), gpointer, N-Object]),:deprecated, :deprecated-version<2.46>, ),
  simple-async-report-take-gerror-in-idle => %( :type(Function), :is-symbol<g_simple_async_report_take_gerror_in_idle>,  :parameters([ N-Object, :( N-Object $source-object, N-Object $res, gpointer $data ), gpointer, N-Object]),:deprecated, :deprecated-version<2.46>, ),

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
