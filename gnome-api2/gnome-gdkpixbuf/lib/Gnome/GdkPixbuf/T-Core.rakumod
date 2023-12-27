=comment Package: GdkPixbuf, C-Source: gdk-pixbuf-core
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GdkPixbuf::T-Core:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GdkColorspace is export <
  GDK_COLORSPACE_RGB 
>;

enum GdkPixbufAlphaMode is export <
  GDK_PIXBUF_ALPHA_BILEVEL GDK_PIXBUF_ALPHA_FULL 
>;

enum GdkPixbufError is export <
  GDK_PIXBUF_ERROR_CORRUPT_IMAGE GDK_PIXBUF_ERROR_INSUFFICIENT_MEMORY GDK_PIXBUF_ERROR_BAD_OPTION GDK_PIXBUF_ERROR_UNKNOWN_TYPE GDK_PIXBUF_ERROR_UNSUPPORTED_OPERATION GDK_PIXBUF_ERROR_FAILED GDK_PIXBUF_ERROR_INCOMPLETE_ANIMATION 
>;

