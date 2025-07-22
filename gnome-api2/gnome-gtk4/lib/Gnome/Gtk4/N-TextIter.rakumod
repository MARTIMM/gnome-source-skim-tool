=comment Package: Gtk4, C-Source: textiter
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Glib::T-slist:api<2>;
use Gnome::Gtk4::T-textiter:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;
use Gnome::Pango::T-types:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::N-TextIter:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TextIter' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTextIter');
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

  #--[Methods]------------------------------------------------------------------
  assign => %(:is-symbol<gtk_text_iter_assign>, :parameters([N-Object]), ),
  backward-char => %(:is-symbol<gtk_text_iter_backward_char>, :returns(gboolean), :cnv-return(Bool), ),
  backward-chars => %(:is-symbol<gtk_text_iter_backward_chars>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  backward-cursor-position => %(:is-symbol<gtk_text_iter_backward_cursor_position>, :returns(gboolean), :cnv-return(Bool), ),
  backward-cursor-positions => %(:is-symbol<gtk_text_iter_backward_cursor_positions>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  backward-find-char => %(:is-symbol<gtk_text_iter_backward_find_char>, :returns(gboolean), :cnv-return(Bool), :parameters([:( gunichar $ch, gpointer $user-data ), gpointer, N-Object]), ),
  backward-line => %(:is-symbol<gtk_text_iter_backward_line>, :returns(gboolean), :cnv-return(Bool), ),
  backward-lines => %(:is-symbol<gtk_text_iter_backward_lines>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  backward-search => %(:is-symbol<gtk_text_iter_backward_search>, :returns(gboolean), :cnv-return(Bool), :parameters([Str, GFlag, N-Object, N-Object, N-Object]), ),
  backward-sentence-start => %(:is-symbol<gtk_text_iter_backward_sentence_start>, :returns(gboolean), :cnv-return(Bool), ),
  backward-sentence-starts => %(:is-symbol<gtk_text_iter_backward_sentence_starts>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  backward-to-tag-toggle => %(:is-symbol<gtk_text_iter_backward_to_tag_toggle>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  backward-visible-cursor-position => %(:is-symbol<gtk_text_iter_backward_visible_cursor_position>, :returns(gboolean), :cnv-return(Bool), ),
  backward-visible-cursor-positions => %(:is-symbol<gtk_text_iter_backward_visible_cursor_positions>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  backward-visible-line => %(:is-symbol<gtk_text_iter_backward_visible_line>, :returns(gboolean), :cnv-return(Bool), ),
  backward-visible-lines => %(:is-symbol<gtk_text_iter_backward_visible_lines>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  backward-visible-word-start => %(:is-symbol<gtk_text_iter_backward_visible_word_start>, :returns(gboolean), :cnv-return(Bool), ),
  backward-visible-word-starts => %(:is-symbol<gtk_text_iter_backward_visible_word_starts>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  backward-word-start => %(:is-symbol<gtk_text_iter_backward_word_start>, :returns(gboolean), :cnv-return(Bool), ),
  backward-word-starts => %(:is-symbol<gtk_text_iter_backward_word_starts>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  can-insert => %(:is-symbol<gtk_text_iter_can_insert>, :returns(gboolean), :cnv-return(Bool), :parameters([gboolean]), ),
  compare => %(:is-symbol<gtk_text_iter_compare>, :returns(gint), :parameters([N-Object]), ),
  copy => %(:is-symbol<gtk_text_iter_copy>, :returns(N-Object), ),
  editable => %(:is-symbol<gtk_text_iter_editable>, :returns(gboolean), :cnv-return(Bool), :parameters([gboolean]), ),
  ends-line => %(:is-symbol<gtk_text_iter_ends_line>, :returns(gboolean), :cnv-return(Bool), ),
  ends-sentence => %(:is-symbol<gtk_text_iter_ends_sentence>, :returns(gboolean), :cnv-return(Bool), ),
  ends-tag => %(:is-symbol<gtk_text_iter_ends_tag>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  ends-word => %(:is-symbol<gtk_text_iter_ends_word>, :returns(gboolean), :cnv-return(Bool), ),
  equal => %(:is-symbol<gtk_text_iter_equal>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  forward-char => %(:is-symbol<gtk_text_iter_forward_char>, :returns(gboolean), :cnv-return(Bool), ),
  forward-chars => %(:is-symbol<gtk_text_iter_forward_chars>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  forward-cursor-position => %(:is-symbol<gtk_text_iter_forward_cursor_position>, :returns(gboolean), :cnv-return(Bool), ),
  forward-cursor-positions => %(:is-symbol<gtk_text_iter_forward_cursor_positions>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  forward-find-char => %(:is-symbol<gtk_text_iter_forward_find_char>, :returns(gboolean), :cnv-return(Bool), :parameters([:( gunichar $ch, gpointer $user-data ), gpointer, N-Object]), ),
  forward-line => %(:is-symbol<gtk_text_iter_forward_line>, :returns(gboolean), :cnv-return(Bool), ),
  forward-lines => %(:is-symbol<gtk_text_iter_forward_lines>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  forward-search => %(:is-symbol<gtk_text_iter_forward_search>, :returns(gboolean), :cnv-return(Bool), :parameters([Str, GFlag, N-Object, N-Object, N-Object]), ),
  forward-sentence-end => %(:is-symbol<gtk_text_iter_forward_sentence_end>, :returns(gboolean), :cnv-return(Bool), ),
  forward-sentence-ends => %(:is-symbol<gtk_text_iter_forward_sentence_ends>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  forward-to-end => %(:is-symbol<gtk_text_iter_forward_to_end>, ),
  forward-to-line-end => %(:is-symbol<gtk_text_iter_forward_to_line_end>, :returns(gboolean), :cnv-return(Bool), ),
  forward-to-tag-toggle => %(:is-symbol<gtk_text_iter_forward_to_tag_toggle>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  forward-visible-cursor-position => %(:is-symbol<gtk_text_iter_forward_visible_cursor_position>, :returns(gboolean), :cnv-return(Bool), ),
  forward-visible-cursor-positions => %(:is-symbol<gtk_text_iter_forward_visible_cursor_positions>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  forward-visible-line => %(:is-symbol<gtk_text_iter_forward_visible_line>, :returns(gboolean), :cnv-return(Bool), ),
  forward-visible-lines => %(:is-symbol<gtk_text_iter_forward_visible_lines>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  forward-visible-word-end => %(:is-symbol<gtk_text_iter_forward_visible_word_end>, :returns(gboolean), :cnv-return(Bool), ),
  forward-visible-word-ends => %(:is-symbol<gtk_text_iter_forward_visible_word_ends>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  forward-word-end => %(:is-symbol<gtk_text_iter_forward_word_end>, :returns(gboolean), :cnv-return(Bool), ),
  forward-word-ends => %(:is-symbol<gtk_text_iter_forward_word_ends>, :returns(gboolean), :cnv-return(Bool), :parameters([gint]), ),
  free => %(:is-symbol<gtk_text_iter_free>, ),
  get-buffer => %(:is-symbol<gtk_text_iter_get_buffer>, :returns(N-Object), ),
  get-bytes-in-line => %(:is-symbol<gtk_text_iter_get_bytes_in_line>, :returns(gint), ),
  get-char => %(:is-symbol<gtk_text_iter_get_char>, :returns(gunichar), ),
  get-chars-in-line => %(:is-symbol<gtk_text_iter_get_chars_in_line>, :returns(gint), ),
  get-child-anchor => %(:is-symbol<gtk_text_iter_get_child_anchor>, :returns(N-Object), ),
  get-language => %(:is-symbol<gtk_text_iter_get_language>, :returns(N-Object), ),
  get-line => %(:is-symbol<gtk_text_iter_get_line>, :returns(gint), ),
  get-line-index => %(:is-symbol<gtk_text_iter_get_line_index>, :returns(gint), ),
  get-line-offset => %(:is-symbol<gtk_text_iter_get_line_offset>, :returns(gint), ),
  get-marks => %(:is-symbol<gtk_text_iter_get_marks>, :returns(N-Object), ),
  get-offset => %(:is-symbol<gtk_text_iter_get_offset>, :returns(gint), ),
  get-paintable => %(:is-symbol<gtk_text_iter_get_paintable>, :returns(N-Object), ),
  get-slice => %(:is-symbol<gtk_text_iter_get_slice>, :returns(Str), :parameters([N-Object]), ),
  get-tags => %(:is-symbol<gtk_text_iter_get_tags>, :returns(N-Object), ),
  get-text => %(:is-symbol<gtk_text_iter_get_text>, :returns(Str), :parameters([N-Object]), ),
  get-toggled-tags => %(:is-symbol<gtk_text_iter_get_toggled_tags>, :returns(N-Object), :parameters([gboolean]), ),
  get-visible-line-index => %(:is-symbol<gtk_text_iter_get_visible_line_index>, :returns(gint), ),
  get-visible-line-offset => %(:is-symbol<gtk_text_iter_get_visible_line_offset>, :returns(gint), ),
  get-visible-slice => %(:is-symbol<gtk_text_iter_get_visible_slice>, :returns(Str), :parameters([N-Object]), ),
  get-visible-text => %(:is-symbol<gtk_text_iter_get_visible_text>, :returns(Str), :parameters([N-Object]), ),
  has-tag => %(:is-symbol<gtk_text_iter_has_tag>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  in-range => %(:is-symbol<gtk_text_iter_in_range>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, N-Object]), ),
  inside-sentence => %(:is-symbol<gtk_text_iter_inside_sentence>, :returns(gboolean), :cnv-return(Bool), ),
  inside-word => %(:is-symbol<gtk_text_iter_inside_word>, :returns(gboolean), :cnv-return(Bool), ),
  is-cursor-position => %(:is-symbol<gtk_text_iter_is_cursor_position>, :returns(gboolean), :cnv-return(Bool), ),
  is-end => %(:is-symbol<gtk_text_iter_is_end>, :returns(gboolean), :cnv-return(Bool), ),
  is-start => %(:is-symbol<gtk_text_iter_is_start>, :returns(gboolean), :cnv-return(Bool), ),
  order => %(:is-symbol<gtk_text_iter_order>, :parameters([N-Object]), ),
  set-line => %(:is-symbol<gtk_text_iter_set_line>, :parameters([gint]), ),
  set-line-index => %(:is-symbol<gtk_text_iter_set_line_index>, :parameters([gint]), ),
  set-line-offset => %(:is-symbol<gtk_text_iter_set_line_offset>, :parameters([gint]), ),
  set-offset => %(:is-symbol<gtk_text_iter_set_offset>, :parameters([gint]), ),
  set-visible-line-index => %(:is-symbol<gtk_text_iter_set_visible_line_index>, :parameters([gint]), ),
  set-visible-line-offset => %(:is-symbol<gtk_text_iter_set_visible_line_offset>, :parameters([gint]), ),
  starts-line => %(:is-symbol<gtk_text_iter_starts_line>, :returns(gboolean), :cnv-return(Bool), ),
  starts-sentence => %(:is-symbol<gtk_text_iter_starts_sentence>, :returns(gboolean), :cnv-return(Bool), ),
  starts-tag => %(:is-symbol<gtk_text_iter_starts_tag>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  starts-word => %(:is-symbol<gtk_text_iter_starts_word>, :returns(gboolean), :cnv-return(Bool), ),
  toggles-tag => %(:is-symbol<gtk_text_iter_toggles_tag>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
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
