=comment Package: Glib, C-Source: main
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::T-main:api<2>;
#use Gnome::Glib::T-poll:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::N-MainContext:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Glib::MainContext' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GMainContext');
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

  #--[Constructors]-------------------------------------------------------------
  new-maincontext => %( :type(Constructor), :is-symbol<g_main_context_new>, :returns(N-Object), ),
  new-with-flags => %( :type(Constructor), :is-symbol<g_main_context_new_with_flags>, :returns(N-Object), :parameters([ GFlag])),

  #--[Methods]------------------------------------------------------------------
  acquire => %(:is-symbol<g_main_context_acquire>,  :returns(gboolean), :cnv-return(Bool)),
  add-poll => %(:is-symbol<g_main_context_add_poll>,  :parameters([N-Object, gint])),
  check => %(:is-symbol<g_main_context_check>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint, N-Object, gint])),
  dispatch => %(:is-symbol<g_main_context_dispatch>, ),
  find-source-by-funcs-user-data => %(:is-symbol<g_main_context_find_source_by_funcs_user_data>,  :returns(N-Object), :parameters([N-Object, gpointer])),
  find-source-by-id => %(:is-symbol<g_main_context_find_source_by_id>,  :returns(N-Object), :parameters([guint])),
  find-source-by-user-data => %(:is-symbol<g_main_context_find_source_by_user_data>,  :returns(N-Object), :parameters([gpointer])),
#  get-poll-func => %(:is-symbol<g_main_context_get_poll_func>,  :returns(), :cnv-return(( N-Object $ufds, guint $nfsd, gint $timeout --> gint ))),
  invoke => %(:is-symbol<g_main_context_invoke>,  :parameters([:( gpointer $user-data --> gboolean ), gpointer])),
  invoke-full => %(:is-symbol<g_main_context_invoke_full>,  :parameters([gint, :( gpointer $user-data --> gboolean ), gpointer, :( gpointer $data )])),
  is-owner => %(:is-symbol<g_main_context_is_owner>,  :returns(gboolean), :cnv-return(Bool)),
  iteration => %(:is-symbol<g_main_context_iteration>,  :returns(gboolean), :cnv-return(Bool), :parameters([gboolean])),
  pending => %(:is-symbol<g_main_context_pending>,  :returns(gboolean), :cnv-return(Bool)),
  pop-thread-default => %(:is-symbol<g_main_context_pop_thread_default>, ),
  prepare => %(:is-symbol<g_main_context_prepare>,  :returns(gboolean), :cnv-return(Bool), :parameters([gint-ptr])),
  push-thread-default => %(:is-symbol<g_main_context_push_thread_default>, ),
  query => %(:is-symbol<g_main_context_query>,  :returns(gint), :parameters([gint, gint-ptr, N-Object, gint])),
  ref => %(:is-symbol<g_main_context_ref>,  :returns(N-Object)),
  release => %(:is-symbol<g_main_context_release>, ),
  remove-poll => %(:is-symbol<g_main_context_remove_poll>,  :parameters([N-Object])),
  set-poll-func => %(:is-symbol<g_main_context_set_poll_func>,  :parameters([:( N-Object $ufds, guint $nfsd, gint $timeout --> gint )])),
  unref => %(:is-symbol<g_main_context_unref>, ),
  wakeup => %(:is-symbol<g_main_context_wakeup>, ),

  #--[Functions]----------------------------------------------------------------
  default => %( :type(Function), :is-symbol<g_main_context_default>,  :returns(N-Object)),
  get-thread-default => %( :type(Function), :is-symbol<g_main_context_get_thread_default>,  :returns(N-Object)),
  ref-thread-default => %( :type(Function), :is-symbol<g_main_context_ref_thread_default>,  :returns(N-Object)),
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
