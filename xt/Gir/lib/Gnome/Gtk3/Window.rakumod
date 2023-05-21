
use NativeCall;

use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::GlibToRakuTypes;
use Gnome::N::Gir;

use Gnome::Gtk3::Bin;

use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
unit class Gnome::Gtk3::Window:api('gir');
also is Gnome::Gtk3::Bin;

constant \Error = Gnome::Glib::Error;

#-------------------------------------------------------------------------------
has Str $!name-space;
has Str $!version;
has Str $!module;
has Str $!prefix;
has Str $!library;


has N-GObject $!repository;
has N-GObject $!object-info;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!name-space = 'Gtk';
  $!version = '3.0';
  $!module = 'Window';
  $!prefix = 'gtk_label_';

  # Get the repository. This is a global object for now.
  $!repository = g_irepository_get_default;


  my $e = CArray[N-GError].new(N-GError);
  my N-GObject $typelib = g_irepository_require(
    $!repository, $!name-space, $!version, 0, $e
  );

  unless $typelib {
    my Error() $error = $e[0];
    die $error.message;
  }

  $!library = g_irepository_get_shared_library( $!repository, $!name-space);

  $!object-info = g_irepository_find_by_name(
    $!repository, $!name-space, $!module
  );
  die "Module $!module not found" unless ?$!object-info;
}

#-------------------------------------------------------------------------------
method FALLBACK ( Str $name, *@arguments, *%options ) {

note $?LINE;
  my N-GObject $function-info = g_object_info_find_method(
    $!object-info, $name
  );

  die "Method $name not found" unless ?$function-info;

  my UInt $flags = g_function_info_get_flags($function-info);

note "function: ",
       g_function_info_get_symbol($function-info),
       ", type $flags.fmt('0b%08b')";

  g_base_info_unref($function-info);
}



=finish
#-------------------------------------------------------------------------------
sub _gtk_window_new ( GEnum $type --> N-GObject )
  is native(&gtk-lib)
  is symbol('gtk_window_new')
  { * }
}