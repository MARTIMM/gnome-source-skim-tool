# Command to generate: generate.raku -v -d -c Pango layout
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
use Gnome::Pango::N-LayoutIter:api<2>;
use Gnome::Pango::N-LayoutLine:api<2>;
#use Gnome::Pango::N-Rectangle:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::LayoutIter:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library('libpango-1.0.so.0'));

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
  at-last-line => %(:is-symbol<pango_layout_iter_at_last_line>,  :returns(gboolean), :cnv-return(Bool)),
  copy => %(:is-symbol<pango_layout_iter_copy>,  :returns(N-LayoutIter)),
  free => %(:is-symbol<pango_layout_iter_free>, ),
  get-baseline => %(:is-symbol<pango_layout_iter_get_baseline>,  :returns(gint)),
  #get-char-extents => %(:is-symbol<pango_layout_iter_get_char_extents>,  :parameters([N-Rectangle ])),
  #get-cluster-extents => %(:is-symbol<pango_layout_iter_get_cluster_extents>,  :parameters([N-Rectangle , N-Rectangle ])),
  get-index => %(:is-symbol<pango_layout_iter_get_index>,  :returns(gint)),
  get-layout => %(:is-symbol<pango_layout_iter_get_layout>,  :returns(N-Object)),
  #get-layout-extents => %(:is-symbol<pango_layout_iter_get_layout_extents>,  :parameters([N-Rectangle , N-Rectangle ])),
  get-line => %(:is-symbol<pango_layout_iter_get_line>,  :returns(N-LayoutLine)),
  #get-line-extents => %(:is-symbol<pango_layout_iter_get_line_extents>,  :parameters([N-Rectangle , N-Rectangle ])),
  get-line-readonly => %(:is-symbol<pango_layout_iter_get_line_readonly>,  :returns(N-LayoutLine)),
  get-line-yrange => %(:is-symbol<pango_layout_iter_get_line_yrange>,  :parameters([gint-ptr, gint-ptr])),
  #get-run => %(:is-symbol<pango_layout_iter_get_run>, ),
  get-run-baseline => %(:is-symbol<pango_layout_iter_get_run_baseline>,  :returns(gint)),
  #get-run-extents => %(:is-symbol<pango_layout_iter_get_run_extents>,  :parameters([N-Rectangle , N-Rectangle ])),
  #get-run-readonly => %(:is-symbol<pango_layout_iter_get_run_readonly>, ),
  next-char => %(:is-symbol<pango_layout_iter_next_char>,  :returns(gboolean), :cnv-return(Bool)),
  next-cluster => %(:is-symbol<pango_layout_iter_next_cluster>,  :returns(gboolean), :cnv-return(Bool)),
  next-line => %(:is-symbol<pango_layout_iter_next_line>,  :returns(gboolean), :cnv-return(Bool)),
  next-run => %(:is-symbol<pango_layout_iter_next_run>,  :returns(gboolean), :cnv-return(Bool)),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library('libpango-1.0.so.0')
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
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
