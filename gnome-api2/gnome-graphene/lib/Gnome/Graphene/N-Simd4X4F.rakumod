=comment Package: Graphene, C-Source: graphene-config
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Graphene::N-Simd4F:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::N-Simd4X4F:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Simd4X4F:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Simd4F $.x;
  has N-Simd4F $.y;
  has N-Simd4F $.z;
  has N-Simd4F $.w;

  submethod BUILD (
    N-Simd4F :$!x, N-Simd4F :$!y, N-Simd4F :$!z, N-Simd4F :$!w, 
  ) {
  }

  method COERCE ( $no --> N-Simd4X4F ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Simd4X4F, $no)
  }
}

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
  $!routine-caller .= new(:library(graphene-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Graphene::Simd4x4f' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('graphene_simd4x4f_t');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}
