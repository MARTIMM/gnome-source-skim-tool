
use NativeCall;

use Gnome::N::N-Object;
use Gnome::N::NativeLib;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
unit module Gnome::N::Gir:api('gir');

constant \GIREPOSITORY = 'libgirepository-1.0.so';
constant \Error = Gnome::Glib::Error;

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# gi repository
# returns a GIRepository
sub g_irepository_get_default ( --> N-Object )
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GITypelib
sub g_irepository_require (
  N-Object $repository, gchar-ptr $namespace, gchar-ptr $version,
  guint $flags, CArray[N-GError]
  --> N-Object
) is native(GIREPOSITORY)
  is export
  { * }

# returns a GIBaseInfo
sub g_irepository_find_by_name (
  N-Object $repository, gchar-ptr $namespace, gchar-ptr $name --> N-Object
) is native(GIREPOSITORY)
  is export
  { * }

sub g_irepository_get_shared_library (
  N-Object $repository, gchar-ptr $namespace --> gchar-ptr
) is native(GIREPOSITORY)
  is export
  { * }

sub g_irepository_get_version (
  N-Object $repository, gchar-ptr $namespace --> gchar-ptr
) is native(GIREPOSITORY)
  is export
  { * }



# gi base info
sub g_base_info_is_deprecated ( N-Object $info --> gboolean )
  is native(GIREPOSITORY)
  is export
  { * }

sub g_base_info_unref ( N-Object $info )
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GIInfoType
sub g_base_info_get_type ( N-Object $info --> GEnum )
  is native(GIREPOSITORY)
  is export
  { * }



# gi object info
sub g_object_info_get_type_name ( N-Object --> gchar-ptr )
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GIFunctionInfo
sub g_object_info_get_method ( N-Object $info, gint $n --> N-Object)
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GIFunctionInfo
sub g_object_info_find_method ( N-Object $info, Str $name --> N-Object)
  is native(GIREPOSITORY)
  is export
  { * }




# function info
sub g_object_info_get_n_methods ( N-Object $finfo --> gint )
  is native(GIREPOSITORY)
  is export
  { * }

sub g_function_info_get_symbol ( N-Object $finfo --> gchar-ptr )
  is native(GIREPOSITORY)
  is export
  { * }

sub g_function_info_get_flags ( N-Object $finfo --> GEnum )
  is native(GIREPOSITORY)
  is export
  { * }
