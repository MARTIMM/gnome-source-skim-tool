use NativeCall;

use Gnome::N::N-Object;
use Gnome::N::GlibToRakuTypes;
use Gnome::N::Gir;

use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
constant \GIREPOSITORY = 'libgirepository-1.0.so';
constant \Error = Gnome::Glib::Error;

#-------------------------------------------------------------------------------
my N-Object $repository = g_irepository_get_default;

my $e = CArray[N-GError].new(N-GError);
my N-Object $typelib = g_irepository_require(
  $repository, 'Gtk', '3.0', 0, $e
);
if $typelib {
  note 'typelib ok';
}

else {
  my Error() $error = $e[0];
  note $error.message;
}

# libs are ok
note 'lib: ', g_irepository_get_shared_library( $repository, 'Gtk');

# works! version is 3.0 and when Str is used above, it returns 4.0
note 'version: ', g_irepository_get_version( $repository, 'Gtk');


# works shows that GtkActionEntry is deprecated
my N-Object $base-info = g_irepository_find_by_name( $repository, 'Gtk', 'ActionEntry');
if ?$base-info {
  note 'GtkActionEntry: ', g_base_info_is_deprecated($base-info).Bool;
  g_base_info_unref($base-info)
}

else {
  note 'no base info';
}

# returned base info is a GIObjectInfo
$base-info = g_irepository_find_by_name(
  $repository, 'Gtk', 'Label'
);

note 'GtkLabel: ', g_base_info_is_deprecated($base-info).Bool;
my GEnum $info-type = g_base_info_get_type($base-info);
note 'type: ', $info-type, ' = object';
note 'type name: ', g_object_info_get_type_name($base-info);


my N-Object $function-info;
my Int $i = g_object_info_get_n_methods($base-info);
for ^$i -> $n {
  $function-info = g_object_info_get_method( $base-info, $n);
  my UInt $flags = g_function_info_get_flags($function-info);
  note "function $n: ",
       g_function_info_get_symbol($function-info),
       ", type $flags.fmt('0b%08b')";

  g_base_info_unref($function-info);
}

g_base_info_unref($base-info);

=finish
#===============================================================================
# gi repository
# returns a GIRepository
sub g_irepository_get_default ( --> N-Object )
  is native(GIREPOSITORY)
  { * }

# returns a GITypelib
sub g_irepository_require (
  N-Object $repository, gchar-ptr $namespace, gchar-ptr $version,
  guint $flags, CArray[N-GError]
  --> N-Object
) is native(GIREPOSITORY)
  { * }

# returns a GIBaseInfo
sub g_irepository_find_by_name (
  N-Object $repository, gchar-ptr $namespace, gchar-ptr $name --> N-Object
) is native(GIREPOSITORY)
  { * }

sub g_irepository_get_shared_library (
  N-Object $repository, gchar-ptr $namespace --> gchar-ptr
) is native(GIREPOSITORY)
  { * }

sub g_irepository_get_version (
  N-Object $repository, gchar-ptr $namespace --> gchar-ptr
) is native(GIREPOSITORY)
  { * }



# gi base info
sub g_base_info_is_deprecated ( N-Object $info --> gboolean )
  is native(GIREPOSITORY)
  { * }

sub g_base_info_unref ( N-Object $info )
  is native(GIREPOSITORY)
  { * }

# returns a GIInfoType
sub g_base_info_get_type ( N-Object $info --> GEnum )
  is native(GIREPOSITORY)
  { * }



# gi object info
sub g_object_info_get_type_name ( N-Object --> gchar-ptr )
  is native(GIREPOSITORY)
  { * }

# returns a GIFunctionInfo
sub g_object_info_get_method ( N-Object $info, gint $n --> N-Object)
  is native(GIREPOSITORY)
  { * }




# function info
sub g_object_info_get_n_methods ( N-Object $finfo --> gint )
  is native(GIREPOSITORY)
  { * }

sub g_function_info_get_symbol ( N-Object $finfo --> gchar-ptr )
  is native(GIREPOSITORY)
  { * }

sub g_function_info_get_flags ( N-Object $finfo --> GEnum )
  is native(GIREPOSITORY)
  { * }
