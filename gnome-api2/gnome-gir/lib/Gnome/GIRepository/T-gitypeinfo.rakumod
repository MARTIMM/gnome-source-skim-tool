=comment Package: GIRepo, C-Source: gitypeinfo
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



#use Gnome::GIRepo::BaseInfo:api<2>;
#use Gnome::GIRepository::T-Argument:api<2>;
#use Gnome::GIRepository::T-gitypeinfo:api<2>;
#use Gnome::GIRepository::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::T-gitypeinfo:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(girepository-2.0));
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  #type-tag-argument-from-hash-pointer => %( :type(Function), :is-symbol<gi_type_tag_argument_from_hash_pointer>, :parameters([ GITypeTag , void-ptr, N-Object]), ),
  #type-tag-hash-pointer-from-argument => %( :type(Function), :is-symbol<gi_type_tag_hash_pointer_from_argument>, :returns(void-ptr), :parameters([ GITypeTag , N-Object]), ),
  #type-tag-to-string => %( :type(Function), :is-symbol<gi_type_tag_to_string>, :returns(Str), :parameters([GITypeTag ]), ),

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
