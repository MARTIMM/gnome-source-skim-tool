=comment Package: Gtk4, C-Source: infobar
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::InfoBar:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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

  Gnome::N::deprecate(
    'Gnome::Gtk4::InfoBar', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<close>,
      :w1<response>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::InfoBar' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkInfoBar');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-infobar => %( :type(Constructor), :is-symbol<gtk_info_bar_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  new-with-buttons => %( :type(Constructor), :is-symbol<gtk_info_bar_new_with_buttons>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :variable-list, :parameters([ Str]), ),

  #--[Methods]------------------------------------------------------------------
  add-action-widget => %(:is-symbol<gtk_info_bar_add_action_widget>, :parameters([N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  add-button => %(:is-symbol<gtk_info_bar_add_button>, :returns(N-Object), :parameters([Str, gint]), :deprecated, :deprecated-version<4.10>, ),
  add-buttons => %(:is-symbol<gtk_info_bar_add_buttons>, :variable-list, :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  add-child => %(:is-symbol<gtk_info_bar_add_child>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-message-type => %(:is-symbol<gtk_info_bar_get_message_type>,  :returns(GEnum), :cnv-return(GtkMessageType),:deprecated, :deprecated-version<4.10>, ),
  get-revealed => %(:is-symbol<gtk_info_bar_get_revealed>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  get-show-close-button => %(:is-symbol<gtk_info_bar_get_show_close_button>, :returns(gboolean), :cnv-return(Bool), :deprecated, :deprecated-version<4.10>, ),
  remove-action-widget => %(:is-symbol<gtk_info_bar_remove_action_widget>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  remove-child => %(:is-symbol<gtk_info_bar_remove_child>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  response => %(:is-symbol<gtk_info_bar_response>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-default-response => %(:is-symbol<gtk_info_bar_set_default_response>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-message-type => %(:is-symbol<gtk_info_bar_set_message_type>, :parameters([GEnum]), :deprecated, :deprecated-version<4.10>, ),
  set-response-sensitive => %(:is-symbol<gtk_info_bar_set_response_sensitive>, :parameters([gint, gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-revealed => %(:is-symbol<gtk_info_bar_set_revealed>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-show-close-button => %(:is-symbol<gtk_info_bar_set_show_close_button>, :parameters([gboolean]), :deprecated, :deprecated-version<4.10>, ),
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
