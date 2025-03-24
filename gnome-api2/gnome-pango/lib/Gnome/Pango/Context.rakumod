=comment Package: Pango, C-Source: context
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::GObject::Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-FontDescription:api<2>;
#use Gnome::Pango::N-FontMetrics:api<2>;
#use Gnome::Pango::N-Language:api<2>;
use Gnome::Pango::N-Matrix:api<2>;
use Gnome::Pango::T-direction:api<2>;
#use Gnome::Pango::T-font:api<2>;
use Gnome::Pango::T-gravity:api<2>;
use Gnome::Pango::T-matrix:api<2>;
#use Gnome::Pango::T-types:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::Context:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
  if self.^name eq 'Gnome::Pango::Context' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoContext');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-context => %( :type(Constructor), :is-symbol<pango_context_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  changed => %(:is-symbol<pango_context_changed>, ),
  get-base-dir => %(:is-symbol<pango_context_get_base_dir>,  :returns(GEnum), :cnv-return(PangoDirection)),
  get-base-gravity => %(:is-symbol<pango_context_get_base_gravity>,  :returns(GEnum), :cnv-return(PangoGravity)),
  get-font-description => %(:is-symbol<pango_context_get_font_description>, :returns(N-Object), ),
  get-font-map => %(:is-symbol<pango_context_get_font_map>, :returns(N-Object), ),
  get-gravity => %(:is-symbol<pango_context_get_gravity>,  :returns(GEnum), :cnv-return(PangoGravity)),
  get-gravity-hint => %(:is-symbol<pango_context_get_gravity_hint>,  :returns(GEnum), :cnv-return(PangoGravityHint)),
  get-language => %(:is-symbol<pango_context_get_language>, :returns(N-Object), ),
  get-matrix => %(:is-symbol<pango_context_get_matrix>, :returns(N-Object), ),
  get-metrics => %(:is-symbol<pango_context_get_metrics>, :returns(N-Object), :parameters([N-Object, N-Object]), ),
  get-round-glyph-positions => %(:is-symbol<pango_context_get_round_glyph_positions>, :returns(gboolean), ),
  get-serial => %(:is-symbol<pango_context_get_serial>, :returns(guint), ),
  list-families => %(:is-symbol<pango_context_list_families>, :parameters([CArray[N-Object], gint-ptr]), ),
  load-font => %(:is-symbol<pango_context_load_font>, :returns(N-Object), :parameters([N-Object]), ),
  load-fontset => %(:is-symbol<pango_context_load_fontset>, :returns(N-Object), :parameters([N-Object, N-Object]), ),
  set-base-dir => %(:is-symbol<pango_context_set_base_dir>, :parameters([GEnum]), ),
  set-base-gravity => %(:is-symbol<pango_context_set_base_gravity>, :parameters([GEnum]), ),
  set-font-description => %(:is-symbol<pango_context_set_font_description>, :parameters([N-Object]), ),
  set-font-map => %(:is-symbol<pango_context_set_font_map>, :parameters([N-Object]), ),
  set-gravity-hint => %(:is-symbol<pango_context_set_gravity_hint>, :parameters([GEnum]), ),
  set-language => %(:is-symbol<pango_context_set_language>, :parameters([N-Object]), ),
  set-matrix => %(:is-symbol<pango_context_set_matrix>, :parameters([N-Object]), ),
  set-round-glyph-positions => %(:is-symbol<pango_context_set_round_glyph_positions>, :parameters([gboolean]), ),
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
