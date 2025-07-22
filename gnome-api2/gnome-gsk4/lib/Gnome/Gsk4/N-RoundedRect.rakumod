=comment Package: Gsk4, C-Source: roundedrect
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-rect:api<2>;
use Gnome::Graphene::T-size:api<2>;
use Gnome::Gsk4::T-roundedrect:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::N-RoundedRect:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gsk4::RoundedRect' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskRoundedRect');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  contains-point => %(:is-symbol<gsk_rounded_rect_contains_point>, :returns(gboolean), :parameters([N-Object]), ),
  contains-rect => %(:is-symbol<gsk_rounded_rect_contains_rect>, :returns(gboolean), :parameters([N-Object]), ),
  init => %(:is-symbol<gsk_rounded_rect_init>, :returns(N-Object), :parameters([N-Object, N-Object, N-Object, N-Object, N-Object]), ),
  init-copy => %(:is-symbol<gsk_rounded_rect_init_copy>, :returns(N-Object), :parameters([N-Object]), ),
  init-from-rect => %(:is-symbol<gsk_rounded_rect_init_from_rect>, :returns(N-Object), :parameters([N-Object, gfloat]), ),
  intersects-rect => %(:is-symbol<gsk_rounded_rect_intersects_rect>, :returns(gboolean), :parameters([N-Object]), ),
  is-rectilinear => %(:is-symbol<gsk_rounded_rect_is_rectilinear>, :returns(gboolean), ),
  normalize => %(:is-symbol<gsk_rounded_rect_normalize>, :returns(N-Object), ),
  offset => %(:is-symbol<gsk_rounded_rect_offset>, :returns(N-Object), :parameters([gfloat, gfloat]), ),
  shrink => %(:is-symbol<gsk_rounded_rect_shrink>, :returns(N-Object), :parameters([gfloat, gfloat, gfloat, gfloat]), ),
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
