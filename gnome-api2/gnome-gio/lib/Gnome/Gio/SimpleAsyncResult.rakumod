=comment Package: Gio, C-Source: simpleasyncresult
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::SimpleAsyncResult:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gio::SimpleAsyncResult' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GSimpleAsyncResult');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-simpleasyncresult => %( :type(Constructor), :is-symbol<g_simple_async_result_new>, :returns(N-Object), :deprecated, :deprecated-version<2.46>, :parameters([ N-Object, :(N-Object, N-Object, gpointer), gpointer, gpointer])),
  new-error => %( :type(Constructor), :is-symbol<g_simple_async_result_new_error>, :returns(N-Object), :deprecated, :deprecated-version<2.46>, :variable-list, :parameters([ N-Object, :(N-Object, N-Object, gpointer), gpointer, GQuark, gint, Str])),
  new-from-error => %( :type(Constructor), :is-symbol<g_simple_async_result_new_from_error>, :returns(N-Object), :deprecated, :deprecated-version<2.46>, :parameters([ N-Object, :(N-Object, N-Object, gpointer), gpointer, N-Object])),
  new-take-error => %( :type(Constructor), :is-symbol<g_simple_async_result_new_take_error>, :returns(N-Object), :deprecated, :deprecated-version<2.46>, :parameters([ N-Object, :(N-Object, N-Object, gpointer), gpointer, N-Object])),

  #--[Methods]------------------------------------------------------------------
  complete => %(:is-symbol<g_simple_async_result_complete>, :deprecated, :deprecated-version<2.46>, ),
  complete-in-idle => %(:is-symbol<g_simple_async_result_complete_in_idle>, :deprecated, :deprecated-version<2.46>, ),
  get-op-res-gboolean => %(:is-symbol<g_simple_async_result_get_op_res_gboolean>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<2.46>, ),
  get-op-res-gpointer => %(:is-symbol<g_simple_async_result_get_op_res_gpointer>,  :returns(gpointer),:deprecated, :deprecated-version<2.46>, ),
  get-op-res-gssize => %(:is-symbol<g_simple_async_result_get_op_res_gssize>,  :returns(gssize),:deprecated, :deprecated-version<2.46>, ),
  get-source-tag => %(:is-symbol<g_simple_async_result_get_source_tag>,  :returns(gpointer),:deprecated, :deprecated-version<2.46.>, ),
  propagate-error => %(:is-symbol<g_simple_async_result_propagate_error>,  :returns(gboolean), :cnv-return(Bool), :parameters([CArray[N-Error]]),:deprecated, :deprecated-version<2.46>, ),
  run-in-thread => %(:is-symbol<g_simple_async_result_run_in_thread>,  :parameters([:( N-Object $res, N-Object $object, N-Object $cancellable ), gint, N-Object]),:deprecated, :deprecated-version<2.46>, ),
  set-check-cancellable => %(:is-symbol<g_simple_async_result_set_check_cancellable>,  :parameters([N-Object]),:deprecated, :deprecated-version<2.46>, ),
  set-error => %(:is-symbol<g_simple_async_result_set_error>, :variable-list,  :parameters([GQuark, gint, Str]),:deprecated, :deprecated-version<2.46>, ),
  #set-error-va => %(:is-symbol<g_simple_async_result_set_error_va>,  :parameters([GQuark, gint, Str, ]),:deprecated, :deprecated-version<2.46>, ),
  set-from-error => %(:is-symbol<g_simple_async_result_set_from_error>,  :parameters([N-Object]),:deprecated, :deprecated-version<2.46>, ),
  set-handle-cancellation => %(:is-symbol<g_simple_async_result_set_handle_cancellation>,  :parameters([gboolean]),:deprecated, :deprecated-version<2.46>, ),
  set-op-res-gboolean => %(:is-symbol<g_simple_async_result_set_op_res_gboolean>,  :parameters([gboolean]),:deprecated, :deprecated-version<2.46>, ),
  #set-op-res-gpointer => %(:is-symbol<g_simple_async_result_set_op_res_gpointer>,  :parameters([gpointer, ]),:deprecated, :deprecated-version<2.46>, ),
  set-op-res-gssize => %(:is-symbol<g_simple_async_result_set_op_res_gssize>,  :parameters([gssize]),:deprecated, :deprecated-version<2.46>, ),
  take-error => %(:is-symbol<g_simple_async_result_take_error>,  :parameters([N-Object]),:deprecated, :deprecated-version<2.46>, ),

  #--[Functions]----------------------------------------------------------------
  is-valid => %( :type(Function), :is-symbol<g_simple_async_result_is_valid>,  :returns(gboolean), :parameters([ N-Object, N-Object, gpointer]),:deprecated, :deprecated-version<2.46>, ),
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
