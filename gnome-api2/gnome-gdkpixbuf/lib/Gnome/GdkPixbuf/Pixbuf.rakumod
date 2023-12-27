=comment Package: GdkPixbuf, C-Source: gdk-pixbuf
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
#use Gnome::GdkPixbuf::N-Format:api<2>;
use Gnome::GdkPixbuf::T-Core:api<2>;
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
  #new-gdkpixbuf => %( :type(Constructor), :is-symbol<gdk_pixbuf_new>, :returns(N-Object), :parameters([ GEnum, gboolean, gint, gint, gint])),
  #new-from-bytes => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_bytes>, :returns(N-Object), :parameters([ N-Bytes , GEnum, gboolean, gint, gint, gint, gint])),
  #new-from-data => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_data>, :returns(N-Object), :parameters([ Str, GEnum, gboolean, gint, gint, gint, gint, , gpointer])),
  new-from-file => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_file>, :returns(N-Object), :parameters([ Str, CArray[N-Error]])),
  new-from-file-at-scale => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_file_at_scale>, :returns(N-Object), :parameters([ Str, gint, gint, gboolean, CArray[N-Error]])),
  new-from-file-at-size => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_file_at_size>, :returns(N-Object), :parameters([ Str, gint, gint, CArray[N-Error]])),
  new-from-resource => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_resource>, :returns(N-Object), :parameters([ Str, CArray[N-Error]])),
  new-from-resource-at-scale => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_resource_at_scale>, :returns(N-Object), :parameters([ Str, gint, gint, gboolean, CArray[N-Error]])),
  new-from-stream => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_stream>, :returns(N-Object), :parameters([ N-Object, N-Object, CArray[N-Error]])),
  new-from-stream-at-scale => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_stream_at_scale>, :returns(N-Object), :parameters([ N-Object, gint, gint, gboolean, N-Object, CArray[N-Error]])),
  new-from-stream-finish => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_stream_finish>, :returns(N-Object), :parameters([ N-Object, CArray[N-Error]])),
  new-from-xpm-data => %( :type(Constructor), :is-symbol<gdk_pixbuf_new_from_xpm_data>, :returns(N-Object), :parameters([ gchar-pptr])),

  #--[Methods]------------------------------------------------------------------
  add-alpha => %(:is-symbol<gdk_pixbuf_add_alpha>,  :returns(N-Object), :parameters([gboolean, guchar, guchar, guchar])),
  apply-embedded-orientation => %(:is-symbol<gdk_pixbuf_apply_embedded_orientation>,  :returns(N-Object)),
  #composite => %(:is-symbol<gdk_pixbuf_composite>,  :parameters([N-Object, gint, gint, gint, gint, gdouble, gdouble, gdouble, gdouble, GEnum, gint])),
  #composite-color => %(:is-symbol<gdk_pixbuf_composite_color>,  :parameters([N-Object, gint, gint, gint, gint, gdouble, gdouble, gdouble, gdouble, GEnum, gint, gint, gint, gint, guint32, guint32])),
  #composite-color-simple => %(:is-symbol<gdk_pixbuf_composite_color_simple>,  :returns(N-Object), :parameters([gint, gint, GEnum, gint, gint, guint32, guint32])),
  copy => %(:is-symbol<gdk_pixbuf_copy>,  :returns(N-Object)),
  copy-area => %(:is-symbol<gdk_pixbuf_copy_area>,  :parameters([gint, gint, gint, gint, N-Object, gint, gint])),
  copy-options => %(:is-symbol<gdk_pixbuf_copy_options>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  fill => %(:is-symbol<gdk_pixbuf_fill>,  :parameters([guint32])),
  flip => %(:is-symbol<gdk_pixbuf_flip>,  :returns(N-Object), :parameters([gboolean])),
  get-bits-per-sample => %(:is-symbol<gdk_pixbuf_get_bits_per_sample>,  :returns(gint)),
  get-byte-length => %(:is-symbol<gdk_pixbuf_get_byte_length>,  :returns(gsize)),
  get-colorspace => %(:is-symbol<gdk_pixbuf_get_colorspace>,  :returns(GEnum), :cnv-return(GdkColorspace )),
  get-has-alpha => %(:is-symbol<gdk_pixbuf_get_has_alpha>,  :returns(gboolean), :cnv-return(Bool)),
  get-height => %(:is-symbol<gdk_pixbuf_get_height>,  :returns(gint)),
  get-n-channels => %(:is-symbol<gdk_pixbuf_get_n_channels>,  :returns(gint)),
  get-option => %(:is-symbol<gdk_pixbuf_get_option>,  :returns(Str), :parameters([Str])),
  #get-options => %(:is-symbol<gdk_pixbuf_get_options>,  :returns(N-HashTable )),
  get-pixels => %(:is-symbol<gdk_pixbuf_get_pixels>,  :returns(Str)),
  get-pixels-with-length => %(:is-symbol<gdk_pixbuf_get_pixels_with_length>,  :returns(Str), :parameters([gint-ptr])),
  get-rowstride => %(:is-symbol<gdk_pixbuf_get_rowstride>,  :returns(gint)),
  get-width => %(:is-symbol<gdk_pixbuf_get_width>,  :returns(gint)),
  new-subpixbuf => %(:is-symbol<gdk_pixbuf_new_subpixbuf>,  :returns(N-Object), :parameters([gint, gint, gint, gint])),
  #read-pixel-bytes => %(:is-symbol<gdk_pixbuf_read_pixel_bytes>,  :returns(N-Bytes )),
  #read-pixels => %(:is-symbol<gdk_pixbuf_read_pixels>, ),
  remove-option => %(:is-symbol<gdk_pixbuf_remove_option>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  #rotate-simple => %(:is-symbol<gdk_pixbuf_rotate_simple>,  :returns(N-Object), :parameters([GEnum])),
  saturate-and-pixelate => %(:is-symbol<gdk_pixbuf_saturate_and_pixelate>,  :parameters([N-Object, gfloat, gboolean])),
  save => %(:is-symbol<gdk_pixbuf_save>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, CArray[N-Error]])),
  save-to-buffer => %(:is-symbol<gdk_pixbuf_save_to_buffer>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([gchar-pptr, CArray[gsize], Str, CArray[N-Error]])),
  save-to-bufferv => %(:is-symbol<gdk_pixbuf_save_to_bufferv>,  :returns(gboolean), :cnv-return(Bool), :parameters([gchar-pptr, CArray[gsize], Str, gchar-pptr, gchar-pptr, CArray[N-Error]])),
  save-to-callback => %(:is-symbol<gdk_pixbuf_save_to_callback>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([:( Str $buf, gsize $count, CArray[N-Error] $error, gpointer $data --> gboolean ), gpointer, Str, CArray[N-Error]])),
  save-to-callbackv => %(:is-symbol<gdk_pixbuf_save_to_callbackv>,  :returns(gboolean), :cnv-return(Bool), :parameters([:( Str $buf, gsize $count, CArray[N-Error] $error, gpointer $data --> gboolean ), gpointer, Str, gchar-pptr, gchar-pptr, CArray[N-Error]])),
  save-to-stream => %(:is-symbol<gdk_pixbuf_save_to_stream>, :variable-list,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, Str, N-Object, CArray[N-Error]])),
  #save-to-stream-async => %(:is-symbol<gdk_pixbuf_save_to_stream_async>, :variable-list,  :parameters([N-Object, Str, N-Object, , gpointer])),
  save-to-streamv => %(:is-symbol<gdk_pixbuf_save_to_streamv>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, Str, gchar-pptr, gchar-pptr, N-Object, CArray[N-Error]])),
  #save-to-streamv-async => %(:is-symbol<gdk_pixbuf_save_to_streamv_async>,  :parameters([N-Object, Str, gchar-pptr, gchar-pptr, N-Object, , gpointer])),
  savev => %(:is-symbol<gdk_pixbuf_savev>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str, gchar-pptr, gchar-pptr, CArray[N-Error]])),
  #scale => %(:is-symbol<gdk_pixbuf_scale>,  :parameters([N-Object, gint, gint, gint, gint, gdouble, gdouble, gdouble, gdouble, GEnum])),
  #scale-simple => %(:is-symbol<gdk_pixbuf_scale_simple>,  :returns(N-Object), :parameters([gint, gint, GEnum])),
  set-option => %(:is-symbol<gdk_pixbuf_set_option>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str])),

  #--[Functions]----------------------------------------------------------------
  #calculate-rowstride => %( :type(Function), :is-symbol<gdk_pixbuf_calculate_rowstride>,  :returns(gint), :parameters([ GdkColorspace , gboolean, gint, gint, gint])),
  #get-file-info => %( :type(Function), :is-symbol<gdk_pixbuf_get_file_info>,  :returns(N-Format ), :parameters([ Str, gint-ptr, gint-ptr])),
  #get-file-info-async => %( :type(Function), :is-symbol<gdk_pixbuf_get_file_info_async>,  :parameters([ Str, N-Object, , gpointer])),
  #get-file-info-finish => %( :type(Function), :is-symbol<gdk_pixbuf_get_file_info_finish>,  :returns(N-Format ), :parameters([ N-Object, gint-ptr, gint-ptr, CArray[N-Error]])),
  get-formats => %( :type(Function), :is-symbol<gdk_pixbuf_get_formats>,  :returns(N-SList)),
  init-modules => %( :type(Function), :is-symbol<gdk_pixbuf_init_modules>,  :returns(gboolean), :parameters([ Str, CArray[N-Error]])),
  #new-from-stream-async => %( :type(Function), :is-symbol<gdk_pixbuf_new_from_stream_async>,  :parameters([ N-Object, N-Object, , gpointer])),
  #new-from-stream-at-scale-async => %( :type(Function), :is-symbol<gdk_pixbuf_new_from_stream_at_scale_async>,  :parameters([ N-Object, gint, gint, gboolean, N-Object, , gpointer])),
  save-to-stream-finish => %( :type(Function), :is-symbol<gdk_pixbuf_save_to_stream_finish>,  :returns(gboolean), :parameters([ N-Object, CArray[N-Error]])),
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
