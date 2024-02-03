=comment Package: Graphene, C-Source: graphene-config
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::T-Simd4F:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Simd4F:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gfloat $.x;
  has gfloat $.y;
  has gfloat $.z;
  has gfloat $.w;

  submethod BUILD (
    gfloat :$!x, gfloat :$!y, gfloat :$!z, gfloat :$!w, 
  ) {
  }

  method COERCE ( $no --> N-Simd4F ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Simd4F, $no)
  }
}


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

