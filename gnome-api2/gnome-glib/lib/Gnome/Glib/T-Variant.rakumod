# Package: Glib, C-Source: variant
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::N-VariantType:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::T-Variant:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(glib-lib()));
}

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GVariantParseError is export <
  G_VARIANT_PARSE_ERROR_FAILED G_VARIANT_PARSE_ERROR_BASIC_TYPE_EXPECTED G_VARIANT_PARSE_ERROR_CANNOT_INFER_TYPE G_VARIANT_PARSE_ERROR_DEFINITE_TYPE_EXPECTED G_VARIANT_PARSE_ERROR_INPUT_NOT_AT_END G_VARIANT_PARSE_ERROR_INVALID_CHARACTER G_VARIANT_PARSE_ERROR_INVALID_FORMAT_STRING G_VARIANT_PARSE_ERROR_INVALID_OBJECT_PATH G_VARIANT_PARSE_ERROR_INVALID_SIGNATURE G_VARIANT_PARSE_ERROR_INVALID_TYPE_STRING G_VARIANT_PARSE_ERROR_NO_COMMON_TYPE G_VARIANT_PARSE_ERROR_NUMBER_OUT_OF_RANGE G_VARIANT_PARSE_ERROR_NUMBER_TOO_BIG G_VARIANT_PARSE_ERROR_TYPE_ERROR G_VARIANT_PARSE_ERROR_UNEXPECTED_TOKEN G_VARIANT_PARSE_ERROR_UNKNOWN_KEYWORD G_VARIANT_PARSE_ERROR_UNTERMINATED_STRING_CONSTANT G_VARIANT_PARSE_ERROR_VALUE_EXPECTED G_VARIANT_PARSE_ERROR_RECURSION 
>;

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  variant-is-object-path => %( :type(Function), :is-symbol<g_variant_is_object_path>,  :returns(gboolean), :parameters([Str])),
  variant-is-signature => %( :type(Function), :is-symbol<g_variant_is_signature>,  :returns(gboolean), :parameters([Str])),
  variant-parse => %( :type(Function), :is-symbol<g_variant_parse>,  :returns(N-Variant), :parameters([ N-VariantType, Str, Str, gchar-pptr])),
  variant-parse-error-print-context => %( :type(Function), :is-symbol<g_variant_parse_error_print_context>,  :returns(Str), :parameters([ N-Error, Str])),

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
