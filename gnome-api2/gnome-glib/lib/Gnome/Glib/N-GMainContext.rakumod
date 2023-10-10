# Command to generate: generate.raku -c Glib main
use v6.d;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
unit class N-GMainContext is export is repr('CPointer');

