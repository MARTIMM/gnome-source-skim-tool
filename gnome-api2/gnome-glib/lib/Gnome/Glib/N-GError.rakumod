# Command to generate: gnome-source-skim-tool.raku -c -t -v Glib error
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

class Gnome::Glib::N-GError {
  class N-GError:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

    has GQuark $.domain;
    has gint $.code;
    has Str $.message;

    submethod BUILD (
      GQuark :$!domain, gint :$!code, Str :$!message, 
    ) {
    }

    method COERCE ( $no --> N-GError ) {
      note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
      nativecast( N-GError, $no)
    }
  }
}
