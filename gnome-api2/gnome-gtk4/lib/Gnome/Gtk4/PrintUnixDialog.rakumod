=comment Package: Gtk4, C-Source: printunixdialog
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::Dialog:api<2>;
#use Gnome::Gtk4::T-printer:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::PrintUnixDialog:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Dialog;

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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::PrintUnixDialog' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkPrintUnixDialog');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-printunixdialog => %( :type(Constructor), :is-symbol<gtk_print_unix_dialog_new>, :returns(N-Object), :parameters([ Str, N-Object])),

  #--[Methods]------------------------------------------------------------------
  add-custom-tab => %(:is-symbol<gtk_print_unix_dialog_add_custom_tab>,  :parameters([N-Object, N-Object])),
  get-current-page => %(:is-symbol<gtk_print_unix_dialog_get_current_page>,  :returns(gint)),
  get-embed-page-setup => %(:is-symbol<gtk_print_unix_dialog_get_embed_page_setup>,  :returns(gboolean), :cnv-return(Bool)),
  get-has-selection => %(:is-symbol<gtk_print_unix_dialog_get_has_selection>,  :returns(gboolean), :cnv-return(Bool)),
  #get-manual-capabilities => %(:is-symbol<gtk_print_unix_dialog_get_manual_capabilities>,  :returns(GFlag), :cnv-return(GtkPrintCapabilities )),
  get-page-setup => %(:is-symbol<gtk_print_unix_dialog_get_page_setup>,  :returns(N-Object)),
  get-page-setup-set => %(:is-symbol<gtk_print_unix_dialog_get_page_setup_set>,  :returns(gboolean), :cnv-return(Bool)),
  get-selected-printer => %(:is-symbol<gtk_print_unix_dialog_get_selected_printer>,  :returns(N-Object)),
  get-settings => %(:is-symbol<gtk_print_unix_dialog_get_settings>,  :returns(N-Object)),
  get-support-selection => %(:is-symbol<gtk_print_unix_dialog_get_support_selection>,  :returns(gboolean), :cnv-return(Bool)),
  set-current-page => %(:is-symbol<gtk_print_unix_dialog_set_current_page>,  :parameters([gint])),
  set-embed-page-setup => %(:is-symbol<gtk_print_unix_dialog_set_embed_page_setup>,  :parameters([gboolean])),
  set-has-selection => %(:is-symbol<gtk_print_unix_dialog_set_has_selection>,  :parameters([gboolean])),
  #set-manual-capabilities => %(:is-symbol<gtk_print_unix_dialog_set_manual_capabilities>,  :parameters([GFlag])),
  set-page-setup => %(:is-symbol<gtk_print_unix_dialog_set_page_setup>,  :parameters([N-Object])),
  set-settings => %(:is-symbol<gtk_print_unix_dialog_set_settings>,  :parameters([N-Object])),
  set-support-selection => %(:is-symbol<gtk_print_unix_dialog_set_support_selection>,  :parameters([gboolean])),
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
        :library(gtk4-lib())
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
