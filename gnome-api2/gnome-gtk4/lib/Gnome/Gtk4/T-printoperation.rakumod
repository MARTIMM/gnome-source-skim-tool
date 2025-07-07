=comment Package: Gtk4, C-Source: printoperation
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-printoperation:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));
}

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkPrintError is export <
  GTK_PRINT_ERROR_GENERAL GTK_PRINT_ERROR_INTERNAL_ERROR GTK_PRINT_ERROR_NOMEM GTK_PRINT_ERROR_INVALID_FILE 
>;

enum GtkPrintOperationAction is export <
  GTK_PRINT_OPERATION_ACTION_PRINT_DIALOG GTK_PRINT_OPERATION_ACTION_PRINT GTK_PRINT_OPERATION_ACTION_PREVIEW GTK_PRINT_OPERATION_ACTION_EXPORT 
>;

enum GtkPrintOperationResult is export <
  GTK_PRINT_OPERATION_RESULT_ERROR GTK_PRINT_OPERATION_RESULT_APPLY GTK_PRINT_OPERATION_RESULT_CANCEL GTK_PRINT_OPERATION_RESULT_IN_PROGRESS 
>;

enum GtkPrintStatus is export <
  GTK_PRINT_STATUS_INITIAL GTK_PRINT_STATUS_PREPARING GTK_PRINT_STATUS_GENERATING_DATA GTK_PRINT_STATUS_SENDING_DATA GTK_PRINT_STATUS_PENDING GTK_PRINT_STATUS_PENDING_ISSUE GTK_PRINT_STATUS_PRINTING GTK_PRINT_STATUS_FINISHED GTK_PRINT_STATUS_FINISHED_ABORTED 
>;

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  print-error-quark => %( :type(Function), :is-symbol<gtk_print_error_quark>, :returns(GQuark), ),
  print-run-page-setup-dialog => %( :type(Function), :is-symbol<gtk_print_run_page_setup_dialog>, :returns(N-Object), :parameters([ N-Object, N-Object, N-Object]), ),
  print-run-page-setup-dialog-async => %( :type(Function), :is-symbol<gtk_print_run_page_setup_dialog_async>, :parameters([ N-Object, N-Object, N-Object, :( N-Object $page-setup, gpointer $data ), gpointer]), ),

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
