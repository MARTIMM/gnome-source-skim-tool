=comment Package: Gtk4, C-Source: types
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::N-Bitset:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {


  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Bitset' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkBitset');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-empty => %( :type(Constructor), :is-symbol<gtk_bitset_new_empty>, :returns(N-Object), ),
  new-range => %( :type(Constructor), :is-symbol<gtk_bitset_new_range>, :returns(N-Object), :parameters([ guint, guint]), ),

  #--[Methods]------------------------------------------------------------------
  add => %(:is-symbol<gtk_bitset_add>, :returns(gboolean), :cnv-return(Bool), :parameters([guint]), ),
  add-range => %(:is-symbol<gtk_bitset_add_range>, :parameters([guint, guint]), ),
  add-range-closed => %(:is-symbol<gtk_bitset_add_range_closed>, :parameters([guint, guint]), ),
  add-rectangle => %(:is-symbol<gtk_bitset_add_rectangle>, :parameters([guint, guint, guint, guint]), ),
  contains => %(:is-symbol<gtk_bitset_contains>, :returns(gboolean), :cnv-return(Bool), :parameters([guint]), ),
  copy => %(:is-symbol<gtk_bitset_copy>, :returns(N-Object), ),
  difference => %(:is-symbol<gtk_bitset_difference>, :parameters([N-Object]), ),
  equals => %(:is-symbol<gtk_bitset_equals>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), ),
  get-maximum => %(:is-symbol<gtk_bitset_get_maximum>, :returns(guint), ),
  get-minimum => %(:is-symbol<gtk_bitset_get_minimum>, :returns(guint), ),
  get-nth => %(:is-symbol<gtk_bitset_get_nth>, :returns(guint), :parameters([guint]), ),
  get-size => %(:is-symbol<gtk_bitset_get_size>, :returns(guint64), ),
  get-size-in-range => %(:is-symbol<gtk_bitset_get_size_in_range>, :returns(guint64), :parameters([guint, guint]), ),
  intersect => %(:is-symbol<gtk_bitset_intersect>, :parameters([N-Object]), ),
  is-empty => %(:is-symbol<gtk_bitset_is_empty>, :returns(gboolean), :cnv-return(Bool), ),
  ref => %(:is-symbol<gtk_bitset_ref>, :returns(N-Object), ),
  remove => %(:is-symbol<gtk_bitset_remove>, :returns(gboolean), :cnv-return(Bool), :parameters([guint]), ),
  remove-all => %(:is-symbol<gtk_bitset_remove_all>, ),
  remove-range => %(:is-symbol<gtk_bitset_remove_range>, :parameters([guint, guint]), ),
  remove-range-closed => %(:is-symbol<gtk_bitset_remove_range_closed>, :parameters([guint, guint]), ),
  remove-rectangle => %(:is-symbol<gtk_bitset_remove_rectangle>, :parameters([guint, guint, guint, guint]), ),
  shift-left => %(:is-symbol<gtk_bitset_shift_left>, :parameters([guint]), ),
  shift-right => %(:is-symbol<gtk_bitset_shift_right>, :parameters([guint]), ),
  splice => %(:is-symbol<gtk_bitset_splice>, :parameters([guint, guint, guint]), ),
  subtract => %(:is-symbol<gtk_bitset_subtract>, :parameters([N-Object]), ),
  union => %(:is-symbol<gtk_bitset_union>, :parameters([N-Object]), ),
  unref => %(:is-symbol<gtk_bitset_unref>, ),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 (
  Str $name, Bool $_fallback-v2-ok is rw, *@arguments, *%options
) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib())
      );

      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        ),
        |%options
      );
    }

    elsif $methods{$name}<type>:exists and $methods{$name}<type> eq 'Function' {
      return $!routine-caller.call-native-sub( $name, @arguments, $methods);
    }

    else {
      my $native-object = self.get-native-object-no-reffing;
      return $!routine-caller.call-native-sub(
        $name, @arguments, $methods, $native-object
      );
    }
  }

  else {
    callsame;
  }
}
