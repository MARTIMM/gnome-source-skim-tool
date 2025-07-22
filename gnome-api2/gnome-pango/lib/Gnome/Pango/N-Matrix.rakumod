=comment Package: Pango, C-Source: matrix
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;
use Gnome::Pango::T-matrix:api<2>;
#use Gnome::Pango::T-types:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::N-Matrix:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

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
  $!routine-caller .= new(:library(pango-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Pango::Matrix' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoMatrix');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object --> N-Object ) {
  self._fallback-v2( 'copy', $n-native-object);
}

method native-object-unref ( $n-native-object ) {
  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  concat => %(:is-symbol<pango_matrix_concat>, :parameters([N-Object]), ),
  copy => %(:is-symbol<pango_matrix_copy>, :returns(N-Object), ),
  free => %(:is-symbol<pango_matrix_free>, ),
  get-font-scale-factor => %(:is-symbol<pango_matrix_get_font_scale_factor>, :returns(gdouble), ),
  get-font-scale-factors => %(:is-symbol<pango_matrix_get_font_scale_factors>, :parameters([CArray[gdouble], CArray[gdouble]]), ),
  get-slant-ratio => %(:is-symbol<pango_matrix_get_slant_ratio>, :returns(gdouble), ),
  rotate => %(:is-symbol<pango_matrix_rotate>, :parameters([gdouble]), ),
  scale => %(:is-symbol<pango_matrix_scale>, :parameters([gdouble, gdouble]), ),
  transform-distance => %(:is-symbol<pango_matrix_transform_distance>, :parameters([CArray[gdouble], CArray[gdouble]]), ),
  transform-pixel-rectangle => %(:is-symbol<pango_matrix_transform_pixel_rectangle>, :parameters([N-Object]), ),
  transform-point => %(:is-symbol<pango_matrix_transform_point>, :parameters([CArray[gdouble], CArray[gdouble]]), ),
  transform-rectangle => %(:is-symbol<pango_matrix_transform_rectangle>, :parameters([N-Object]), ),
  translate => %(:is-symbol<pango_matrix_translate>, :parameters([gdouble, gdouble]), ),
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
        :library(pango-lib())
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
