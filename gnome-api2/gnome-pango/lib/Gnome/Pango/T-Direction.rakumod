# Command to generate: generate.raku -v -d -c Pango direction
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::T-Direction:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum PangoDirection is export <
  PANGO_DIRECTION_LTR PANGO_DIRECTION_RTL PANGO_DIRECTION_TTB_LTR PANGO_DIRECTION_TTB_RTL PANGO_DIRECTION_WEAK_LTR PANGO_DIRECTION_WEAK_RTL PANGO_DIRECTION_NEUTRAL 
>;

