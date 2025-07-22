=comment Package: Gtk4, C-Source: centerlayout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::LayoutManager:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::CenterLayout:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gtk4::CenterLayout' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCenterLayout');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-centerlayout => %( :type(Constructor), :is-symbol<gtk_center_layout_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-baseline-position => %(:is-symbol<gtk_center_layout_get_baseline_position>,  :returns(GEnum), :cnv-return(GtkBaselinePosition)),
  get-center-widget => %(:is-symbol<gtk_center_layout_get_center_widget>, :returns(N-Object), ),
  get-end-widget => %(:is-symbol<gtk_center_layout_get_end_widget>, :returns(N-Object), ),
  get-orientation => %(:is-symbol<gtk_center_layout_get_orientation>,  :returns(GEnum), :cnv-return(GtkOrientation)),
  get-shrink-center-last => %(:is-symbol<gtk_center_layout_get_shrink_center_last>, :returns(gboolean), :cnv-return(Bool), ),
  get-start-widget => %(:is-symbol<gtk_center_layout_get_start_widget>, :returns(N-Object), ),
  set-baseline-position => %(:is-symbol<gtk_center_layout_set_baseline_position>, :parameters([GEnum]), ),
  set-center-widget => %(:is-symbol<gtk_center_layout_set_center_widget>, :parameters([N-Object]), ),
  set-end-widget => %(:is-symbol<gtk_center_layout_set_end_widget>, :parameters([N-Object]), ),
  set-orientation => %(:is-symbol<gtk_center_layout_set_orientation>, :parameters([GEnum]), ),
  set-shrink-center-last => %(:is-symbol<gtk_center_layout_set_shrink_center_last>, :parameters([gboolean]), ),
  set-start-widget => %(:is-symbol<gtk_center_layout_set_start_widget>, :parameters([N-Object]), ),
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
