# Command to generate: generate.raku -v -c -t Glib variant
use v6.d;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Glib::T-Variant:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GVariantParseError is export <
  G_VARIANT_PARSE_ERROR_FAILED G_VARIANT_PARSE_ERROR_BASIC_TYPE_EXPECTED G_VARIANT_PARSE_ERROR_CANNOT_INFER_TYPE G_VARIANT_PARSE_ERROR_DEFINITE_TYPE_EXPECTED G_VARIANT_PARSE_ERROR_INPUT_NOT_AT_END G_VARIANT_PARSE_ERROR_INVALID_CHARACTER G_VARIANT_PARSE_ERROR_INVALID_FORMAT_STRING G_VARIANT_PARSE_ERROR_INVALID_OBJECT_PATH G_VARIANT_PARSE_ERROR_INVALID_SIGNATURE G_VARIANT_PARSE_ERROR_INVALID_TYPE_STRING G_VARIANT_PARSE_ERROR_NO_COMMON_TYPE G_VARIANT_PARSE_ERROR_NUMBER_OUT_OF_RANGE G_VARIANT_PARSE_ERROR_NUMBER_TOO_BIG G_VARIANT_PARSE_ERROR_TYPE_ERROR G_VARIANT_PARSE_ERROR_UNEXPECTED_TOKEN G_VARIANT_PARSE_ERROR_UNKNOWN_KEYWORD G_VARIANT_PARSE_ERROR_UNTERMINATED_STRING_CONSTANT G_VARIANT_PARSE_ERROR_VALUE_EXPECTED G_VARIANT_PARSE_ERROR_RECURSION 
>;


