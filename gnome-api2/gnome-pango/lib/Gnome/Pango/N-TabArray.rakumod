=comment Package: Pango, C-Source: tabs
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
use Gnome::N::X:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::N-TabArray:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[Record Structure]-----------------------------------------------------------
#-------------------------------------------------------------------------------

# This is an opaque type of which fields are not available.
class N-TabArray:auth<github:MARTIMM>:api<2> is export is repr('CPointer') { }

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
  $!routine-caller .= new(:library(pango-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Pango::TabArray' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoTabArray');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-tabarray => %( :type(Constructor), :is-symbol<pango_tab_array_new>, :returns(N-TabArray), :parameters([ gint, gboolean])),
  new-with-positions => %( :type(Constructor), :is-symbol<pango_tab_array_new_with_positions>, :returns(N-TabArray), :variable-list, :parameters([ gint, gboolean, GEnum, gint])),

  #--[Methods]------------------------------------------------------------------
  copy => %(:is-symbol<pango_tab_array_copy>,  :returns(N-TabArray)),
  free => %(:is-symbol<pango_tab_array_free>, ),
  get-decimal-point => %(:is-symbol<pango_tab_array_get_decimal_point>,  :returns(gunichar), :parameters([gint])),
  get-positions-in-pixels => %(:is-symbol<pango_tab_array_get_positions_in_pixels>,  :returns(gboolean), :cnv-return(Bool)),
  get-size => %(:is-symbol<pango_tab_array_get_size>,  :returns(gint)),
  get-tab => %(:is-symbol<pango_tab_array_get_tab>,  :parameters([gint, GEnum, gint-ptr])),
  get-tabs => %(:is-symbol<pango_tab_array_get_tabs>,  :parameters([GEnum, gint-ptr])),
  resize => %(:is-symbol<pango_tab_array_resize>,  :parameters([gint])),
  set-decimal-point => %(:is-symbol<pango_tab_array_set_decimal_point>,  :parameters([gint, gunichar])),
  set-positions-in-pixels => %(:is-symbol<pango_tab_array_set_positions_in_pixels>,  :parameters([gboolean])),
  set-tab => %(:is-symbol<pango_tab_array_set_tab>,  :parameters([gint, GEnum, gint])),
  sort => %(:is-symbol<pango_tab_array_sort>, ),
  to-string => %(:is-symbol<pango_tab_array_to_string>,  :returns(Str)),

  #--[Functions]----------------------------------------------------------------
  from-string => %( :type(Function), :is-symbol<pango_tab_array_from_string>,  :returns(N-TabArray), :parameters([Str])),
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
        :library(pango-lib())
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
