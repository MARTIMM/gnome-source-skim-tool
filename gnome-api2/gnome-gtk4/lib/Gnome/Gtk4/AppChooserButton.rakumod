=comment Package: Gtk4, C-Source: appchooserbutton
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::R-AppChooser:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::AppChooserButton:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-AppChooser;

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
      :w0<changed activate>,
      :w1<custom-item-activated>,
    );

    # Signals from interfaces
    self._add_gtk_app_chooser_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_app_chooser_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::AppChooserButton' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAppChooserButton');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-appchooserbutton => %( :type(Constructor), :is-symbol<gtk_app_chooser_button_new>, :returns(N-Object), :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  append-custom-item => %(:is-symbol<gtk_app_chooser_button_append_custom_item>,  :parameters([Str, Str, N-Object])),
  append-separator => %(:is-symbol<gtk_app_chooser_button_append_separator>, ),
  get-heading => %(:is-symbol<gtk_app_chooser_button_get_heading>,  :returns(Str)),
  get-modal => %(:is-symbol<gtk_app_chooser_button_get_modal>,  :returns(gboolean), :cnv-return(Bool)),
  get-show-default-item => %(:is-symbol<gtk_app_chooser_button_get_show_default_item>,  :returns(gboolean), :cnv-return(Bool)),
  get-show-dialog-item => %(:is-symbol<gtk_app_chooser_button_get_show_dialog_item>,  :returns(gboolean), :cnv-return(Bool)),
  set-active-custom-item => %(:is-symbol<gtk_app_chooser_button_set_active_custom_item>,  :parameters([Str])),
  set-heading => %(:is-symbol<gtk_app_chooser_button_set_heading>,  :parameters([Str])),
  set-modal => %(:is-symbol<gtk_app_chooser_button_set_modal>,  :parameters([gboolean])),
  set-show-default-item => %(:is-symbol<gtk_app_chooser_button_set_show_default_item>,  :parameters([gboolean])),
  set-show-dialog-item => %(:is-symbol<gtk_app_chooser_button_set_show_dialog_item>,  :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
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
    $r = self.Gnome::Gtk4::R-AppChooser::_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    );
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
