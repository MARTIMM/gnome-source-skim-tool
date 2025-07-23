=comment Package: Gtk4, C-Source: treemodel
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::T-treemodel:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));
}

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

class N-TreeIter:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {

  has gint $.stamp;
  has gpointer $.user-data;
  has gpointer $.user-data2;
  has gpointer $.user-data3;

  submethod BUILD (
    gint :$!stamp, gpointer :$!user-data, gpointer :$!user-data2, gpointer :$!user-data3, 
  ) {
  }

  method COERCE ( $no --> N-TreeIter ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-TreeIter, $no)
  }
}

# This is an opaque type of which fields are not available.
class N-TreeRowReference:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

# This is an opaque type of which fields are not available.
class N-TreePath:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GtkTreeModelFlags is export (
  :GTK_TREE_MODEL_ITERS_PERSIST(1), :GTK_TREE_MODEL_LIST_ONLY(2)
);

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  tree-row-reference-deleted => %( :type(Function), :is-symbol<gtk_tree_row_reference_deleted>, :parameters([ N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  tree-row-reference-inserted => %( :type(Function), :is-symbol<gtk_tree_row_reference_inserted>, :parameters([ N-Object, N-Object]), :deprecated, :deprecated-version<4.10>, ),
  tree-row-reference-reordered => %( :type(Function), :is-symbol<gtk_tree_row_reference_reordered>, :parameters([ N-Object, N-Object, N-Object, gint-ptr]), :deprecated, :deprecated-version<4.10>, ),

);
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
