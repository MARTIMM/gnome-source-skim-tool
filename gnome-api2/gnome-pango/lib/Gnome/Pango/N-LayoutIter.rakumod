# Command to generate: generate.raku -c -t Pango Layout
use v6.d;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
unit class N-LayoutIter is export is repr('CPointer');

