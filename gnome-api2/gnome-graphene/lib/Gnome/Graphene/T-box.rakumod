=comment Package: Graphene, C-Source: box
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

unit class Gnome::Graphene::T-box:auth<github:MARTIMM>:api<2>;
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

class N-Box:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.min;
  has N-Object $.max;

  submethod TWEAK (
    N-Object :$min, N-Object :$max, 
  ) {
    $!min := $min if ?$min;
  $!max := $max if ?$max;
}

  method COERCE ( $no --> N-Box ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Box, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  box-empty => %( :type(Function), :is-symbol<graphene_box_empty>,  :returns(N-Object)),
  box-infinite => %( :type(Function), :is-symbol<graphene_box_infinite>,  :returns(N-Object)),
  box-minus-one => %( :type(Function), :is-symbol<graphene_box_minus_one>,  :returns(N-Object)),
  box-one => %( :type(Function), :is-symbol<graphene_box_one>,  :returns(N-Object)),
  box-one-minus-one => %( :type(Function), :is-symbol<graphene_box_one_minus_one>,  :returns(N-Object)),
  box-zero => %( :type(Function), :is-symbol<graphene_box_zero>,  :returns(N-Object)),

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
