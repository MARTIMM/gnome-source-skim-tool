=comment Package: Gtk4, C-Source: scrolledwindow
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-scrolledwindow:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ScrolledWindow:auth<github:MARTIMM>:api<2>;
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
      :w1<move-focus-out edge-overshot edge-reached>,
      :w2<scroll-child>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ScrolledWindow' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkScrolledWindow');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-scrolledwindow => %( :type(Constructor), :is-symbol<gtk_scrolled_window_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-child => %(:is-symbol<gtk_scrolled_window_get_child>,  :returns(N-Object)),
  get-hadjustment => %(:is-symbol<gtk_scrolled_window_get_hadjustment>,  :returns(N-Object)),
  get-has-frame => %(:is-symbol<gtk_scrolled_window_get_has_frame>,  :returns(gboolean), :cnv-return(Bool)),
  get-hscrollbar => %(:is-symbol<gtk_scrolled_window_get_hscrollbar>,  :returns(N-Object)),
  get-kinetic-scrolling => %(:is-symbol<gtk_scrolled_window_get_kinetic_scrolling>,  :returns(gboolean), :cnv-return(Bool)),
  get-max-content-height => %(:is-symbol<gtk_scrolled_window_get_max_content_height>,  :returns(gint)),
  get-max-content-width => %(:is-symbol<gtk_scrolled_window_get_max_content_width>,  :returns(gint)),
  get-min-content-height => %(:is-symbol<gtk_scrolled_window_get_min_content_height>,  :returns(gint)),
  get-min-content-width => %(:is-symbol<gtk_scrolled_window_get_min_content_width>,  :returns(gint)),
  get-overlay-scrolling => %(:is-symbol<gtk_scrolled_window_get_overlay_scrolling>,  :returns(gboolean), :cnv-return(Bool)),
  get-placement => %(:is-symbol<gtk_scrolled_window_get_placement>,  :returns(GEnum), :cnv-return(GtkCornerType)),
  get-policy => %(:is-symbol<gtk_scrolled_window_get_policy>,  :parameters([GEnum, GEnum])),
  get-propagate-natural-height => %(:is-symbol<gtk_scrolled_window_get_propagate_natural_height>,  :returns(gboolean), :cnv-return(Bool)),
  get-propagate-natural-width => %(:is-symbol<gtk_scrolled_window_get_propagate_natural_width>,  :returns(gboolean), :cnv-return(Bool)),
  get-vadjustment => %(:is-symbol<gtk_scrolled_window_get_vadjustment>,  :returns(N-Object)),
  get-vscrollbar => %(:is-symbol<gtk_scrolled_window_get_vscrollbar>,  :returns(N-Object)),
  set-child => %(:is-symbol<gtk_scrolled_window_set_child>,  :parameters([N-Object])),
  set-hadjustment => %(:is-symbol<gtk_scrolled_window_set_hadjustment>,  :parameters([N-Object])),
  set-has-frame => %(:is-symbol<gtk_scrolled_window_set_has_frame>,  :parameters([gboolean])),
  set-kinetic-scrolling => %(:is-symbol<gtk_scrolled_window_set_kinetic_scrolling>,  :parameters([gboolean])),
  set-max-content-height => %(:is-symbol<gtk_scrolled_window_set_max_content_height>,  :parameters([gint])),
  set-max-content-width => %(:is-symbol<gtk_scrolled_window_set_max_content_width>,  :parameters([gint])),
  set-min-content-height => %(:is-symbol<gtk_scrolled_window_set_min_content_height>,  :parameters([gint])),
  set-min-content-width => %(:is-symbol<gtk_scrolled_window_set_min_content_width>,  :parameters([gint])),
  set-overlay-scrolling => %(:is-symbol<gtk_scrolled_window_set_overlay_scrolling>,  :parameters([gboolean])),
  set-placement => %(:is-symbol<gtk_scrolled_window_set_placement>,  :parameters([GEnum])),
  set-policy => %(:is-symbol<gtk_scrolled_window_set_policy>,  :parameters([GEnum, GEnum])),
  set-propagate-natural-height => %(:is-symbol<gtk_scrolled_window_set_propagate_natural_height>,  :parameters([gboolean])),
  set-propagate-natural-width => %(:is-symbol<gtk_scrolled_window_set_propagate_natural_width>,  :parameters([gboolean])),
  set-vadjustment => %(:is-symbol<gtk_scrolled_window_set_vadjustment>,  :parameters([N-Object])),
  unset-placement => %(:is-symbol<gtk_scrolled_window_unset_placement>, ),
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
