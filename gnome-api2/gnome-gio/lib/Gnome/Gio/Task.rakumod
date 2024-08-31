=comment Package: Gio, C-Source: task
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::Object:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::N-MainContext:api<2>;
#use Gnome::Glib::N-Source:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::Glib::T-main:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::Task:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::Task' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GTask');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-task => %( :type(Constructor), :is-symbol<g_task_new>, :returns(N-Object), :parameters([ gpointer, N-Object, :(N-Object, N-Object, gpointer), gpointer])),

  #--[Methods]------------------------------------------------------------------
  #attach-source => %(:is-symbol<g_task_attach_source>,  :parameters([N-Object, ])),
  get-cancellable => %(:is-symbol<g_task_get_cancellable>,  :returns(N-Object)),
  get-check-cancellable => %(:is-symbol<g_task_get_check_cancellable>,  :returns(gboolean), :cnv-return(Bool)),
  get-completed => %(:is-symbol<g_task_get_completed>,  :returns(gboolean), :cnv-return(Bool)),
  get-context => %(:is-symbol<g_task_get_context>,  :returns(N-Object)),
  get-name => %(:is-symbol<g_task_get_name>,  :returns(Str)),
  get-priority => %(:is-symbol<g_task_get_priority>,  :returns(gint)),
  get-return-on-cancel => %(:is-symbol<g_task_get_return_on_cancel>,  :returns(gboolean), :cnv-return(Bool)),
  get-source-object => %(:is-symbol<g_task_get_source_object>,  :returns(gpointer)),
  get-source-tag => %(:is-symbol<g_task_get_source_tag>,  :returns(gpointer)),
  get-task-data => %(:is-symbol<g_task_get_task_data>,  :returns(gpointer)),
  had-error => %(:is-symbol<g_task_had_error>,  :returns(gboolean), :cnv-return(Bool)),
  propagate-boolean => %(:is-symbol<g_task_propagate_boolean>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[N-Error]])),
  propagate-int => %(:is-symbol<g_task_propagate_int>,  :returns(gssize), :parameters([CArray[N-Error]])),
  propagate-pointer => %(:is-symbol<g_task_propagate_pointer>,  :returns(gpointer), :parameters([CArray[N-Error]])),
  propagate-value => %(:is-symbol<g_task_propagate_value>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  return-boolean => %(:is-symbol<g_task_return_boolean>,  :parameters([gboolean])),
  return-error => %(:is-symbol<g_task_return_error>,  :parameters([N-Object])),
  return-error-if-cancelled => %(:is-symbol<g_task_return_error_if_cancelled>,  :returns(gboolean), :cnv-return(Bool)),
  return-int => %(:is-symbol<g_task_return_int>,  :parameters([gssize])),
  return-new-error => %(:is-symbol<g_task_return_new_error>, :variable-list,  :parameters([GQuark, gint, Str])),
  return-new-error-literal => %(:is-symbol<g_task_return_new_error_literal>,  :parameters([GQuark, gint, Str])),
  #return-pointer => %(:is-symbol<g_task_return_pointer>,  :parameters([gpointer, ])),
  return-prefixed-error => %(:is-symbol<g_task_return_prefixed_error>, :variable-list,  :parameters([N-Object, Str])),
  return-value => %(:is-symbol<g_task_return_value>,  :parameters([N-Object])),
  run-in-thread => %(:is-symbol<g_task_run_in_thread>,  :parameters([:( N-Object $task, gpointer $source-object, gpointer $task-data, N-Object $cancellable )])),
  run-in-thread-sync => %(:is-symbol<g_task_run_in_thread_sync>,  :parameters([:( N-Object $task, gpointer $source-object, gpointer $task-data, N-Object $cancellable )])),
  set-check-cancellable => %(:is-symbol<g_task_set_check_cancellable>,  :parameters([gboolean])),
  set-name => %(:is-symbol<g_task_set_name>,  :parameters([Str])),
  set-priority => %(:is-symbol<g_task_set_priority>,  :parameters([gint])),
  set-return-on-cancel => %(:is-symbol<g_task_set_return_on_cancel>,  :returns(gboolean), :cnv-return(Bool), :parameters([gboolean])),
  set-source-tag => %(:is-symbol<g_task_set_source_tag>,  :parameters([gpointer])),
  set-static-name => %(:is-symbol<g_task_set_static_name>,  :parameters([Str])),
  #set-task-data => %(:is-symbol<g_task_set_task_data>,  :parameters([gpointer, ])),

  #--[Functions]----------------------------------------------------------------
  is-valid => %( :type(Function), :is-symbol<g_task_is_valid>,  :returns(gboolean), :parameters([ gpointer, gpointer])),
  report-error => %( :type(Function), :is-symbol<g_task_report_error>,  :parameters([ gpointer, :( N-Object $source-object, N-Object $res, gpointer $data ), gpointer, gpointer, N-Object])),
  report-new-error => %( :type(Function), :is-symbol<g_task_report_new_error>, :variable-list,  :parameters([ gpointer, :( N-Object $source-object, N-Object $res, gpointer $data ), gpointer, gpointer, GQuark, gint, Str])),
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
        :library(gio-lib())
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
