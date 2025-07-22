=comment Package: Gtk4, C-Source: searchentry
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::R-Editable:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::SearchEntry:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
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
      :w0<stop-search previous-match search-changed activate search-started next-match>,
    );

    # Signals from interfaces
    self._add_gtk_editable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_editable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::SearchEntry' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkSearchEntry');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-searchentry => %( :type(Constructor), :is-symbol<gtk_search_entry_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-input-hints => %(:is-symbol<gtk_search_entry_get_input_hints>,  :returns(GFlag), :cnv-return(GtkInputHints)),
  get-input-purpose => %(:is-symbol<gtk_search_entry_get_input_purpose>,  :returns(GEnum), :cnv-return(GtkInputPurpose)),
  get-key-capture-widget => %(:is-symbol<gtk_search_entry_get_key_capture_widget>, :returns(N-Object), ),
  get-placeholder-text => %(:is-symbol<gtk_search_entry_get_placeholder_text>, :returns(Str), ),
  get-search-delay => %(:is-symbol<gtk_search_entry_get_search_delay>, :returns(guint), ),
  set-input-hints => %(:is-symbol<gtk_search_entry_set_input_hints>, :parameters([GFlag]), ),
  set-input-purpose => %(:is-symbol<gtk_search_entry_set_input_purpose>, :parameters([GEnum]), ),
  set-key-capture-widget => %(:is-symbol<gtk_search_entry_set_key_capture_widget>, :parameters([N-Object]), ),
  set-placeholder-text => %(:is-symbol<gtk_search_entry_set_placeholder_text>, :parameters([Str]), ),
  set-search-delay => %(:is-symbol<gtk_search_entry_set_search_delay>, :parameters([guint]), ),
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
    $r = self._do_gtk_editable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_editable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
