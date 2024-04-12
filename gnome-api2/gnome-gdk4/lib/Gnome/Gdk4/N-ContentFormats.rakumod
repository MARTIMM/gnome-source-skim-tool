=comment Package: Gdk4, C-Source: types
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gdk4::T-types:api<2>;
#use Gnome::Glib::T-string:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::N-ContentFormats:auth<github:MARTIMM>:api<2>;
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
  if self.^name eq 'Gnome::Gdk4::ContentFormats' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkContentFormats');
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
  new-contentformats => %( :type(Constructor), :is-symbol<gdk_content_formats_new>, :returns(N-Object), :parameters([ gchar-pptr, guint])),
  new-for-gtype => %( :type(Constructor), :is-symbol<gdk_content_formats_new_for_gtype>, :returns(N-Object), :parameters([ GType])),

  #--[Methods]------------------------------------------------------------------
  contain-gtype => %(:is-symbol<gdk_content_formats_contain_gtype>,  :returns(gboolean), :cnv-return(Bool), :parameters([GType])),
  contain-mime-type => %(:is-symbol<gdk_content_formats_contain_mime_type>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str])),
  #get-gtypes => %(:is-symbol<gdk_content_formats_get_gtypes>,  :parameters([CArray[gsize]])),
  get-mime-types => %(:is-symbol<gdk_content_formats_get_mime_types>,  :returns(gchar-pptr), :parameters([CArray[gsize]])),
  match => %(:is-symbol<gdk_content_formats_match>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  match-gtype => %(:is-symbol<gdk_content_formats_match_gtype>,  :returns(GType), :parameters([N-Object])),
  match-mime-type => %(:is-symbol<gdk_content_formats_match_mime_type>,  :returns(Str), :parameters([N-Object])),
  print => %(:is-symbol<gdk_content_formats_print>,  :parameters([N-Object])),
  ref => %(:is-symbol<gdk_content_formats_ref>,  :returns(N-Object)),
  to-string => %(:is-symbol<gdk_content_formats_to_string>,  :returns(Str)),
  union => %(:is-symbol<gdk_content_formats_union>,  :returns(N-Object), :parameters([N-Object])),
  union-deserialize-gtypes => %(:is-symbol<gdk_content_formats_union_deserialize_gtypes>,  :returns(N-Object)),
  union-deserialize-mime-types => %(:is-symbol<gdk_content_formats_union_deserialize_mime_types>,  :returns(N-Object)),
  union-serialize-gtypes => %(:is-symbol<gdk_content_formats_union_serialize_gtypes>,  :returns(N-Object)),
  union-serialize-mime-types => %(:is-symbol<gdk_content_formats_union_serialize_mime_types>,  :returns(N-Object)),
  unref => %(:is-symbol<gdk_content_formats_unref>, ),

  #--[Functions]----------------------------------------------------------------
  parse => %( :type(Function), :is-symbol<gdk_content_formats_parse>,  :returns(N-Object), :parameters([Str])),
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
