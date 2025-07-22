=comment Package: Pango, C-Source: layout
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
use Gnome::Pango::T-direction:api<2>;
use Gnome::Pango::T-layout:api<2>;
#use Gnome::Pango::T-types:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::N-LayoutLine:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(pango-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Pango::LayoutLine' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoLayoutLine');
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

  #--[Methods]------------------------------------------------------------------
  get-extents => %(:is-symbol<pango_layout_line_get_extents>, :parameters([N-Object, N-Object]), ),
  get-height => %(:is-symbol<pango_layout_line_get_height>, :parameters([gint-ptr]), ),
  get-length => %(:is-symbol<pango_layout_line_get_length>, :returns(gint), ),
  get-pixel-extents => %(:is-symbol<pango_layout_line_get_pixel_extents>, :parameters([N-Object, N-Object]), ),
  get-resolved-direction => %(:is-symbol<pango_layout_line_get_resolved_direction>,  :returns(GEnum), :cnv-return(PangoDirection)),
  get-start-index => %(:is-symbol<pango_layout_line_get_start_index>, :returns(gint), ),
  get-x-ranges => %(:is-symbol<pango_layout_line_get_x_ranges>, :parameters([gint, gint, gint-ptr, gint-ptr]), ),
  index-to-x => %(:is-symbol<pango_layout_line_index_to_x>, :parameters([gint, gboolean, gint-ptr]), ),
  is-paragraph-start => %(:is-symbol<pango_layout_line_is_paragraph_start>, :returns(gboolean), ),
  ref => %(:is-symbol<pango_layout_line_ref>, :returns(N-Object), ),
  unref => %(:is-symbol<pango_layout_line_unref>, ),
  x-to-index => %(:is-symbol<pango_layout_line_x_to_index>, :returns(gboolean), :parameters([gint, gint-ptr, gint-ptr]), ),
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
