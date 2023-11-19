# Command to generate: generate.raku -d -c -t Glib main
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::N-Source:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::T-Main:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library('libglib-2.0.so.0'));
}

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant G_SOURCE_CONTINUE is export = true;
constant G_PRIORITY_DEFAULT is export = 0;
constant G_SOURCE_REMOVE is export = false;
constant G_PRIORITY_DEFAULT_IDLE is export = 200;
constant G_PRIORITY_HIGH is export = -100;
constant G_PRIORITY_LOW is export = 300;
constant G_PRIORITY_HIGH_IDLE is export = 100;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GMainContextFlags is export (
  :G_MAIN_CONTEXT_FLAGS_NONE(0), :G_MAIN_CONTEXT_FLAGS_OWNERLESS_POLLING(1)
);

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  #child-watch-add => %( :type(Function), :is-symbol<g_child_watch_add>,  :returns(guint), :parameters([ , :(  $pid, gint $wait-status, gpointer $user-data ), gpointer])),
  #child-watch-add-full => %( :type(Function), :is-symbol<g_child_watch_add_full>,  :returns(guint), :parameters([ gint, , :(  $pid, gint $wait-status, gpointer $user-data ), gpointer, :( gpointer $data )])),
  #child-watch-source-new => %( :type(Function), :is-symbol<g_child_watch_source_new>,  :returns(N-Source )),
  clear-handle-id => %( :type(Function), :is-symbol<g_clear_handle_id>,  :parameters([ gint-ptr, :( guint $handle-id )])),
  get-monotonic-time => %( :type(Function), :is-symbol<g_get_monotonic_time>,  :returns(gint64)),
  get-real-time => %( :type(Function), :is-symbol<g_get_real_time>,  :returns(gint64)),
  idle-add => %( :type(Function), :is-symbol<g_idle_add>,  :returns(guint), :parameters([ :( gpointer $user-data --> gboolean ), gpointer])),
  idle-add-full => %( :type(Function), :is-symbol<g_idle_add_full>,  :returns(guint), :parameters([ gint, :( gpointer $user-data --> gboolean ), gpointer, :( gpointer $data )])),
  idle-remove-by-data => %( :type(Function), :is-symbol<g_idle_remove_by_data>,  :returns(gboolean), :parameters([gpointer])),
  #idle-source-new => %( :type(Function), :is-symbol<g_idle_source_new>,  :returns(N-Source )),
  #main-current-source => %( :type(Function), :is-symbol<g_main_current_source>,  :returns(N-Source )),
  main-depth => %( :type(Function), :is-symbol<g_main_depth>,  :returns(gint)),
  timeout-add => %( :type(Function), :is-symbol<g_timeout_add>,  :returns(guint), :parameters([ guint, :( gpointer $user-data --> gboolean ), gpointer])),
  timeout-add-full => %( :type(Function), :is-symbol<g_timeout_add_full>,  :returns(guint), :parameters([ gint, guint, :( gpointer $user-data --> gboolean ), gpointer, :( gpointer $data )])),
  timeout-add-seconds => %( :type(Function), :is-symbol<g_timeout_add_seconds>,  :returns(guint), :parameters([ guint, :( gpointer $user-data --> gboolean ), gpointer])),
  timeout-add-seconds-full => %( :type(Function), :is-symbol<g_timeout_add_seconds_full>,  :returns(guint), :parameters([ gint, guint, :( gpointer $user-data --> gboolean ), gpointer, :( gpointer $data )])),
  #timeout-source-new => %( :type(Function), :is-symbol<g_timeout_source_new>,  :returns(N-Source ), :parameters([guint])),
  #timeout-source-new-seconds => %( :type(Function), :is-symbol<g_timeout_source_new_seconds>,  :returns(N-Source ), :parameters([guint])),

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
