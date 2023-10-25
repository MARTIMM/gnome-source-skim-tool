# Command to generate: generate.raku -c -t Pango Layout
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-SList:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-AttrList:api<2>;
#use Gnome::Pango::N-FontDescription:api<2>;
use Gnome::Pango::N-LayoutIter:api<2>;
use Gnome::Pango::N-LayoutLine:api<2>;
#use Gnome::Pango::N-LogAttr:api<2>;
#use Gnome::Pango::N-Rectangle:api<2>;
#use Gnome::Pango::N-TabArray:api<2>;
#use Gnome::Pango::T-Direction:api<2>;
use Gnome::Pango::T-Layout:api<2>;


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
  $!routine-caller .= new( :library(pango-lib()), :sub-prefix<pango_layout_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Pango::Layout' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoLayout');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-layout => %( :type(Constructor), :isnew, :returns(N-GObject), :parameters([ N-GObject])),

  #--[Methods]------------------------------------------------------------------
  context-changed => %(),
  copy => %( :returns(N-GObject)),
  get-alignment => %( :returns(GEnum), :cnv-return(PangoAlignment)),
  #get-attributes => %( :returns(N-AttrList )),
  get-auto-dir => %( :returns(gboolean), :cnv-return(Bool)),
  get-baseline => %( :returns(gint)),
  #get-caret-pos => %( :parameters([gint, N-Rectangle , N-Rectangle ])),
  get-character-count => %( :returns(gint)),
  get-context => %( :returns(N-GObject)),
  #get-cursor-pos => %( :parameters([gint, N-Rectangle , N-Rectangle ])),
  #get-direction => %( :returns(GEnum), :cnv-return(PangoDirection ), :parameters([gint])),
  get-ellipsize => %( :returns(GEnum), :cnv-return(PangoEllipsizeMode)),
  #get-extents => %( :parameters([N-Rectangle , N-Rectangle ])),
  #get-font-description => %( :returns(N-FontDescription )),
  get-height => %( :returns(gint)),
  get-indent => %( :returns(gint)),
  get-iter => %( :returns(N-LayoutIter)),
  get-justify => %( :returns(gboolean), :cnv-return(Bool)),
  get-justify-last-line => %( :returns(gboolean), :cnv-return(Bool)),
  get-line => %( :returns(N-LayoutLine), :parameters([gint])),
  get-line-count => %( :returns(gint)),
  get-line-readonly => %( :returns(N-LayoutLine), :parameters([gint])),
  get-line-spacing => %( :returns(gfloat)),
  get-lines => %( :returns(N-SList)),
  get-lines-readonly => %( :returns(N-SList)),
  #get-log-attrs => %( :parameters([CArray[N-LogAttr] , gint-ptr])),
  #get-log-attrs-readonly => %( :returns(N-LogAttr ), :parameters([gint-ptr])),
  #get-pixel-extents => %( :parameters([N-Rectangle , N-Rectangle ])),
  get-pixel-size => %( :parameters([gint-ptr, gint-ptr])),
  get-serial => %( :returns(guint)),
  get-single-paragraph-mode => %( :returns(gboolean), :cnv-return(Bool)),
  get-size => %( :parameters([gint-ptr, gint-ptr])),
  get-spacing => %( :returns(gint)),
  #get-tabs => %( :returns(N-TabArray )),
  get-text => %( :returns(Str)),
  get-unknown-glyphs-count => %( :returns(gint)),
  get-width => %( :returns(gint)),
  get-wrap => %( :returns(GEnum), :cnv-return(PangoWrapMode)),
  index-to-line-x => %( :parameters([gint, gboolean, gint-ptr, gint-ptr])),
  #index-to-pos => %( :parameters([gint, N-Rectangle ])),
  is-ellipsized => %( :returns(gboolean), :cnv-return(Bool)),
  is-wrapped => %( :returns(gboolean), :cnv-return(Bool)),
  move-cursor-visually => %( :parameters([gboolean, gint, gint, gint, gint-ptr, gint-ptr])),
  #serialize => %( :returns(N-Bytes ), :parameters([GFlag])),
  set-alignment => %( :parameters([GEnum])),
  #set-attributes => %( :parameters([N-AttrList ])),
  set-auto-dir => %( :parameters([gboolean])),
  set-ellipsize => %( :parameters([GEnum])),
  #set-font-description => %( :parameters([N-FontDescription ])),
  set-height => %( :parameters([gint])),
  set-indent => %( :parameters([gint])),
  set-justify => %( :parameters([gboolean])),
  set-justify-last-line => %( :parameters([gboolean])),
  set-line-spacing => %( :parameters([gfloat])),
  set-markup => %( :parameters([Str, gint])),
  set-markup-with-accel => %( :parameters([Str, gint, gunichar, Str])),
  set-single-paragraph-mode => %( :parameters([gboolean])),
  set-spacing => %( :parameters([gint])),
  #set-tabs => %( :parameters([N-TabArray ])),
  set-text => %( :parameters([Str, gint])),
  set-width => %( :parameters([gint])),
  set-wrap => %( :parameters([GEnum])),
  write-to-file => %( :returns(gboolean), :cnv-return(Bool), :parameters([GFlag, Str])),
  xy-to-index => %( :returns(gboolean), :cnv-return(Bool), :parameters([gint, gint, gint-ptr, gint-ptr])),

  #--[Functions]----------------------------------------------------------------
  #deserialize => %( :type(Function),  :returns(N-GObject), :parameters([UInt])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(pango-lib()), :sub-prefix<pango_layout_>
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
