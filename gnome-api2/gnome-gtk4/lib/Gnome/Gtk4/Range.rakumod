=comment Package: Gtk4, C-Source: range
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gdk4::N-Rectangle:api<2>;
use Gnome::Gtk4::R-Orientable:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Range:auth<github:MARTIMM>:api<2>;
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
      :w0<value-changed>,
      :w1<move-slider adjust-bounds>,
      :w2<change-value>,
    );

    # Signals from interfaces
    self._add_gtk_orientable_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_orientable_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Range' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkRange');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  get-adjustment => %(:is-symbol<gtk_range_get_adjustment>,  :returns(N-Object)),
  get-fill-level => %(:is-symbol<gtk_range_get_fill_level>,  :returns(gdouble)),
  get-flippable => %(:is-symbol<gtk_range_get_flippable>,  :returns(gboolean), :cnv-return(Bool)),
  get-inverted => %(:is-symbol<gtk_range_get_inverted>,  :returns(gboolean), :cnv-return(Bool)),
  get-range-rect => %(:is-symbol<gtk_range_get_range_rect>,  :parameters([N-Rectangle])),
  get-restrict-to-fill-level => %(:is-symbol<gtk_range_get_restrict_to_fill_level>,  :returns(gboolean), :cnv-return(Bool)),
  get-round-digits => %(:is-symbol<gtk_range_get_round_digits>,  :returns(gint)),
  get-show-fill-level => %(:is-symbol<gtk_range_get_show_fill_level>,  :returns(gboolean), :cnv-return(Bool)),
  get-slider-range => %(:is-symbol<gtk_range_get_slider_range>,  :parameters([gint-ptr, gint-ptr])),
  get-slider-size-fixed => %(:is-symbol<gtk_range_get_slider_size_fixed>,  :returns(gboolean), :cnv-return(Bool)),
  get-value => %(:is-symbol<gtk_range_get_value>,  :returns(gdouble)),
  set-adjustment => %(:is-symbol<gtk_range_set_adjustment>,  :parameters([N-Object])),
  set-fill-level => %(:is-symbol<gtk_range_set_fill_level>,  :parameters([gdouble])),
  set-flippable => %(:is-symbol<gtk_range_set_flippable>,  :parameters([gboolean])),
  set-increments => %(:is-symbol<gtk_range_set_increments>,  :parameters([gdouble, gdouble])),
  set-inverted => %(:is-symbol<gtk_range_set_inverted>,  :parameters([gboolean])),
  set-range => %(:is-symbol<gtk_range_set_range>,  :parameters([gdouble, gdouble])),
  set-restrict-to-fill-level => %(:is-symbol<gtk_range_set_restrict_to_fill_level>,  :parameters([gboolean])),
  set-round-digits => %(:is-symbol<gtk_range_set_round_digits>,  :parameters([gint])),
  set-show-fill-level => %(:is-symbol<gtk_range_set_show_fill_level>,  :parameters([gboolean])),
  set-slider-size-fixed => %(:is-symbol<gtk_range_set_slider_size_fixed>,  :parameters([gboolean])),
  set-value => %(:is-symbol<gtk_range_set_value>,  :parameters([gdouble])),
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
