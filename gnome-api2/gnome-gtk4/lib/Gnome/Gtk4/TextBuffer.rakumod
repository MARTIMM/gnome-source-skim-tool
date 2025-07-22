=comment Package: Gtk4, C-Source: textbuffer
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::Object:api<2>;
use Gnome::Gtk4::N-TextIter:api<2>;
use Gnome::Gtk4::T-textiter:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::TextBuffer:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
      :w0<changed modified-changed redo undo begin-user-action end-user-action>,
      :w1<mark-deleted paste-done>,
      :w2<mark-set insert-paintable insert-child-anchor delete-range>,
      :w3<remove-tag apply-tag insert-text>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::TextBuffer' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkTextBuffer');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-textbuffer => %( :type(Constructor), :is-symbol<gtk_text_buffer_new>, :returns(N-Object), :parameters([ N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  add-mark => %(:is-symbol<gtk_text_buffer_add_mark>, :parameters([N-Object, N-Object]), ),
  add-selection-clipboard => %(:is-symbol<gtk_text_buffer_add_selection_clipboard>, :parameters([N-Object]), ),
  apply-tag => %(:is-symbol<gtk_text_buffer_apply_tag>, :parameters([N-Object, N-Object, N-Object]), ),
  apply-tag-by-name => %(:is-symbol<gtk_text_buffer_apply_tag_by_name>, :parameters([Str, N-Object, N-Object]), ),
  backspace => %(:is-symbol<gtk_text_buffer_backspace>, :returns(gboolean), :parameters([N-Object, gboolean, gboolean]), ),
  begin-irreversible-action => %(:is-symbol<gtk_text_buffer_begin_irreversible_action>, ),
  begin-user-action => %(:is-symbol<gtk_text_buffer_begin_user_action>, ),
  copy-clipboard => %(:is-symbol<gtk_text_buffer_copy_clipboard>, :parameters([N-Object]), ),
  create-child-anchor => %(:is-symbol<gtk_text_buffer_create_child_anchor>, :returns(N-Object), :parameters([N-Object]), ),
  create-mark => %(:is-symbol<gtk_text_buffer_create_mark>, :returns(N-Object), :parameters([Str, N-Object, gboolean]), ),
  create-tag => %(:is-symbol<gtk_text_buffer_create_tag>, :variable-list, :returns(N-Object), :parameters([Str, Str]), ),
  cut-clipboard => %(:is-symbol<gtk_text_buffer_cut_clipboard>, :parameters([N-Object, gboolean]), ),
  delete => %(:is-symbol<gtk_text_buffer_delete>, :parameters([N-Object, N-Object]), ),
  delete-interactive => %(:is-symbol<gtk_text_buffer_delete_interactive>, :returns(gboolean), :parameters([N-Object, N-Object, gboolean]), ),
  delete-mark => %(:is-symbol<gtk_text_buffer_delete_mark>, :parameters([N-Object]), ),
  delete-mark-by-name => %(:is-symbol<gtk_text_buffer_delete_mark_by_name>, :parameters([Str]), ),
  delete-selection => %(:is-symbol<gtk_text_buffer_delete_selection>, :returns(gboolean), :parameters([gboolean, gboolean]), ),
  end-irreversible-action => %(:is-symbol<gtk_text_buffer_end_irreversible_action>, ),
  end-user-action => %(:is-symbol<gtk_text_buffer_end_user_action>, ),
  get-bounds => %(:is-symbol<gtk_text_buffer_get_bounds>, :parameters([N-Object, N-Object]), ),
  get-can-redo => %(:is-symbol<gtk_text_buffer_get_can_redo>, :returns(gboolean), ),
  get-can-undo => %(:is-symbol<gtk_text_buffer_get_can_undo>, :returns(gboolean), ),
  get-char-count => %(:is-symbol<gtk_text_buffer_get_char_count>, :returns(gint), ),
  get-enable-undo => %(:is-symbol<gtk_text_buffer_get_enable_undo>, :returns(gboolean), ),
  get-end-iter => %(:is-symbol<gtk_text_buffer_get_end_iter>, :parameters([N-Object]), ),
  get-has-selection => %(:is-symbol<gtk_text_buffer_get_has_selection>, :returns(gboolean), ),
  get-insert => %(:is-symbol<gtk_text_buffer_get_insert>, :returns(N-Object), ),
  get-iter-at-child-anchor => %(:is-symbol<gtk_text_buffer_get_iter_at_child_anchor>, :parameters([N-Object, N-Object]), ),
  get-iter-at-line => %(:is-symbol<gtk_text_buffer_get_iter_at_line>, :returns(gboolean), :parameters([N-Object, gint]), ),
  get-iter-at-line-index => %(:is-symbol<gtk_text_buffer_get_iter_at_line_index>, :returns(gboolean), :parameters([N-Object, gint, gint]), ),
  get-iter-at-line-offset => %(:is-symbol<gtk_text_buffer_get_iter_at_line_offset>, :returns(gboolean), :parameters([N-Object, gint, gint]), ),
  get-iter-at-mark => %(:is-symbol<gtk_text_buffer_get_iter_at_mark>, :parameters([N-Object, N-Object]), ),
  get-iter-at-offset => %(:is-symbol<gtk_text_buffer_get_iter_at_offset>, :parameters([N-Object, gint]), ),
  get-line-count => %(:is-symbol<gtk_text_buffer_get_line_count>, :returns(gint), ),
  get-mark => %(:is-symbol<gtk_text_buffer_get_mark>, :returns(N-Object), :parameters([Str]), ),
  get-max-undo-levels => %(:is-symbol<gtk_text_buffer_get_max_undo_levels>, :returns(guint), ),
  get-modified => %(:is-symbol<gtk_text_buffer_get_modified>, :returns(gboolean), ),
  get-selection-bound => %(:is-symbol<gtk_text_buffer_get_selection_bound>, :returns(N-Object), ),
  get-selection-bounds => %(:is-symbol<gtk_text_buffer_get_selection_bounds>, :returns(gboolean), :parameters([N-Object, N-Object]), ),
  get-selection-content => %(:is-symbol<gtk_text_buffer_get_selection_content>, :returns(N-Object), ),
  get-slice => %(:is-symbol<gtk_text_buffer_get_slice>, :returns(Str), :parameters([N-Object, N-Object, gboolean]), ),
  get-start-iter => %(:is-symbol<gtk_text_buffer_get_start_iter>, :parameters([N-Object]), ),
  get-tag-table => %(:is-symbol<gtk_text_buffer_get_tag_table>, :returns(N-Object), ),
  get-text => %(:is-symbol<gtk_text_buffer_get_text>, :returns(Str), :parameters([N-Object, N-Object, gboolean]), ),
  insert => %(:is-symbol<gtk_text_buffer_insert>, :parameters([N-Object, Str, gint]), ),
  insert-at-cursor => %(:is-symbol<gtk_text_buffer_insert_at_cursor>, :parameters([Str, gint]), ),
  insert-child-anchor => %(:is-symbol<gtk_text_buffer_insert_child_anchor>, :parameters([N-Object, N-Object]), ),
  insert-interactive => %(:is-symbol<gtk_text_buffer_insert_interactive>, :returns(gboolean), :parameters([N-Object, Str, gint, gboolean]), ),
  insert-interactive-at-cursor => %(:is-symbol<gtk_text_buffer_insert_interactive_at_cursor>, :returns(gboolean), :parameters([Str, gint, gboolean]), ),
  insert-markup => %(:is-symbol<gtk_text_buffer_insert_markup>, :parameters([N-Object, Str, gint]), ),
  insert-paintable => %(:is-symbol<gtk_text_buffer_insert_paintable>, :parameters([N-Object, N-Object]), ),
  insert-range => %(:is-symbol<gtk_text_buffer_insert_range>, :parameters([N-Object, N-Object, N-Object]), ),
  insert-range-interactive => %(:is-symbol<gtk_text_buffer_insert_range_interactive>, :returns(gboolean), :parameters([N-Object, N-Object, N-Object, gboolean]), ),
  insert-with-tags => %(:is-symbol<gtk_text_buffer_insert_with_tags>, :variable-list, :parameters([N-Object, Str, gint, N-Object]), ),
  insert-with-tags-by-name => %(:is-symbol<gtk_text_buffer_insert_with_tags_by_name>, :variable-list, :parameters([N-Object, Str, gint, Str]), ),
  move-mark => %(:is-symbol<gtk_text_buffer_move_mark>, :parameters([N-Object, N-Object]), ),
  move-mark-by-name => %(:is-symbol<gtk_text_buffer_move_mark_by_name>, :parameters([Str, N-Object]), ),
  paste-clipboard => %(:is-symbol<gtk_text_buffer_paste_clipboard>, :parameters([N-Object, N-Object, gboolean]), ),
  place-cursor => %(:is-symbol<gtk_text_buffer_place_cursor>, :parameters([N-Object]), ),
  redo => %(:is-symbol<gtk_text_buffer_redo>, ),
  remove-all-tags => %(:is-symbol<gtk_text_buffer_remove_all_tags>, :parameters([N-Object, N-Object]), ),
  remove-selection-clipboard => %(:is-symbol<gtk_text_buffer_remove_selection_clipboard>, :parameters([N-Object]), ),
  remove-tag => %(:is-symbol<gtk_text_buffer_remove_tag>, :parameters([N-Object, N-Object, N-Object]), ),
  remove-tag-by-name => %(:is-symbol<gtk_text_buffer_remove_tag_by_name>, :parameters([Str, N-Object, N-Object]), ),
  select-range => %(:is-symbol<gtk_text_buffer_select_range>, :parameters([N-Object, N-Object]), ),
  set-enable-undo => %(:is-symbol<gtk_text_buffer_set_enable_undo>, :parameters([gboolean]), ),
  set-max-undo-levels => %(:is-symbol<gtk_text_buffer_set_max_undo_levels>, :parameters([guint]), ),
  set-modified => %(:is-symbol<gtk_text_buffer_set_modified>, :parameters([gboolean]), ),
  set-text => %(:is-symbol<gtk_text_buffer_set_text>, :parameters([Str, gint]), ),
  undo => %(:is-symbol<gtk_text_buffer_undo>, ),
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
