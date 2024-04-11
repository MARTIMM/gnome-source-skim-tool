=comment Package: Gtk4, C-Source: printoperation
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Gtk4::R-PrintOperationPreview:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::T-PrintOperation:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::PrintOperation:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gtk4::R-PrintOperationPreview;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

# Add signal registration helper
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {
  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<create-custom-widget status-changed>,
      :w1<begin-print custom-widget-apply done end-print paginate>,
      :w2<draw-page>,
      :w3<preview request-page-setup update-custom-widget>,
    );

    # Signals from interfaces
    self._add_gtk_print_operation_preview_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_print_operation_preview_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::PrintOperation' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkPrintOperation');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-printoperation => %( :type(Constructor), :is-symbol<gtk_print_operation_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  cancel => %(:is-symbol<gtk_print_operation_cancel>, ),
  draw-page-finish => %(:is-symbol<gtk_print_operation_draw_page_finish>, ),
  get-default-page-setup => %(:is-symbol<gtk_print_operation_get_default_page_setup>,  :returns(N-Object)),
  get-embed-page-setup => %(:is-symbol<gtk_print_operation_get_embed_page_setup>,  :returns(gboolean), :cnv-return(Bool)),
  get-error => %(:is-symbol<gtk_print_operation_get_error>,  :parameters([CArray[N-Error]])),
  get-has-selection => %(:is-symbol<gtk_print_operation_get_has_selection>,  :returns(gboolean), :cnv-return(Bool)),
  get-n-pages-to-print => %(:is-symbol<gtk_print_operation_get_n_pages_to_print>,  :returns(gint)),
  get-print-settings => %(:is-symbol<gtk_print_operation_get_print_settings>,  :returns(N-Object)),
  get-status => %(:is-symbol<gtk_print_operation_get_status>,  :returns(GEnum), :cnv-return(GtkPrintStatus)),
  get-status-string => %(:is-symbol<gtk_print_operation_get_status_string>,  :returns(Str)),
  get-support-selection => %(:is-symbol<gtk_print_operation_get_support_selection>,  :returns(gboolean), :cnv-return(Bool)),
  is-finished => %(:is-symbol<gtk_print_operation_is_finished>,  :returns(gboolean), :cnv-return(Bool)),
  run => %(:is-symbol<gtk_print_operation_run>,  :returns(GEnum), :cnv-return(GtkPrintOperationResult), :parameters([GEnum, N-Object, CArray[N-Error]])),
  set-allow-async => %(:is-symbol<gtk_print_operation_set_allow_async>,  :parameters([gboolean])),
  set-current-page => %(:is-symbol<gtk_print_operation_set_current_page>,  :parameters([gint])),
  set-custom-tab-label => %(:is-symbol<gtk_print_operation_set_custom_tab_label>,  :parameters([Str])),
  set-default-page-setup => %(:is-symbol<gtk_print_operation_set_default_page_setup>,  :parameters([N-Object])),
  set-defer-drawing => %(:is-symbol<gtk_print_operation_set_defer_drawing>, ),
  set-embed-page-setup => %(:is-symbol<gtk_print_operation_set_embed_page_setup>,  :parameters([gboolean])),
  set-export-filename => %(:is-symbol<gtk_print_operation_set_export_filename>,  :parameters([Str])),
  set-has-selection => %(:is-symbol<gtk_print_operation_set_has_selection>,  :parameters([gboolean])),
  set-job-name => %(:is-symbol<gtk_print_operation_set_job_name>,  :parameters([Str])),
  set-n-pages => %(:is-symbol<gtk_print_operation_set_n_pages>,  :parameters([gint])),
  set-print-settings => %(:is-symbol<gtk_print_operation_set_print_settings>,  :parameters([N-Object])),
  set-show-progress => %(:is-symbol<gtk_print_operation_set_show_progress>,  :parameters([gboolean])),
  set-support-selection => %(:is-symbol<gtk_print_operation_set_support_selection>,  :parameters([gboolean])),
  set-track-print-status => %(:is-symbol<gtk_print_operation_set_track_print_status>,  :parameters([gboolean])),
  set-unit => %(:is-symbol<gtk_print_operation_set_unit>,  :parameters([GEnum])),
  set-use-full-page => %(:is-symbol<gtk_print_operation_set_use_full_page>,  :parameters([gboolean])),
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
    $r = self._do_gtk_print_operation_preview_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_print_operation_preview_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
