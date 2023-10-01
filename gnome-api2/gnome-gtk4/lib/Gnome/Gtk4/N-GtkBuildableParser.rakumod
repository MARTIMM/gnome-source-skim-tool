# Command to generate: generate.raku -c -t Gtk4 buildable
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class N-GtkBuildableParser:auth<github:MARTIMM>:api<2> is export is repr('CStruct');

  has gpointer $.start-element;
  has gpointer $.end-element;
  has gpointer $.text;
  has gpointer $.error;
has gchar-pptr $.padding;

submethod BUILD (
  gpointer :$!start-element, gpointer :$!end-element, gpointer :$!text, gpointer :$!error, gchar-pptr :$!padding, 
) {
}

method COERCE ( $no --> N-GtkBuildableParser ) {
  note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
  nativecast( N-GtkBuildableParser, $no)
}
