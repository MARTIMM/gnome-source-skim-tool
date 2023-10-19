# Command to generate: generate.raku -v -c -t Glib variant
use v6.d;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
unit class N-VariantDict is export is repr('CPointer');

