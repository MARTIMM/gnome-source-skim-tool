=comment Package: Graphene, C-Source: point3d
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

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Graphene::T-point3d:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new(:library(graphene-lib()));
}


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-Point3D:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gfloat $.x;
  has gfloat $.y;
  has gfloat $.z;

  submethod BUILD (
    gfloat :$!x, gfloat :$!y, gfloat :$!z, 
  ) {
  }

  method COERCE ( $no --> N-Point3D ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Point3D, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  point3d-zero => %( :type(Function), :is-symbol<graphene_point3d_zero>,  :returns(N-Point3D)),

);
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
