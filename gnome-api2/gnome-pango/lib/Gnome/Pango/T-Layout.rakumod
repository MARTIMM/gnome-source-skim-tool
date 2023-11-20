# Command to generate: generate.raku -v -d -c Pango layout
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::T-Layout:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum PangoAlignment is export <
  PANGO_ALIGN_LEFT PANGO_ALIGN_CENTER PANGO_ALIGN_RIGHT 
>;

enum PangoEllipsizeMode is export <
  PANGO_ELLIPSIZE_NONE PANGO_ELLIPSIZE_START PANGO_ELLIPSIZE_MIDDLE PANGO_ELLIPSIZE_END 
>;

enum PangoLayoutDeserializeError is export <
  PANGO_LAYOUT_DESERIALIZE_INVALID PANGO_LAYOUT_DESERIALIZE_INVALID_VALUE PANGO_LAYOUT_DESERIALIZE_MISSING_VALUE 
>;

enum PangoWrapMode is export <
  PANGO_WRAP_WORD PANGO_WRAP_CHAR PANGO_WRAP_WORD_CHAR 
>;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum PangoLayoutDeserializeFlags is export (
  :PANGO_LAYOUT_DESERIALIZE_DEFAULT(0), :PANGO_LAYOUT_DESERIALIZE_CONTEXT(1)
);

enum PangoLayoutSerializeFlags is export (
  :PANGO_LAYOUT_SERIALIZE_DEFAULT(0), :PANGO_LAYOUT_SERIALIZE_CONTEXT(1), :PANGO_LAYOUT_SERIALIZE_OUTPUT(2)
);

