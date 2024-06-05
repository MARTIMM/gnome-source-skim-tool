=comment Package: Gtk4, C-Source: fontbutton
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


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

unit class Gnome::Gtk4::FontButton:auth<github:MARTIMM>:api<2>;
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
    'Gnome::Gtk4::FontButton', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<activate font-set>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::FontButton' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkFontButton');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-fontbutton => %( :type(Constructor), :is-symbol<gtk_font_button_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  new-with-font => %( :type(Constructor), :is-symbol<gtk_font_button_new_with_font>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, :parameters([ Str])),

  #--[Methods]------------------------------------------------------------------
  get-modal => %(:is-symbol<gtk_font_button_get_modal>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  get-title => %(:is-symbol<gtk_font_button_get_title>,  :returns(Str),:deprecated, :deprecated-version<4.10>, ),
  get-use-font => %(:is-symbol<gtk_font_button_get_use_font>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  get-use-size => %(:is-symbol<gtk_font_button_get_use_size>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  set-modal => %(:is-symbol<gtk_font_button_set_modal>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
  set-title => %(:is-symbol<gtk_font_button_set_title>,  :parameters([Str]),:deprecated, :deprecated-version<4.10>, ),
  set-use-font => %(:is-symbol<gtk_font_button_set_use_font>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
  set-use-size => %(:is-symbol<gtk_font_button_set_use_size>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
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
