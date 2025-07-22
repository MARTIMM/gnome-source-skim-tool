=comment Package: Pango, C-Source: layout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::Object:api<2>;
use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-SList:api<2>;
use Gnome::Glib::T-array:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::Glib::T-slist:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-AttrList:api<2>;
#use Gnome::Pango::N-FontDescription:api<2>;
use Gnome::Pango::N-LayoutIter:api<2>;
use Gnome::Pango::N-LayoutLine:api<2>;
#use Gnome::Pango::N-LogAttr:api<2>;
use Gnome::Pango::N-Rectangle:api<2>;
use Gnome::Pango::N-TabArray:api<2>;
#use Gnome::Pango::T-attributes:api<2>;
#use Gnome::Pango::T-break:api<2>;
use Gnome::Pango::T-direction:api<2>;
#use Gnome::Pango::T-font:api<2>;
use Gnome::Pango::T-layout:api<2>;
#use Gnome::Pango::T-tabs:api<2>;
#use Gnome::Pango::T-types:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::Layout:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Pango::Layout' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoLayout');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-layout => %( :type(Constructor), :is-symbol<pango_layout_new>, :returns(N-Object), :parameters([ N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  context-changed => %(:is-symbol<pango_layout_context_changed>, ),
  copy => %(:is-symbol<pango_layout_copy>, :returns(N-Object), ),
  get-alignment => %(:is-symbol<pango_layout_get_alignment>,  :returns(GEnum), :cnv-return(PangoAlignment)),
  get-attributes => %(:is-symbol<pango_layout_get_attributes>, :returns(N-Object), ),
  get-auto-dir => %(:is-symbol<pango_layout_get_auto_dir>, :returns(gboolean), ),
  get-baseline => %(:is-symbol<pango_layout_get_baseline>, :returns(gint), ),
  get-caret-pos => %(:is-symbol<pango_layout_get_caret_pos>, :parameters([gint, N-Object, N-Object]), ),
  get-character-count => %(:is-symbol<pango_layout_get_character_count>, :returns(gint), ),
  get-context => %(:is-symbol<pango_layout_get_context>, :returns(N-Object), ),
  get-cursor-pos => %(:is-symbol<pango_layout_get_cursor_pos>, :parameters([gint, N-Object, N-Object]), ),
  get-direction => %(:is-symbol<pango_layout_get_direction>,  :returns(GEnum), :cnv-return(PangoDirection),:parameters([gint]), ),
  get-ellipsize => %(:is-symbol<pango_layout_get_ellipsize>,  :returns(GEnum), :cnv-return(PangoEllipsizeMode)),
  get-extents => %(:is-symbol<pango_layout_get_extents>, :parameters([N-Object, N-Object]), ),
  get-font-description => %(:is-symbol<pango_layout_get_font_description>, :returns(N-Object), ),
  get-height => %(:is-symbol<pango_layout_get_height>, :returns(gint), ),
  get-indent => %(:is-symbol<pango_layout_get_indent>, :returns(gint), ),
  get-iter => %(:is-symbol<pango_layout_get_iter>, :returns(N-Object), ),
  get-justify => %(:is-symbol<pango_layout_get_justify>, :returns(gboolean), ),
  get-justify-last-line => %(:is-symbol<pango_layout_get_justify_last_line>, :returns(gboolean), ),
  get-line => %(:is-symbol<pango_layout_get_line>, :returns(N-Object), :parameters([gint]), ),
  get-line-count => %(:is-symbol<pango_layout_get_line_count>, :returns(gint), ),
  get-line-readonly => %(:is-symbol<pango_layout_get_line_readonly>, :returns(N-Object), :parameters([gint]), ),
  get-line-spacing => %(:is-symbol<pango_layout_get_line_spacing>, :returns(gfloat), ),
  get-lines => %(:is-symbol<pango_layout_get_lines>, :returns(N-Object), ),
  get-lines-readonly => %(:is-symbol<pango_layout_get_lines_readonly>, :returns(N-Object), ),
  get-log-attrs => %(:is-symbol<pango_layout_get_log_attrs>, :parameters([N-Object, gint-ptr]), ),
  get-log-attrs-readonly => %(:is-symbol<pango_layout_get_log_attrs_readonly>, :returns(N-Object), :parameters([gint-ptr]), ),
  get-pixel-extents => %(:is-symbol<pango_layout_get_pixel_extents>, :parameters([N-Object, N-Object]), ),
  get-pixel-size => %(:is-symbol<pango_layout_get_pixel_size>, :parameters([gint-ptr, gint-ptr]), ),
  get-serial => %(:is-symbol<pango_layout_get_serial>, :returns(guint), ),
  get-single-paragraph-mode => %(:is-symbol<pango_layout_get_single_paragraph_mode>, :returns(gboolean), ),
  get-size => %(:is-symbol<pango_layout_get_size>, :parameters([gint-ptr, gint-ptr]), ),
  get-spacing => %(:is-symbol<pango_layout_get_spacing>, :returns(gint), ),
  get-tabs => %(:is-symbol<pango_layout_get_tabs>, :returns(N-Object), ),
  get-text => %(:is-symbol<pango_layout_get_text>, :returns(Str), ),
  get-unknown-glyphs-count => %(:is-symbol<pango_layout_get_unknown_glyphs_count>, :returns(gint), ),
  get-width => %(:is-symbol<pango_layout_get_width>, :returns(gint), ),
  get-wrap => %(:is-symbol<pango_layout_get_wrap>,  :returns(GEnum), :cnv-return(PangoWrapMode)),
  index-to-line-x => %(:is-symbol<pango_layout_index_to_line_x>, :parameters([gint, gboolean, gint-ptr, gint-ptr]), ),
  index-to-pos => %(:is-symbol<pango_layout_index_to_pos>, :parameters([gint, N-Object]), ),
  is-ellipsized => %(:is-symbol<pango_layout_is_ellipsized>, :returns(gboolean), ),
  is-wrapped => %(:is-symbol<pango_layout_is_wrapped>, :returns(gboolean), ),
  move-cursor-visually => %(:is-symbol<pango_layout_move_cursor_visually>, :parameters([gboolean, gint, gint, gint, gint-ptr, gint-ptr]), ),
  serialize => %(:is-symbol<pango_layout_serialize>, :returns(N-Object), :parameters([GFlag]), ),
  set-alignment => %(:is-symbol<pango_layout_set_alignment>, :parameters([GEnum]), ),
  set-attributes => %(:is-symbol<pango_layout_set_attributes>, :parameters([N-Object]), ),
  set-auto-dir => %(:is-symbol<pango_layout_set_auto_dir>, :parameters([gboolean]), ),
  set-ellipsize => %(:is-symbol<pango_layout_set_ellipsize>, :parameters([GEnum]), ),
  set-font-description => %(:is-symbol<pango_layout_set_font_description>, :parameters([N-Object]), ),
  set-height => %(:is-symbol<pango_layout_set_height>, :parameters([gint]), ),
  set-indent => %(:is-symbol<pango_layout_set_indent>, :parameters([gint]), ),
  set-justify => %(:is-symbol<pango_layout_set_justify>, :parameters([gboolean]), ),
  set-justify-last-line => %(:is-symbol<pango_layout_set_justify_last_line>, :parameters([gboolean]), ),
  set-line-spacing => %(:is-symbol<pango_layout_set_line_spacing>, :parameters([gfloat]), ),
  set-markup => %(:is-symbol<pango_layout_set_markup>, :parameters([Str, gint]), ),
  set-markup-with-accel => %(:is-symbol<pango_layout_set_markup_with_accel>, :parameters([Str, gint, gunichar, Str]), ),
  set-single-paragraph-mode => %(:is-symbol<pango_layout_set_single_paragraph_mode>, :parameters([gboolean]), ),
  set-spacing => %(:is-symbol<pango_layout_set_spacing>, :parameters([gint]), ),
  set-tabs => %(:is-symbol<pango_layout_set_tabs>, :parameters([N-Object]), ),
  set-text => %(:is-symbol<pango_layout_set_text>, :parameters([Str, gint]), ),
  set-width => %(:is-symbol<pango_layout_set_width>, :parameters([gint]), ),
  set-wrap => %(:is-symbol<pango_layout_set_wrap>, :parameters([GEnum]), ),
  write-to-file => %(:is-symbol<pango_layout_write_to_file>, :returns(gboolean), :parameters([GFlag, Str, CArray[N-Error]]), ),
  xy-to-index => %(:is-symbol<pango_layout_xy_to_index>, :returns(gboolean), :parameters([gint, gint, gint-ptr, gint-ptr]), ),

  #--[Functions]----------------------------------------------------------------
  deserialize => %( :type(Function), :is-symbol<pango_layout_deserialize>, :returns(N-Object), :parameters([ UInt, CArray[N-Error]]), ),
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
