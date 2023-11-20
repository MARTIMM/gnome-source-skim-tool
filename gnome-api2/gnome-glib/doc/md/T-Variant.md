Project Description
-------------------

  * **Distribution:** Gnome::Glib

  * **Project description:** Modules for package Gnome::Glib:api<2>. The language binding to GNOME's lowest level library

  * **Project version:** 0.1.5

  * **Rakudo version:** 6.d, 2023.10.67.g.688.b.625.ac

  * **Author:** Marcel Timmerman

Enumerations
============

GVariantParseError
------------------

Error codes returned by parsing text-format GVariants.=item `G_VARIANT_PARSE_ERROR_FAILED`; generic error (unused)

  * `G_VARIANT_PARSE_ERROR_BASIC_TYPE_EXPECTED`; a non-basic GVariantType was given where a basic type was expected

  * `G_VARIANT_PARSE_ERROR_CANNOT_INFER_TYPE`; cannot infer the GVariantType

  * `G_VARIANT_PARSE_ERROR_DEFINITE_TYPE_EXPECTED`; an indefinite GVariantType was given where a definite type was expected

  * `G_VARIANT_PARSE_ERROR_INPUT_NOT_AT_END`; extra data after parsing finished

  * `G_VARIANT_PARSE_ERROR_INVALID_CHARACTER`; invalid character in number or unicode escape

  * `G_VARIANT_PARSE_ERROR_INVALID_FORMAT_STRING`; not a valid GVariant format string

  * `G_VARIANT_PARSE_ERROR_INVALID_OBJECT_PATH`; not a valid object path

  * `G_VARIANT_PARSE_ERROR_INVALID_SIGNATURE`; not a valid type signature

  * `G_VARIANT_PARSE_ERROR_INVALID_TYPE_STRING`; not a valid GVariant type string

  * `G_VARIANT_PARSE_ERROR_NO_COMMON_TYPE`; could not find a common type for array entries

  * `G_VARIANT_PARSE_ERROR_NUMBER_OUT_OF_RANGE`; the numerical value is out of range of the given type

  * `G_VARIANT_PARSE_ERROR_NUMBER_TOO_BIG`; the numerical value is out of range for any type

  * `G_VARIANT_PARSE_ERROR_TYPE_ERROR`; cannot parse as variant of the specified type

  * `G_VARIANT_PARSE_ERROR_UNEXPECTED_TOKEN`; an unexpected token was encountered

  * `G_VARIANT_PARSE_ERROR_UNKNOWN_KEYWORD`; an unknown keyword was encountered

  * `G_VARIANT_PARSE_ERROR_UNTERMINATED_STRING_CONSTANT`; unterminated string constant

  * `G_VARIANT_PARSE_ERROR_VALUE_EXPECTED`; no value given

  * `G_VARIANT_PARSE_ERROR_RECURSION`; variant was too deeply nested; GVariant is only guaranteed to handle nesting up to 64 levels (Since: 2.64)
