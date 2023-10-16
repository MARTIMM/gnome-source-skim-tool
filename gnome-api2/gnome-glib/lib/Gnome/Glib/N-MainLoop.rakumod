# Command to generate: generate.raku -t -c Glib main record
use v6.d;
#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
unit class N-MainLoop is export is repr('CPointer');

