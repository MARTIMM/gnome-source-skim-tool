=comment Package: Gtk4, C-Source: scale
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::Range:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Scale:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Range;

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
  if self.^name eq 'Gnome::Gtk4::Scale' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkScale');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-scale => %( :type(Constructor), :is-symbol<gtk_scale_new>, :returns(N-Object), :parameters([ GEnum, N-Object]), ),
  new-with-range => %( :type(Constructor), :is-symbol<gtk_scale_new_with_range>, :returns(N-Object), :parameters([ GEnum, gdouble, gdouble, gdouble]), ),

  #--[Methods]------------------------------------------------------------------
  add-mark => %(:is-symbol<gtk_scale_add_mark>, :parameters([gdouble, GEnum, Str]), ),
  clear-marks => %(:is-symbol<gtk_scale_clear_marks>, ),
  get-digits => %(:is-symbol<gtk_scale_get_digits>, :returns(gint), ),
  get-draw-value => %(:is-symbol<gtk_scale_get_draw_value>, :returns(gboolean), :cnv-return(Bool), ),
  get-has-origin => %(:is-symbol<gtk_scale_get_has_origin>, :returns(gboolean), :cnv-return(Bool), ),
  get-layout => %(:is-symbol<gtk_scale_get_layout>, :returns(N-Object), ),
  get-layout-offsets => %(:is-symbol<gtk_scale_get_layout_offsets>, :parameters([gint-ptr, gint-ptr]), ),
  get-value-pos => %(:is-symbol<gtk_scale_get_value_pos>,  :returns(GEnum), :cnv-return(GtkPositionType)),
  set-digits => %(:is-symbol<gtk_scale_set_digits>, :parameters([gint]), ),
  set-draw-value => %(:is-symbol<gtk_scale_set_draw_value>, :parameters([gboolean]), ),
  set-format-value-func => %(:is-symbol<gtk_scale_set_format_value_func>, :parameters([:( N-Object $scale, gdouble $value, gpointer $user-data ), gpointer, :( gpointer $data )]), ),
  set-has-origin => %(:is-symbol<gtk_scale_set_has_origin>, :parameters([gboolean]), ),
  set-value-pos => %(:is-symbol<gtk_scale_set_value_pos>, :parameters([GEnum]), ),
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
