=comment Package: Pango, C-Source: layout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;
use Gnome::Pango::T-layout:api<2>;
use Gnome::Pango::T-types:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::N-LayoutIter:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Pango::LayoutIter' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoLayoutIter');
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
  at-last-line => %(:is-symbol<pango_layout_iter_at_last_line>, :returns(gboolean), ),
  copy => %(:is-symbol<pango_layout_iter_copy>, :returns(N-Object), ),
  free => %(:is-symbol<pango_layout_iter_free>, ),
  get-baseline => %(:is-symbol<pango_layout_iter_get_baseline>, :returns(gint), ),
  get-char-extents => %(:is-symbol<pango_layout_iter_get_char_extents>, :parameters([N-Object]), ),
  get-cluster-extents => %(:is-symbol<pango_layout_iter_get_cluster_extents>, :parameters([N-Object, N-Object]), ),
  get-index => %(:is-symbol<pango_layout_iter_get_index>, :returns(gint), ),
  get-layout => %(:is-symbol<pango_layout_iter_get_layout>, :returns(N-Object), ),
  get-layout-extents => %(:is-symbol<pango_layout_iter_get_layout_extents>, :parameters([N-Object, N-Object]), ),
  get-line => %(:is-symbol<pango_layout_iter_get_line>, :returns(N-Object), ),
  get-line-extents => %(:is-symbol<pango_layout_iter_get_line_extents>, :parameters([N-Object, N-Object]), ),
  get-line-readonly => %(:is-symbol<pango_layout_iter_get_line_readonly>, :returns(N-Object), ),
  get-line-yrange => %(:is-symbol<pango_layout_iter_get_line_yrange>, :parameters([gint-ptr, gint-ptr]), ),
  #get-run => %(:is-symbol<pango_layout_iter_get_run>, ),
  get-run-baseline => %(:is-symbol<pango_layout_iter_get_run_baseline>, :returns(gint), ),
  get-run-extents => %(:is-symbol<pango_layout_iter_get_run_extents>, :parameters([N-Object, N-Object]), ),
  #get-run-readonly => %(:is-symbol<pango_layout_iter_get_run_readonly>, ),
  next-char => %(:is-symbol<pango_layout_iter_next_char>, :returns(gboolean), ),
  next-cluster => %(:is-symbol<pango_layout_iter_next_cluster>, :returns(gboolean), ),
  next-line => %(:is-symbol<pango_layout_iter_next_line>, :returns(gboolean), ),
  next-run => %(:is-symbol<pango_layout_iter_next_run>, :returns(gboolean), ),
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
