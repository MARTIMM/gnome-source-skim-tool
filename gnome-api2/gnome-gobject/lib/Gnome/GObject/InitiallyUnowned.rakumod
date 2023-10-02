# Command to generate: gnome-source-skim-tool.raku -c -v GObject object
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GObject::InitiallyUnowned:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

