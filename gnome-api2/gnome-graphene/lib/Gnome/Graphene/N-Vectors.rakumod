=comment Package: Graphene, C-Source: graphene-vec*. Needed to extract structs

use v6.d;
use NativeCall;

use Gnome::Graphene::N-Simd4F:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::N-Vectors:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Record Structures]----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Vec2:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Simd4F $.value;

  submethod BUILD (
    N-Simd4F :$!value, 
  ) {
  }

  method COERCE ( $no --> N-Vec2 ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Vec2, $no)
  }
}

#-------------------------------------------------------------------------------
class N-Vec3:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Simd4F $.value;

  submethod BUILD (
    N-Simd4F :$!value, 
  ) {
  }

  method COERCE ( $no --> N-Vec3 ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Vec3, $no)
  }
}

#-------------------------------------------------------------------------------
class N-Vec4:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Simd4F $.value;

  submethod BUILD (
    N-Simd4F :$!value, 
  ) {
  }

  method COERCE ( $no --> N-Vec4 ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Vec4, $no)
  }
}
