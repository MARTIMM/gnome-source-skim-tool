=comment Package: Gtk4, C-Source: entrycompletion
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Gtk4::N-TreeIter:api<2>;
use Gnome::Gtk4::R-Buildable:api<2>;
use Gnome::Gtk4::R-CellLayout:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::EntryCompletion:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gtk4::R-Buildable;
also does Gnome::Gtk4::R-CellLayout;

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
      :w0<no-matches>,
      :w1<insert-prefix>,
      :w2<match-selected cursor-on-match>,
    );

    # Signals from interfaces
    self._add_gtk_buildable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_buildable_signal_types');
    self._add_gtk_cell_layout_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_cell_layout_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::EntryCompletion' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkEntryCompletion');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-entrycompletion => %( :type(Constructor), :is-symbol<gtk_entry_completion_new>, :returns(N-Object), ),
  new-with-area => %( :type(Constructor), :is-symbol<gtk_entry_completion_new_with_area>, :returns(N-Object), :parameters([ N-Object])),

  #--[Methods]------------------------------------------------------------------
  complete => %(:is-symbol<gtk_entry_completion_complete>, ),
  compute-prefix => %(:is-symbol<gtk_entry_completion_compute_prefix>,  :returns(Str), :parameters([Str])),
  get-completion-prefix => %(:is-symbol<gtk_entry_completion_get_completion_prefix>,  :returns(Str)),
  get-entry => %(:is-symbol<gtk_entry_completion_get_entry>,  :returns(N-Object)),
  get-inline-completion => %(:is-symbol<gtk_entry_completion_get_inline_completion>,  :returns(gboolean), :cnv-return(Bool)),
  get-inline-selection => %(:is-symbol<gtk_entry_completion_get_inline_selection>,  :returns(gboolean), :cnv-return(Bool)),
  get-minimum-key-length => %(:is-symbol<gtk_entry_completion_get_minimum_key_length>,  :returns(gint)),
  get-model => %(:is-symbol<gtk_entry_completion_get_model>,  :returns(N-Object)),
  get-popup-completion => %(:is-symbol<gtk_entry_completion_get_popup_completion>,  :returns(gboolean), :cnv-return(Bool)),
  get-popup-set-width => %(:is-symbol<gtk_entry_completion_get_popup_set_width>,  :returns(gboolean), :cnv-return(Bool)),
  get-popup-single-match => %(:is-symbol<gtk_entry_completion_get_popup_single_match>,  :returns(gboolean), :cnv-return(Bool)),
  get-text-column => %(:is-symbol<gtk_entry_completion_get_text_column>,  :returns(gint)),
  insert-prefix => %(:is-symbol<gtk_entry_completion_insert_prefix>, ),
  set-inline-completion => %(:is-symbol<gtk_entry_completion_set_inline_completion>,  :parameters([gboolean])),
  set-inline-selection => %(:is-symbol<gtk_entry_completion_set_inline_selection>,  :parameters([gboolean])),
  #set-match-func => %(:is-symbol<gtk_entry_completion_set_match_func>,  :parameters([:( N-Object $completion, Str $key, N-TreeIter $iter, gpointer $user-data --> gboolean ), gpointer, ])),
  set-minimum-key-length => %(:is-symbol<gtk_entry_completion_set_minimum_key_length>,  :parameters([gint])),
  set-model => %(:is-symbol<gtk_entry_completion_set_model>,  :parameters([N-Object])),
  set-popup-completion => %(:is-symbol<gtk_entry_completion_set_popup_completion>,  :parameters([gboolean])),
  set-popup-set-width => %(:is-symbol<gtk_entry_completion_set_popup_set_width>,  :parameters([gboolean])),
  set-popup-single-match => %(:is-symbol<gtk_entry_completion_set_popup_single_match>,  :parameters([gboolean])),
  set-text-column => %(:is-symbol<gtk_entry_completion_set_text_column>,  :parameters([gint])),
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
    $r = self._do_gtk_buildable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_buildable_fallback-v2');
    return $r if $_fallback-v2-ok;

    $r = self._do_gtk_cell_layout_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_cell_layout_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
