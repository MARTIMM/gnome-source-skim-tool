=comment Package: Gtk4, C-Source: gridlayout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::LayoutManager:api<2>;
use Gnome::Gtk4::T-Enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::GridLayout:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::LayoutManager;

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
  if self.^name eq 'Gnome::Gtk4::GridLayout' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkGridLayout');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-gridlayout => %( :type(Constructor), :is-symbol<gtk_grid_layout_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-baseline-row => %(:is-symbol<gtk_grid_layout_get_baseline_row>,  :returns(gint)),
  get-column-homogeneous => %(:is-symbol<gtk_grid_layout_get_column_homogeneous>,  :returns(gboolean), :cnv-return(Bool)),
  get-column-spacing => %(:is-symbol<gtk_grid_layout_get_column_spacing>,  :returns(guint)),
  get-row-baseline-position => %(:is-symbol<gtk_grid_layout_get_row_baseline_position>,  :returns(GEnum), :cnv-return(GtkBaselinePosition), :parameters([gint])),
  get-row-homogeneous => %(:is-symbol<gtk_grid_layout_get_row_homogeneous>,  :returns(gboolean), :cnv-return(Bool)),
  get-row-spacing => %(:is-symbol<gtk_grid_layout_get_row_spacing>,  :returns(guint)),
  set-baseline-row => %(:is-symbol<gtk_grid_layout_set_baseline_row>,  :parameters([gint])),
  set-column-homogeneous => %(:is-symbol<gtk_grid_layout_set_column_homogeneous>,  :parameters([gboolean])),
  set-column-spacing => %(:is-symbol<gtk_grid_layout_set_column_spacing>,  :parameters([guint])),
  set-row-baseline-position => %(:is-symbol<gtk_grid_layout_set_row_baseline_position>,  :parameters([gint, GEnum])),
  set-row-homogeneous => %(:is-symbol<gtk_grid_layout_set_row_homogeneous>,  :parameters([gboolean])),
  set-row-spacing => %(:is-symbol<gtk_grid_layout_set_row_spacing>,  :parameters([guint])),
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
