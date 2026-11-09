use v6.d;
use lib './xt/Gir/lib';

use NativeCall;

use Gnome::N::N-Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::Gir;

use Gnome::Glib::T-error:api<2>;

#-------------------------------------------------------------------------------
#constant GIREPOSITORY = 'libgirepository-1.0.so';
#constant Error = Gnome::Glib::Error;

#-------------------------------------------------------------------------------
my N-Object $repository = gi_repository_new;

my $e = CArray[N-Error].new(N-Error);
my N-Object $typelib = gi_repository_require(
  $repository, 'Gtk', '4.0', 0, $e
);
if $typelib {
  note 'typelib ok';
}

else {
  my N-Error $error = $e[0];
  note $error.message;
}

# libs are ok
my $n-elems = CArray[gsize].new(0);
my CArray[Str] $libs = gi_repository_get_shared_libraries(
  $repository, 'Gtk', $n-elems
);
note 'libs: ', $n-elems[0], ', ', $libs[0];

# works! version is 3.0 and when Str is used above, it returns 4.0
note 'version: ', gi_repository_get_version( $repository, 'Gtk');


# works shows that GtkActionEntry is deprecated
my N-Object $base-info = gi_repository_find_by_name( $repository, 'Gtk', 'AppChooserButton');
if ?$base-info {
  note 'AppChooserButton deprecated: ', gi_base_info_is_deprecated($base-info).Bool;
  gi_base_info_unref($base-info);
}

else {
  note 'no base info';
}

# returned base info is a GIObjectInfo
$base-info = gi_repository_find_by_name(
  $repository, 'Gtk', 'Label'
);

note 'GtkLabel: ', gi_base_info_is_deprecated($base-info).Bool;
my GEnum $info-type = gi_base_info_get_type($base-info);
note 'type: ', $info-type, ' = object';
note 'type name: ', gi_object_info_get_type_name($base-info);


my N-Object $function-info;
my Int $i = gi_object_info_get_n_methods($base-info);
for ^$i -> $n {
  $function-info = gi_object_info_get_method( $base-info, $n);
  my UInt $flags = gi_function_info_get_flags($function-info);
  note "function $n: ",
       gi_function_info_get_symbol($function-info),
       ", type $flags.fmt('0b%08b')";
  for ( GI_FUNCTION_INFO_FLAGS_NONE, GI_FUNCTION_IS_METHOD,
    GI_FUNCTION_IS_CONSTRUCTOR, GI_FUNCTION_IS_GETTER, GI_FUNCTION_IS_SETTER,
    GI_FUNCTION_WRAPS_VFUNC, GI_FUNCTION_IS_ASYNC
  ) -> $flag {
    note "  ", FunctionInfoFlags($flag) if $flags +& $flag;
  }


  gi_base_info_unref($function-info);
}

gi_base_info_unref($base-info);

=finish
#===============================================================================
# gi repository
# returns a GIRepository
sub gi_repository_get_default ( --> N-Object )
  is native(GIREPOSITORY)
  { * }

# returns a GITypelib
sub gi_repository_require (
  N-Object $repository, gchar-ptr $namespace, gchar-ptr $version,
  guint $flags, CArray[N-GError]
  --> N-Object
) is native(GIREPOSITORY)
  { * }

# returns a GIBaseInfo
sub gi_repository_find_by_name (
  N-Object $repository, gchar-ptr $namespace, gchar-ptr $name --> N-Object
) is native(GIREPOSITORY)
  { * }

sub gi_repository_get_shared_library (
  N-Object $repository, gchar-ptr $namespace --> gchar-ptr
) is native(GIREPOSITORY)
  { * }

sub gi_repository_get_version (
  N-Object $repository, gchar-ptr $namespace --> gchar-ptr
) is native(GIREPOSITORY)
  { * }



# gi base info
sub gi_base_info_is_deprecated ( N-Object $info --> gboolean )
  is native(GIREPOSITORY)
  { * }

sub gi_base_info_unref ( N-Object $info )
  is native(GIREPOSITORY)
  { * }

# returns a GIInfoType
sub gi_base_info_get_type ( N-Object $info --> GEnum )
  is native(GIREPOSITORY)
  { * }



# gi object info
sub gi_object_info_get_type_name ( N-Object --> gchar-ptr )
  is native(GIREPOSITORY)
  { * }

# returns a GIFunctionInfo
sub gi_object_info_get_method ( N-Object $info, gint $n --> N-Object)
  is native(GIREPOSITORY)
  { * }




# function info
sub gi_object_info_get_n_methods ( N-Object $finfo --> gint )
  is native(GIREPOSITORY)
  { * }

sub gi_function_info_get_symbol ( N-Object $finfo --> gchar-ptr )
  is native(GIREPOSITORY)
  { * }

sub gi_function_info_get_flags ( N-Object $finfo --> GEnum )
  is native(GIREPOSITORY)
  { * }
