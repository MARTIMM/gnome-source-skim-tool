
use NativeCall;

use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;

use Gnome::Glib::T-error:api<2>;

#-------------------------------------------------------------------------------
unit module Gnome::N::Gir:api('gir');

constant GIREPOSITORY = 'girepository-2.0';
#constant Error = Gnome::Glib::Error;

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# gi repository 
# 2026 11 03 - Changes in Gir libs
# returns a GIRepository
sub gi_repository_get_default ( --> N-Object )
  is native(GIREPOSITORY)
  is export
  { * }

sub gi_repository_new ( --> N-Object )
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GITypelib
sub gi_repository_require (
  N-Object $repository, Str $namespace, Str $version,
  guint $flags, CArray[N-Error]
  --> N-Object
) is native(GIREPOSITORY)
  is export
  { * }

# returns a GIBaseInfo
sub gi_repository_find_by_name (
  N-Object $repository, Str $namespace, Str $name --> N-Object
) is native(GIREPOSITORY)
  is export
  { * }

sub gi_repository_get_shared_libraries (
  N-Object $repository, Str $namespace, CArray[gsize] $nelems --> CArray[Str]
) is native(GIREPOSITORY)
  is export
  { * }

sub gi_repository_get_version (
  N-Object $repository, Str $namespace --> Str
) is native(GIREPOSITORY)
  is export
  { * }



# gi base info
sub gi_base_info_is_deprecated ( N-Object $info --> gboolean )
  is native(GIREPOSITORY)
  is export
  { * }

sub gi_base_info_unref ( N-Object $info )
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GIInfoType
sub gi_base_info_get_type ( N-Object $info --> GEnum )
  is native(GIREPOSITORY)
  is export
  { * }



# gi object info
sub gi_object_info_get_type_name ( N-Object --> Str )
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GIFunctionInfo
sub gi_object_info_get_method ( N-Object $info, gint $n --> N-Object)
  is native(GIREPOSITORY)
  is export
  { * }

# returns a GIFunctionInfo
sub gi_object_info_find_method ( N-Object $info, Str $name --> N-Object)
  is native(GIREPOSITORY)
  is export
  { * }




# function info
sub gi_object_info_get_n_methods ( N-Object $finfo --> gint )
  is native(GIREPOSITORY)
  is export
  { * }

sub gi_function_info_get_symbol ( N-Object $finfo --> Str )
  is native(GIREPOSITORY)
  is export
  { * }

sub gi_function_info_get_flags ( N-Object $finfo --> GEnum )
  is native(GIREPOSITORY)
  is export
  { * }
