=comment Package: Gtk4, C-Source: scalebutton
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ScaleButton:auth<github:MARTIMM>:api<2>;
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

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<popup popdown>,
      :w1<value-changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ScaleButton' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkScaleButton');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-scalebutton => %( :type(Constructor), :is-symbol<gtk_scale_button_new>, :returns(N-Object), :parameters([ gdouble, gdouble, gdouble, gchar-pptr])),

  #--[Methods]------------------------------------------------------------------
  get-active => %(:is-symbol<gtk_scale_button_get_active>,  :returns(gboolean), :cnv-return(Bool)),
  get-adjustment => %(:is-symbol<gtk_scale_button_get_adjustment>,  :returns(N-Object)),
  get-minus-button => %(:is-symbol<gtk_scale_button_get_minus_button>,  :returns(N-Object)),
  get-plus-button => %(:is-symbol<gtk_scale_button_get_plus_button>,  :returns(N-Object)),
  get-popup => %(:is-symbol<gtk_scale_button_get_popup>,  :returns(N-Object)),
  get-value => %(:is-symbol<gtk_scale_button_get_value>,  :returns(gdouble)),
  set-adjustment => %(:is-symbol<gtk_scale_button_set_adjustment>,  :parameters([N-Object])),
  set-icons => %(:is-symbol<gtk_scale_button_set_icons>,  :parameters([gchar-pptr])),
  set-value => %(:is-symbol<gtk_scale_button_set_value>,  :parameters([gdouble])),
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
