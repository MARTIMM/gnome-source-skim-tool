# Command to generate: generate.raku -v -c -t Glib varianttype
use v6.d;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
unit class N-VariantType is export is repr('CPointer');

