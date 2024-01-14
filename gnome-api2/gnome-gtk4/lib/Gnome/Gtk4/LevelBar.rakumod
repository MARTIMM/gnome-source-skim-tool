=comment Package: Gtk4, C-Source: levelbar
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::R-Orientable:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::LevelBar:auth<github:MARTIMM>:api<2>;
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
    self.add-signal-types( $?CLASS.^name,
      :w1<offset-changed>,
    );

    # Signals from interfaces
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::LevelBar' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkLevelBar');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-levelbar => %( :type(Constructor), :is-symbol<gtk_level_bar_new>, :returns(N-Object), ),
  new-for-interval => %( :type(Constructor), :is-symbol<gtk_level_bar_new_for_interval>, :returns(N-Object), :parameters([ gdouble, gdouble])),

  #--[Methods]------------------------------------------------------------------
  add-offset-value => %(:is-symbol<gtk_level_bar_add_offset_value>,  :parameters([Str, gdouble])),
  get-inverted => %(:is-symbol<gtk_level_bar_get_inverted>,  :returns(gboolean), :cnv-return(Bool)),
  get-max-value => %(:is-symbol<gtk_level_bar_get_max_value>,  :returns(gdouble)),
  get-min-value => %(:is-symbol<gtk_level_bar_get_min_value>,  :returns(gdouble)),
  get-mode => %(:is-symbol<gtk_level_bar_get_mode>,  :returns(GEnum), :cnv-return(GtkLevelBarMode)),
  get-offset-value => %(:is-symbol<gtk_level_bar_get_offset_value>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, CArray[gdouble]])),
  get-value => %(:is-symbol<gtk_level_bar_get_value>,  :returns(gdouble)),
  remove-offset-value => %(:is-symbol<gtk_level_bar_remove_offset_value>,  :parameters([Str])),
  set-inverted => %(:is-symbol<gtk_level_bar_set_inverted>,  :parameters([gboolean])),
  set-max-value => %(:is-symbol<gtk_level_bar_set_max_value>,  :parameters([gdouble])),
  set-min-value => %(:is-symbol<gtk_level_bar_set_min_value>,  :parameters([gdouble])),
  set-mode => %(:is-symbol<gtk_level_bar_set_mode>,  :parameters([GEnum])),
  set-value => %(:is-symbol<gtk_level_bar_set_value>,  :parameters([gdouble])),
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
