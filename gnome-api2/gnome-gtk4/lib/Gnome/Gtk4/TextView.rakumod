=comment Package: Gtk4, C-Source: textview
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gdk4::N-Rectangle:api<2>;
#use Gnome::Gtk4::N-TextIter:api<2>;
#use Gnome::Gtk4::R-Scrollable:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
#use Gnome::Gtk4::T-TextView:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
use Gnome::Pango::N-TabArray:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::TextView:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
#also does Gnome::Gtk4::R-Scrollable;

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
      :w0<insert-emoji copy-clipboard toggle-overwrite backspace cut-clipboard toggle-cursor-visible set-anchor paste-clipboard>,
      :w1<insert-at-cursor select-all preedit-changed>,
      :w2<move-viewport delete-from-cursor>,
      :w3<move-cursor>,
      :w4<extend-selection>,
    );

    # Signals from interfaces
#`{{
    self._add_gtk_scrollable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_scrollable_signal_types');
}}
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TextView' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTextView');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-textview => %( :type(Constructor), :is-symbol<gtk_text_view_new>, :returns(N-Object), ),
  new-with-buffer => %( :type(Constructor), :is-symbol<gtk_text_view_new_with_buffer>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  add-child-at-anchor => %(:is-symbol<gtk_text_view_add_child_at_anchor>,  :parameters([N-Object, N-Object])),
  add-overlay => %(:is-symbol<gtk_text_view_add_overlay>,  :parameters([N-Object, gint, gint])),
  #backward-display-line => %(:is-symbol<gtk_text_view_backward_display_line>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter ])),
  #backward-display-line-start => %(:is-symbol<gtk_text_view_backward_display_line_start>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter ])),
  #buffer-to-window-coords => %(:is-symbol<gtk_text_view_buffer_to_window_coords>,  :parameters([GEnum, gint, gint, gint-ptr, gint-ptr])),
  #forward-display-line => %(:is-symbol<gtk_text_view_forward_display_line>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter ])),
  #forward-display-line-end => %(:is-symbol<gtk_text_view_forward_display_line_end>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter ])),
  get-accepts-tab => %(:is-symbol<gtk_text_view_get_accepts_tab>,  :returns(gboolean), :cnv-return(Bool)),
  get-bottom-margin => %(:is-symbol<gtk_text_view_get_bottom_margin>,  :returns(gint)),
  get-buffer => %(:is-symbol<gtk_text_view_get_buffer>,  :returns(N-Object)),
  #get-cursor-locations => %(:is-symbol<gtk_text_view_get_cursor_locations>,  :parameters([N-TextIter , N-Rectangle, N-Rectangle])),
  get-cursor-visible => %(:is-symbol<gtk_text_view_get_cursor_visible>,  :returns(gboolean), :cnv-return(Bool)),
  get-editable => %(:is-symbol<gtk_text_view_get_editable>,  :returns(gboolean), :cnv-return(Bool)),
  get-extra-menu => %(:is-symbol<gtk_text_view_get_extra_menu>,  :returns(N-Object)),
  #get-gutter => %(:is-symbol<gtk_text_view_get_gutter>,  :returns(N-Object), :parameters([GEnum])),
  get-indent => %(:is-symbol<gtk_text_view_get_indent>,  :returns(gint)),
  get-input-hints => %(:is-symbol<gtk_text_view_get_input_hints>,  :returns(GFlag), :cnv-return(GtkInputHints)),
  get-input-purpose => %(:is-symbol<gtk_text_view_get_input_purpose>,  :returns(GEnum), :cnv-return(GtkInputPurpose)),
  #get-iter-at-location => %(:is-symbol<gtk_text_view_get_iter_at_location>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter , gint, gint])),
  #get-iter-at-position => %(:is-symbol<gtk_text_view_get_iter_at_position>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter , gint-ptr, gint, gint])),
  #get-iter-location => %(:is-symbol<gtk_text_view_get_iter_location>,  :parameters([N-TextIter , N-Rectangle])),
  get-justification => %(:is-symbol<gtk_text_view_get_justification>,  :returns(GEnum), :cnv-return(GtkJustification)),
  get-left-margin => %(:is-symbol<gtk_text_view_get_left_margin>,  :returns(gint)),
  #get-line-at-y => %(:is-symbol<gtk_text_view_get_line_at_y>,  :parameters([N-TextIter , gint, gint-ptr])),
  #get-line-yrange => %(:is-symbol<gtk_text_view_get_line_yrange>,  :parameters([N-TextIter , gint-ptr, gint-ptr])),
  get-ltr-context => %(:is-symbol<gtk_text_view_get_ltr_context>,  :returns(N-Object)),
  get-monospace => %(:is-symbol<gtk_text_view_get_monospace>,  :returns(gboolean), :cnv-return(Bool)),
  get-overwrite => %(:is-symbol<gtk_text_view_get_overwrite>,  :returns(gboolean), :cnv-return(Bool)),
  get-pixels-above-lines => %(:is-symbol<gtk_text_view_get_pixels_above_lines>,  :returns(gint)),
  get-pixels-below-lines => %(:is-symbol<gtk_text_view_get_pixels_below_lines>,  :returns(gint)),
  get-pixels-inside-wrap => %(:is-symbol<gtk_text_view_get_pixels_inside_wrap>,  :returns(gint)),
  get-right-margin => %(:is-symbol<gtk_text_view_get_right_margin>,  :returns(gint)),
  get-rtl-context => %(:is-symbol<gtk_text_view_get_rtl_context>,  :returns(N-Object)),
  get-tabs => %(:is-symbol<gtk_text_view_get_tabs>,  :returns(N-TabArray)),
  get-top-margin => %(:is-symbol<gtk_text_view_get_top_margin>,  :returns(gint)),
  get-visible-rect => %(:is-symbol<gtk_text_view_get_visible_rect>,  :parameters([N-Rectangle])),
  get-wrap-mode => %(:is-symbol<gtk_text_view_get_wrap_mode>,  :returns(GEnum), :cnv-return(GtkWrapMode)),
  im-context-filter-keypress => %(:is-symbol<gtk_text_view_im_context_filter_keypress>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  move-mark-onscreen => %(:is-symbol<gtk_text_view_move_mark_onscreen>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  move-overlay => %(:is-symbol<gtk_text_view_move_overlay>,  :parameters([N-Object, gint, gint])),
  #move-visually => %(:is-symbol<gtk_text_view_move_visually>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter , gint])),
  place-cursor-onscreen => %(:is-symbol<gtk_text_view_place_cursor_onscreen>,  :returns(gboolean), :cnv-return(Bool)),
  remove => %(:is-symbol<gtk_text_view_remove>,  :parameters([N-Object])),
  reset-cursor-blink => %(:is-symbol<gtk_text_view_reset_cursor_blink>, ),
  reset-im-context => %(:is-symbol<gtk_text_view_reset_im_context>, ),
  scroll-mark-onscreen => %(:is-symbol<gtk_text_view_scroll_mark_onscreen>,  :parameters([N-Object])),
  #scroll-to-iter => %(:is-symbol<gtk_text_view_scroll_to_iter>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter , gdouble, gboolean, gdouble, gdouble])),
  scroll-to-mark => %(:is-symbol<gtk_text_view_scroll_to_mark>,  :parameters([N-Object, gdouble, gboolean, gdouble, gdouble])),
  set-accepts-tab => %(:is-symbol<gtk_text_view_set_accepts_tab>,  :parameters([gboolean])),
  set-bottom-margin => %(:is-symbol<gtk_text_view_set_bottom_margin>,  :parameters([gint])),
  set-buffer => %(:is-symbol<gtk_text_view_set_buffer>,  :parameters([N-Object])),
  set-cursor-visible => %(:is-symbol<gtk_text_view_set_cursor_visible>,  :parameters([gboolean])),
  set-editable => %(:is-symbol<gtk_text_view_set_editable>,  :parameters([gboolean])),
  set-extra-menu => %(:is-symbol<gtk_text_view_set_extra_menu>,  :parameters([N-Object])),
  #set-gutter => %(:is-symbol<gtk_text_view_set_gutter>,  :parameters([GEnum, N-Object])),
  set-indent => %(:is-symbol<gtk_text_view_set_indent>,  :parameters([gint])),
  set-input-hints => %(:is-symbol<gtk_text_view_set_input_hints>,  :parameters([GFlag])),
  set-input-purpose => %(:is-symbol<gtk_text_view_set_input_purpose>,  :parameters([GEnum])),
  set-justification => %(:is-symbol<gtk_text_view_set_justification>,  :parameters([GEnum])),
  set-left-margin => %(:is-symbol<gtk_text_view_set_left_margin>,  :parameters([gint])),
  set-monospace => %(:is-symbol<gtk_text_view_set_monospace>,  :parameters([gboolean])),
  set-overwrite => %(:is-symbol<gtk_text_view_set_overwrite>,  :parameters([gboolean])),
  set-pixels-above-lines => %(:is-symbol<gtk_text_view_set_pixels_above_lines>,  :parameters([gint])),
  set-pixels-below-lines => %(:is-symbol<gtk_text_view_set_pixels_below_lines>,  :parameters([gint])),
  set-pixels-inside-wrap => %(:is-symbol<gtk_text_view_set_pixels_inside_wrap>,  :parameters([gint])),
  set-right-margin => %(:is-symbol<gtk_text_view_set_right_margin>,  :parameters([gint])),
  set-tabs => %(:is-symbol<gtk_text_view_set_tabs>,  :parameters([N-TabArray])),
  set-top-margin => %(:is-symbol<gtk_text_view_set_top_margin>,  :parameters([gint])),
  set-wrap-mode => %(:is-symbol<gtk_text_view_set_wrap_mode>,  :parameters([GEnum])),
  #starts-display-line => %(:is-symbol<gtk_text_view_starts_display_line>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-TextIter ])),
  #window-to-buffer-coords => %(:is-symbol<gtk_text_view_window_to_buffer_coords>,  :parameters([GEnum, gint, gint, gint-ptr, gint-ptr])),
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
#`{{
    $r = self.Gnome::Gtk4::R-Scrollable::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

}}
    callsame;
  }
}
