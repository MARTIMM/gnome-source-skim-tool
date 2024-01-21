=comment Package: Gtk4, C-Source: progressbar
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::R-Orientable:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
use Gnome::Pango::T-Layout:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ProgressBar:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;
also does Gnome::Gtk4::R-Orientable;

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
    
    # Signals from interfaces
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ProgressBar' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkProgressBar');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-progressbar => %( :type(Constructor), :is-symbol<gtk_progress_bar_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-ellipsize => %(:is-symbol<gtk_progress_bar_get_ellipsize>,  :returns(GEnum), :cnv-return(PangoEllipsizeMode)),
  get-fraction => %(:is-symbol<gtk_progress_bar_get_fraction>,  :returns(gdouble)),
  get-inverted => %(:is-symbol<gtk_progress_bar_get_inverted>,  :returns(gboolean), :cnv-return(Bool)),
  get-pulse-step => %(:is-symbol<gtk_progress_bar_get_pulse_step>,  :returns(gdouble)),
  get-show-text => %(:is-symbol<gtk_progress_bar_get_show_text>,  :returns(gboolean), :cnv-return(Bool)),
  get-text => %(:is-symbol<gtk_progress_bar_get_text>,  :returns(Str)),
  pulse => %(:is-symbol<gtk_progress_bar_pulse>, ),
  set-ellipsize => %(:is-symbol<gtk_progress_bar_set_ellipsize>,  :parameters([GEnum])),
  set-fraction => %(:is-symbol<gtk_progress_bar_set_fraction>,  :parameters([gdouble])),
  set-inverted => %(:is-symbol<gtk_progress_bar_set_inverted>,  :parameters([gboolean])),
  set-pulse-step => %(:is-symbol<gtk_progress_bar_set_pulse_step>,  :parameters([gdouble])),
  set-show-text => %(:is-symbol<gtk_progress_bar_set_show_text>,  :parameters([gboolean])),
  set-text => %(:is-symbol<gtk_progress_bar_set_text>,  :parameters([Str])),
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
    $r = self._do_gtk_orientable_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_orientable_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
