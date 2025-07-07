=comment Package: Gtk4, C-Source: revealer
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::T-revealer:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Revealer:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
  if self.^name eq 'Gnome::Gtk4::Revealer' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkRevealer');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-revealer => %( :type(Constructor), :is-symbol<gtk_revealer_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-child => %(:is-symbol<gtk_revealer_get_child>, :returns(N-Object), ),
  get-child-revealed => %(:is-symbol<gtk_revealer_get_child_revealed>, :returns(gboolean), ),
  get-reveal-child => %(:is-symbol<gtk_revealer_get_reveal_child>, :returns(gboolean), ),
  get-transition-duration => %(:is-symbol<gtk_revealer_get_transition_duration>, :returns(guint), ),
  get-transition-type => %(:is-symbol<gtk_revealer_get_transition_type>,  :returns(GEnum), :cnv-return(GtkRevealerTransitionType)),
  set-child => %(:is-symbol<gtk_revealer_set_child>, :parameters([N-Object]), ),
  set-reveal-child => %(:is-symbol<gtk_revealer_set_reveal_child>, :parameters([gboolean]), ),
  set-transition-duration => %(:is-symbol<gtk_revealer_set_transition_duration>, :parameters([guint]), ),
  set-transition-type => %(:is-symbol<gtk_revealer_set_transition_type>, :parameters([GEnum]), ),
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
