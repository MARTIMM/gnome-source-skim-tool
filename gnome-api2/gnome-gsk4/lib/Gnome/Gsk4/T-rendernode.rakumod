=comment Package: Gsk4, C-Source: rendernode
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::T-value:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::T-rendernode:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gtk4-lib()));
}

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-ColorStop:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gfloat $.offset;
  has N-Object $.color;

  submethod BUILD ( Num() :$!offset ) {
  }

  submethod TWEAK (
    N-Object :$color, 
  ) {
    $!color := $color if ?$color;
}

  method COERCE ( $no --> N-ColorStop ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-ColorStop, $no)
  }
}


class N-Shadow:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has N-Object $.color;
  has gfloat $.dx;
  has gfloat $.dy;
  has gfloat $.radius;

  submethod BUILD (
    gfloat :$!dx, gfloat :$!dy, gfloat :$!radius, 
  ) {
  }

  submethod TWEAK (
    N-Object :$color, 
  ) {
    $!color := $color if ?$color;
}

  method COERCE ( $no --> N-Shadow ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-Shadow, $no)
  }
}


class N-ParseLocation:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gsize $.bytes;
  has gsize $.chars;
  has gsize $.lines;
  has gsize $.line-bytes;
  has gsize $.line-chars;

  submethod BUILD (
    gsize :$!bytes, gsize :$!chars, gsize :$!lines, gsize :$!line-bytes, gsize :$!line-chars, 
  ) {
  }

  method COERCE ( $no --> N-ParseLocation ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-ParseLocation, $no)
  }
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  value-dup-render-node => %( :type(Function), :is-symbol<gsk_value_dup_render_node>, :returns(N-Object), :parameters([N-Object]), ),
  value-get-render-node => %( :type(Function), :is-symbol<gsk_value_get_render_node>, :returns(N-Object), :parameters([N-Object]), ),
  value-set-render-node => %( :type(Function), :is-symbol<gsk_value_set_render_node>, :parameters([ N-Object, N-Object]), ),
  value-take-render-node => %( :type(Function), :is-symbol<gsk_value_take_render_node>, :parameters([ N-Object, N-Object]), ),

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
