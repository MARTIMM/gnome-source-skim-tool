=comment Package: Gtk4, C-Source: text
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Graphene::N-Rect:api<2>;
use Gnome::Graphene::T-rect:api<2>;
#use Gnome::Gtk4::R-AccessibleText:api<2>;
use Gnome::Gtk4::R-Editable:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-AttrList:api<2>;
use Gnome::Pango::N-TabArray:api<2>;
#use Gnome::Pango::T-attributes:api<2>;
#use Gnome::Pango::T-tabs:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Text:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
#also does Gnome::Gtk4::R-AccessibleText;
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
      :w0<toggle-overwrite copy-clipboard insert-emoji cut-clipboard backspace activate paste-clipboard>,
      :w1<insert-at-cursor preedit-changed>,
      :w2<delete-from-cursor>,
      :w3<move-cursor>,
    );

    # Signals from interfaces
#`{{
    self._add_gtk_accessible_text_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_accessible_text_signal_types');
}}
    self._add_gtk_editable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_editable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Text' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkText');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-text => %( :type(Constructor), :is-symbol<gtk_text_new>, :returns(N-Object), ),
  new-with-buffer => %( :type(Constructor), :is-symbol<gtk_text_new_with_buffer>, :returns(N-Object), :parameters([ N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  compute-cursor-extents => %(:is-symbol<gtk_text_compute_cursor_extents>, :parameters([gsize, N-Object, N-Object]), ),
  get-activates-default => %(:is-symbol<gtk_text_get_activates_default>, :returns(gboolean), ),
  get-attributes => %(:is-symbol<gtk_text_get_attributes>, :returns(N-Object), ),
  get-buffer => %(:is-symbol<gtk_text_get_buffer>, :returns(N-Object), ),
  get-enable-emoji-completion => %(:is-symbol<gtk_text_get_enable_emoji_completion>, :returns(gboolean), ),
  get-extra-menu => %(:is-symbol<gtk_text_get_extra_menu>, :returns(N-Object), ),
  get-input-hints => %(:is-symbol<gtk_text_get_input_hints>,  :returns(GFlag), :cnv-return(GtkInputHints)),
  get-input-purpose => %(:is-symbol<gtk_text_get_input_purpose>,  :returns(GEnum), :cnv-return(GtkInputPurpose)),
  get-invisible-char => %(:is-symbol<gtk_text_get_invisible_char>, :returns(gunichar), ),
  get-max-length => %(:is-symbol<gtk_text_get_max_length>, :returns(gint), ),
  get-overwrite-mode => %(:is-symbol<gtk_text_get_overwrite_mode>, :returns(gboolean), ),
  get-placeholder-text => %(:is-symbol<gtk_text_get_placeholder_text>, :returns(Str), ),
  get-propagate-text-width => %(:is-symbol<gtk_text_get_propagate_text_width>, :returns(gboolean), ),
  get-tabs => %(:is-symbol<gtk_text_get_tabs>, :returns(N-Object), ),
  get-text-length => %(:is-symbol<gtk_text_get_text_length>, :returns(guint16), ),
  get-truncate-multiline => %(:is-symbol<gtk_text_get_truncate_multiline>, :returns(gboolean), ),
  get-visibility => %(:is-symbol<gtk_text_get_visibility>, :returns(gboolean), ),
  grab-focus-without-selecting => %(:is-symbol<gtk_text_grab_focus_without_selecting>, :returns(gboolean), ),
  set-activates-default => %(:is-symbol<gtk_text_set_activates_default>, :parameters([gboolean]), ),
  set-attributes => %(:is-symbol<gtk_text_set_attributes>, :parameters([N-Object]), ),
  set-buffer => %(:is-symbol<gtk_text_set_buffer>, :parameters([N-Object]), ),
  set-enable-emoji-completion => %(:is-symbol<gtk_text_set_enable_emoji_completion>, :parameters([gboolean]), ),
  set-extra-menu => %(:is-symbol<gtk_text_set_extra_menu>, :parameters([N-Object]), ),
  set-input-hints => %(:is-symbol<gtk_text_set_input_hints>, :parameters([GFlag]), ),
  set-input-purpose => %(:is-symbol<gtk_text_set_input_purpose>, :parameters([GEnum]), ),
  set-invisible-char => %(:is-symbol<gtk_text_set_invisible_char>, :parameters([gunichar]), ),
  set-max-length => %(:is-symbol<gtk_text_set_max_length>, :parameters([gint]), ),
  set-overwrite-mode => %(:is-symbol<gtk_text_set_overwrite_mode>, :parameters([gboolean]), ),
  set-placeholder-text => %(:is-symbol<gtk_text_set_placeholder_text>, :parameters([Str]), ),
  set-propagate-text-width => %(:is-symbol<gtk_text_set_propagate_text_width>, :parameters([gboolean]), ),
  set-tabs => %(:is-symbol<gtk_text_set_tabs>, :parameters([N-Object]), ),
  set-truncate-multiline => %(:is-symbol<gtk_text_set_truncate_multiline>, :parameters([gboolean]), ),
  set-visibility => %(:is-symbol<gtk_text_set_visibility>, :parameters([gboolean]), ),
  unset-invisible-char => %(:is-symbol<gtk_text_unset_invisible_char>, ),
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
    $r = self._do_gtk_accessible_text_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_accessible_text_fallback-v2');
    return $r if $_fallback-v2-ok;

}}
    $r = self._do_gtk_editable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_editable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
