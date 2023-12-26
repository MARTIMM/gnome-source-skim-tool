=comment Package: GdkPixbuf, C-Source: gdk-pixbuf
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
#use Gnome::GdkPixbuf::N-Format:api<2>;
#use Gnome::GdkPixbuf::T-Core:api<2>;
#use Gnome::GdkPixbuf::T-Transform:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
#use Gnome::Glib::N-HashTable:api<2>;
use Gnome::Glib::N-SList:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GdkPixbuf::Pixbuf:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gdk-pixbuf-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GdkPixbuf::Pixbuf' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkPixbuf');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  #new-gdkpixbuf => %( :type(Constructor), :is-symbol<gdkpixbufnew>, :returns(N-Object), :parameters([ GEnum, gboolean, gint, gint, gint])),
  #new-from-bytes => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_bytes>, :returns(N-Object), :parameters([ N-Bytes , GEnum, gboolean, gint, gint, gint, gint])),
  #new-from-data => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_data>, :returns(N-Object), :parameters([ Str, GEnum, gboolean, gint, gint, gint, gint, , gpointer])),
  new-from-file => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_file>, :returns(N-Object), :parameters([ Str, CArray[N-Error]])),
  new-from-file-at-scale => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_file_at_scale>, :returns(N-Object), :parameters([ Str, gint, gint, gboolean, CArray[N-Error]])),
  new-from-file-at-size => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_file_at_size>, :returns(N-Object), :parameters([ Str, gint, gint, CArray[N-Error]])),
  new-from-resource => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_resource>, :returns(N-Object), :parameters([ Str, CArray[N-Error]])),
  new-from-resource-at-scale => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_resource_at_scale>, :returns(N-Object), :parameters([ Str, gint, gint, gboolean, CArray[N-Error]])),
  new-from-stream => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_stream>, :returns(N-Object), :parameters([ N-Object, N-Object, CArray[N-Error]])),
  new-from-stream-at-scale => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_stream_at_scale>, :returns(N-Object), :parameters([ N-Object, gint, gint, gboolean, N-Object, CArray[N-Error]])),
  new-from-stream-finish => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_stream_finish>, :returns(N-Object), :parameters([ N-Object, CArray[N-Error]])),
  new-from-xpm-data => %( :type(Constructor), :is-symbol<gdkpixbufnew_from_xpm_data>, :returns(N-Object), :parameters([ gchar-pptr])),

  #--[Methods]------------------------------------------------------------------
  add-alpha => %(:is-symbol<gdkpixbufadd_alpha>,  :returns(N-Object), :parameters([gboolean, guchar, guchar, guchar])),
  apply-embedded-orientation => %(:is-symbol<gdkpixbufapply_embedded_orientation>,  :returns(N-Object)),
  #composite => %(:is-symbol<gdkpixbufcomposite>,  :parameters([N-Object, gint, gint, gint, gint, gdouble, gdouble, gdouble, gdouble, GEnum, gint])),
  #composite-color => %(:is-symbol<gdkpixbufcomposite_color>,  :parameters([N-Object, gint, gint, gint, gint, gdouble, gdouble, gdouble, gdouble, GEnum, gint, gint, gint, gint, guint32, guint32])),
  #composite-color-simple => %(:is-symbol<gdkpixbufcomposite_color_simple>,  :returns(N-Object), :parameters([gint, gint, GEnum, gint, gint, guint32, guint32])),
  copy => %(:is-symbol<gdkpixbufcopy>,  :returns(N-Object)),
  copy-area => %(:is-symbol<gdkpixbufcopy_area>,  :parameters([gint, gint, gint, gint, N-Object, gint, gint])),
  copy-options => %(:is-symbol<gdkpixbufcopy_options>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  fill => %(:is-symbol<gdkpixbuffill>,  :parameters([guint32])),
  flip => %(:is-symbol<gdkpixbufflip>,  :returns(N-Object), :parameters([gboolean])),
  get-bits-per-sample => %(:is-symbol<gdkpixbufget_bits_per_sample>,  :returns(gint)),
  get-byte-length => %(:is-symbol<gdkpixbufget_byte_length>,  :returns(gsize)),
  #get-colorspace => %(:is-symbol<gdkpixbufget_colorspace>,  :returns(GEnum), :cnv-return(GdkColorspace )),
  get-has-alpha => %(:is-symbol<gdkpixbufget_has_alpha>,  :returns(gboolean), :cnv-return(Bool)),
  get-height => %(:is-symbol<gdkpixbufget_height>,  :returns(gint)),
  get-n-channels => %(:is-symbol<gdkpixbufget_n_channels>,  :returns(gint)),
  get-option => %(:is-symbol<gdkpixbufget_option>,  :returns(Str), :parameters([Str])),
  #get-options => %(:is-symbol<gdkpixbufget_options>,  :returns(N-HashTable )),
  get-pixels => %(:is-symbol<gdkpixbufget_pixels>,  :returns(Str)),
  get-pixels-with-length => %(:is-symbol<gdkpixbufget_pixels_with_length>,  :returns(Str), :parameters([gint-ptr])),
  get-rowstride => %(:is-symbol<gdkpixbufget_rowstride>,  :returns(gint)),
  get-width => %(:is-symbol<gdkpixbufget_width>,  :returns(gint)),
  new-subpixbuf => %(:is-symbol<gdkpixbufnew_subpixbuf>,  :returns(N-Object), :parameters([gint, gint, gint, gint])),
  #read-pixel-bytes => %(:is-symbol<gdkpixbufread_pixel_bytes>,  :returns(N-Bytes )),
  #read-pixels => %(:is-symbol<gdkpixbufread_pixels>, ),
  remove-option => %(:is-symbol<gdkpixbufremove_option>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  #rotate-simple => %(:is-symbol<gdkpixbufrotate_simple>,  :returns(N-Object), :parameters([GEnum])),
  saturate-and-pixelate => %(:is-symbol<gdkpixbufsaturate_and_pixelate>,  :parameters([N-Object, gfloat, gboolean])),
  save => %(:is-symbol<gdkpixbufsave>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, CArray[N-Error]])),
  save-to-buffer => %(:is-symbol<gdkpixbufsave_to_buffer>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([gchar-pptr, CArray[gsize], Str, CArray[N-Error]])),
  save-to-bufferv => %(:is-symbol<gdkpixbufsave_to_bufferv>,  :returns(gboolean), :cnv-return(Bool), :parameters([gchar-pptr, CArray[gsize], Str, gchar-pptr, gchar-pptr, CArray[N-Error]])),
  save-to-callback => %(:is-symbol<gdkpixbufsave_to_callback>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([:( Str $buf, gsize $count, CArray[N-Error] $error, gpointer $data --> gboolean ), gpointer, Str, CArray[N-Error]])),
  save-to-callbackv => %(:is-symbol<gdkpixbufsave_to_callbackv>,  :returns(gboolean), :cnv-return(Bool), :parameters([:( Str $buf, gsize $count, CArray[N-Error] $error, gpointer $data --> gboolean ), gpointer, Str, gchar-pptr, gchar-pptr, CArray[N-Error]])),
  save-to-stream => %(:is-symbol<gdkpixbufsave_to_stream>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, Str, N-Object, CArray[N-Error]])),
  #save-to-stream-async => %(:is-symbol<gdkpixbufsave_to_stream_async>, :variable-list,  :parameters([N-Object, Str, N-Object, , gpointer])),
  save-to-streamv => %(:is-symbol<gdkpixbufsave_to_streamv>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, Str, gchar-pptr, gchar-pptr, N-Object, CArray[N-Error]])),
  #save-to-streamv-async => %(:is-symbol<gdkpixbufsave_to_streamv_async>,  :parameters([N-Object, Str, gchar-pptr, gchar-pptr, N-Object, , gpointer])),
  savev => %(:is-symbol<gdkpixbufsavev>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, gchar-pptr, gchar-pptr, CArray[N-Error]])),
  #scale => %(:is-symbol<gdkpixbufscale>,  :parameters([N-Object, gint, gint, gint, gint, gdouble, gdouble, gdouble, gdouble, GEnum])),
  #scale-simple => %(:is-symbol<gdkpixbufscale_simple>,  :returns(N-Object), :parameters([gint, gint, GEnum])),
  set-option => %(:is-symbol<gdkpixbufset_option>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),

  #--[Functions]----------------------------------------------------------------
  #calculate-rowstride => %( :type(Function), :is-symbol<gdkpixbufcalculate_rowstride>,  :returns(gint), :parameters([ GdkColorspace , gboolean, gint, gint, gint])),
  #get-file-info => %( :type(Function), :is-symbol<gdkpixbufget_file_info>,  :returns(N-Format ), :parameters([ Str, gint-ptr, gint-ptr])),
  #get-file-info-async => %( :type(Function), :is-symbol<gdkpixbufget_file_info_async>,  :parameters([ Str, N-Object, , gpointer])),
  #get-file-info-finish => %( :type(Function), :is-symbol<gdkpixbufget_file_info_finish>,  :returns(N-Format ), :parameters([ N-Object, gint-ptr, gint-ptr, CArray[N-Error]])),
  get-formats => %( :type(Function), :is-symbol<gdkpixbufget_formats>,  :returns(N-SList)),
  init-modules => %( :type(Function), :is-symbol<gdkpixbufinit_modules>,  :returns(gboolean), :parameters([ Str, CArray[N-Error]])),
  #new-from-stream-async => %( :type(Function), :is-symbol<gdkpixbufnew_from_stream_async>,  :parameters([ N-Object, N-Object, , gpointer])),
  #new-from-stream-at-scale-async => %( :type(Function), :is-symbol<gdkpixbufnew_from_stream_at_scale_async>,  :parameters([ N-Object, gint, gint, gboolean, N-Object, , gpointer])),
  save-to-stream-finish => %( :type(Function), :is-symbol<gdkpixbufsave_to_stream_finish>,  :returns(gboolean), :parameters([ N-Object, CArray[N-Error]])),
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
        :library(gdk-pixbuf-lib())
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
