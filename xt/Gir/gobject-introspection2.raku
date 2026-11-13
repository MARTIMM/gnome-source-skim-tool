use v6.d;
use lib './gnome-api2/gnome-gir/lib';
use NativeCall;

use Gnome::N::N-Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::X:api<2>;

use Gnome::Glib::T-error:api<2>;

use Gnome::GIRepository::Repository:api<2>;
use Gnome::GIRepository::BaseInfo:api<2>;
use Gnome::GIRepository::ObjectInfo:api<2>;
use Gnome::GIRepository::FunctionInfo:api<2>;
use Gnome::GIRepository::T-types:api<2>;

#-------------------------------------------------------------------------------
#constant GIREPOSITORY = 'libgirepository-1.0.so';
#constant Error = Gnome::Glib::Error;

#-------------------------------------------------------------------------------
my Gnome::GIRepository::Repository $repository .= new-repository;

my $e = CArray[N-Error].new(N-Error);
my N-Object $typelib = $repository.require( 'Gtk', '4.0', 0, $e);
if $typelib {
  note 'typelib ok';
}

else {
  my N-Error $error = $e[0];
  note $error.message;
}

# libs are ok
my $n-elems = CArray[gsize].new(0);
my Array $libs = $repository.get-shared-libraries( 'Gtk', $n-elems);
note 'libs: ', $n-elems[0], ', ', $libs[0];

# works! version is 3.0 and when Str is used above, it returns 4.0
note 'version: ', $repository.get-version('Gtk');


# works shows that GtkActionEntry is deprecated
my Gnome::GIRepository::BaseInfo() $base-info .= new(
  :native-object($repository.find-by-name( 'Gtk', 'AppChooserButton'))
);

if ?$base-info {
  note 'AppChooserButton deprecated: ', $base-info.is-deprecated.Bool;
  $base-info.clear-object;
}

else {
  note 'no base info';
}

# returned base info is a GIObjectInfo
my Gnome::GIRepository::ObjectInfo() $object-info =
   $repository.find-by-name( 'Gtk', 'Label');

note 'GtkLabel deprecated?: ', $object-info.is-deprecated.Bool;
#my GEnum $info-type = $base-info.get-type;
#note 'type: ', $info-type, ' = object';

note 'type name: ', $object-info.get-type-name;

#Gnome::N::debug(:on);
my Gnome::GIRepository::FunctionInfo() $function-info;
my Int $i = $object-info.get-n-methods;
for ^$i -> $n {
  $function-info = $object-info.get-method($n);
  my UInt $flags = $function-info.get-flags;
  note "$n: ", $function-info.get-symbol, ", type $flags.fmt('0b%08b')";
  for ( GI_FUNCTION_INFO_FLAGS_NONE, GI_FUNCTION_IS_METHOD,
    GI_FUNCTION_IS_CONSTRUCTOR, GI_FUNCTION_IS_GETTER, GI_FUNCTION_IS_SETTER,
    GI_FUNCTION_WRAPS_VFUNC, GI_FUNCTION_IS_ASYNC
  ) -> $flag {
    note "  ", GIFunctionInfoFlags($flag) if $flags +& $flag;
  }

  $function-info.clear-object;
}

$object-info.clear-object;

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
