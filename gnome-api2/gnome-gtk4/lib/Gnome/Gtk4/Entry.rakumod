=comment Package: Gtk4, C-Source: entry
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gdk4::N-Rectangle:api<2>;
use Gnome::Gdk4::T-Enums:api<2>;
use Gnome::Gtk4::R-CellEditable:api<2>;
use Gnome::Gtk4::R-Editable:api<2>;
use Gnome::Gtk4::T-Entry:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::T-Image:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-AttrList:api<2>;
use Gnome::Pango::N-TabArray:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Entry:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-CellEditable;
also does Gnome::Gtk4::R-Editable;

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
      :w0<activate>,
      :w1<icon-release icon-press>,
    );

    # Signals from interfaces
    self._add_gtk_cell_editable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_editable_signal_types');
    self._add_gtk_editable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_editable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Entry' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkEntry');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-entry => %( :type(Constructor), :is-symbol<gtk_entry_new>, :returns(N-Object), ),
  new-with-buffer => %( :type(Constructor), :is-symbol<gtk_entry_new_with_buffer>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  get-activates-default => %(:is-symbol<gtk_entry_get_activates_default>,  :returns(gboolean), :cnv-return(Bool)),
  get-alignment => %(:is-symbol<gtk_entry_get_alignment>,  :returns(gfloat)),
  #get-attributes => %(:is-symbol<gtk_entry_get_attributes>,  :returns(N-AttrList )),
  get-buffer => %(:is-symbol<gtk_entry_get_buffer>,  :returns(N-Object)),
  get-completion => %(:is-symbol<gtk_entry_get_completion>,  :returns(N-Object)),
  get-current-icon-drag-source => %(:is-symbol<gtk_entry_get_current_icon_drag_source>,  :returns(gint)),
  get-extra-menu => %(:is-symbol<gtk_entry_get_extra_menu>,  :returns(N-Object)),
  get-has-frame => %(:is-symbol<gtk_entry_get_has_frame>,  :returns(gboolean), :cnv-return(Bool)),
  get-icon-activatable => %(:is-symbol<gtk_entry_get_icon_activatable>,  :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  get-icon-area => %(:is-symbol<gtk_entry_get_icon_area>,  :parameters([GEnum, N-Rectangle])),
  get-icon-at-pos => %(:is-symbol<gtk_entry_get_icon_at_pos>,  :returns(gint), :parameters([gint, gint])),
  get-icon-gicon => %(:is-symbol<gtk_entry_get_icon_gicon>,  :returns(N-Object), :parameters([GEnum])),
  get-icon-name => %(:is-symbol<gtk_entry_get_icon_name>,  :returns(Str), :parameters([GEnum])),
  get-icon-paintable => %(:is-symbol<gtk_entry_get_icon_paintable>,  :returns(N-Object), :parameters([GEnum])),
  get-icon-sensitive => %(:is-symbol<gtk_entry_get_icon_sensitive>,  :returns(gboolean), :cnv-return(Bool), :parameters([GEnum])),
  get-icon-storage-type => %(:is-symbol<gtk_entry_get_icon_storage_type>,  :returns(GEnum), :cnv-return(GtkImageType), :parameters([GEnum])),
  get-icon-tooltip-markup => %(:is-symbol<gtk_entry_get_icon_tooltip_markup>,  :returns(Str), :parameters([GEnum])),
  get-icon-tooltip-text => %(:is-symbol<gtk_entry_get_icon_tooltip_text>,  :returns(Str), :parameters([GEnum])),
  get-input-hints => %(:is-symbol<gtk_entry_get_input_hints>,  :returns(GFlag), :cnv-return(GtkInputHints)),
  get-input-purpose => %(:is-symbol<gtk_entry_get_input_purpose>,  :returns(GEnum), :cnv-return(GtkInputPurpose)),
  get-invisible-char => %(:is-symbol<gtk_entry_get_invisible_char>,  :returns(gunichar)),
  get-max-length => %(:is-symbol<gtk_entry_get_max_length>,  :returns(gint)),
  get-overwrite-mode => %(:is-symbol<gtk_entry_get_overwrite_mode>,  :returns(gboolean), :cnv-return(Bool)),
  get-placeholder-text => %(:is-symbol<gtk_entry_get_placeholder_text>,  :returns(Str)),
  get-progress-fraction => %(:is-symbol<gtk_entry_get_progress_fraction>,  :returns(gdouble)),
  get-progress-pulse-step => %(:is-symbol<gtk_entry_get_progress_pulse_step>,  :returns(gdouble)),
  get-tabs => %(:is-symbol<gtk_entry_get_tabs>,  :returns(N-TabArray)),
  get-text-length => %(:is-symbol<gtk_entry_get_text_length>,  :returns(guint16)),
  get-visibility => %(:is-symbol<gtk_entry_get_visibility>,  :returns(gboolean), :cnv-return(Bool)),
  grab-focus-without-selecting => %(:is-symbol<gtk_entry_grab_focus_without_selecting>,  :returns(gboolean), :cnv-return(Bool)),
  progress-pulse => %(:is-symbol<gtk_entry_progress_pulse>, ),
  reset-im-context => %(:is-symbol<gtk_entry_reset_im_context>, ),
  set-activates-default => %(:is-symbol<gtk_entry_set_activates_default>,  :parameters([gboolean])),
  set-alignment => %(:is-symbol<gtk_entry_set_alignment>,  :parameters([gfloat])),
  #set-attributes => %(:is-symbol<gtk_entry_set_attributes>,  :parameters([N-AttrList ])),
  set-buffer => %(:is-symbol<gtk_entry_set_buffer>,  :parameters([N-Object])),
  set-completion => %(:is-symbol<gtk_entry_set_completion>,  :parameters([N-Object])),
  set-extra-menu => %(:is-symbol<gtk_entry_set_extra_menu>,  :parameters([N-Object])),
  set-has-frame => %(:is-symbol<gtk_entry_set_has_frame>,  :parameters([gboolean])),
  set-icon-activatable => %(:is-symbol<gtk_entry_set_icon_activatable>,  :parameters([GEnum, gboolean])),
  set-icon-drag-source => %(:is-symbol<gtk_entry_set_icon_drag_source>,  :parameters([GEnum, N-Object, GFlag])),
  set-icon-from-gicon => %(:is-symbol<gtk_entry_set_icon_from_gicon>,  :parameters([GEnum, N-Object])),
  set-icon-from-icon-name => %(:is-symbol<gtk_entry_set_icon_from_icon_name>,  :parameters([GEnum, Str])),
  set-icon-from-paintable => %(:is-symbol<gtk_entry_set_icon_from_paintable>,  :parameters([GEnum, N-Object])),
  set-icon-sensitive => %(:is-symbol<gtk_entry_set_icon_sensitive>,  :parameters([GEnum, gboolean])),
  set-icon-tooltip-markup => %(:is-symbol<gtk_entry_set_icon_tooltip_markup>,  :parameters([GEnum, Str])),
  set-icon-tooltip-text => %(:is-symbol<gtk_entry_set_icon_tooltip_text>,  :parameters([GEnum, Str])),
  set-input-hints => %(:is-symbol<gtk_entry_set_input_hints>,  :parameters([GFlag])),
  set-input-purpose => %(:is-symbol<gtk_entry_set_input_purpose>,  :parameters([GEnum])),
  set-invisible-char => %(:is-symbol<gtk_entry_set_invisible_char>,  :parameters([gunichar])),
  set-max-length => %(:is-symbol<gtk_entry_set_max_length>,  :parameters([gint])),
  set-overwrite-mode => %(:is-symbol<gtk_entry_set_overwrite_mode>,  :parameters([gboolean])),
  set-placeholder-text => %(:is-symbol<gtk_entry_set_placeholder_text>,  :parameters([Str])),
  set-progress-fraction => %(:is-symbol<gtk_entry_set_progress_fraction>,  :parameters([gdouble])),
  set-progress-pulse-step => %(:is-symbol<gtk_entry_set_progress_pulse_step>,  :parameters([gdouble])),
  set-tabs => %(:is-symbol<gtk_entry_set_tabs>,  :parameters([N-TabArray])),
  set-visibility => %(:is-symbol<gtk_entry_set_visibility>,  :parameters([gboolean])),
  unset-invisible-char => %(:is-symbol<gtk_entry_unset_invisible_char>, ),
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
    $r = self._do_gtk_cell_editable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_cell_editable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_editable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_editable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
