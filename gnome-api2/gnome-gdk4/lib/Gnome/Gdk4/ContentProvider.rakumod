=comment Package: Gdk4, C-Source: contentprovider
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::N-Value:api<2>;
use Gnome::GObject::Object:api<2>;
use Gnome::GObject::T-value:api<2>;
use Gnome::Gdk4::N-ContentFormats:api<2>;
use Gnome::Gdk4::T-types:api<2>;
use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::T-array:api<2>;
use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gdk4::ContentProvider:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

# Add signal registration helper
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<content-changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gdk4::ContentProvider' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GdkContentProvider');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-for-bytes => %( :type(Constructor), :is-symbol<gdk_content_provider_new_for_bytes>, :returns(N-Object), :parameters([ Str, N-Object])),
  new-for-value => %( :type(Constructor), :is-symbol<gdk_content_provider_new_for_value>, :returns(N-Object), :parameters([ N-Object])),
  new-typed => %( :type(Constructor), :is-symbol<gdk_content_provider_new_typed>, :returns(N-Object), :variable-list, :parameters([ GType])),
  new-union => %( :type(Constructor), :is-symbol<gdk_content_provider_new_union>, :returns(N-Object), :parameters([ CArray[N-Object], gsize])),

  #--[Methods]------------------------------------------------------------------
  content-changed => %(:is-symbol<gdk_content_provider_content_changed>, ),
  get-value => %(:is-symbol<gdk_content_provider_get_value>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
  ref-formats => %(:is-symbol<gdk_content_provider_ref_formats>,  :returns(N-Object)),
  ref-storable-formats => %(:is-symbol<gdk_content_provider_ref_storable_formats>,  :returns(N-Object)),
  #write-mime-type-async => %(:is-symbol<gdk_content_provider_write_mime_type_async>,  :parameters([Str, N-Object, gint, N-Object, , gpointer])),
  write-mime-type-finish => %(:is-symbol<gdk_content_provider_write_mime_type_finish>,  :returns(gboolean), :cnv-return(Bool), :parameters([N-Object, CArray[N-Error]])),
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
