=comment Package: GIRepo, C-Source: girepository
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



#use Gnome::GIRepository::N-Typelib:api<2>;
#use Gnome::GIRepository::T-gitypelib:api<2>;
use Gnome::GIRepository::T-repository:api<2>;
use Gnome::GObject::Object:api<2>;
#use Gnome::Glib::N-OptionGroup:api<2>;
use Gnome::Glib::T-error:api<2>;
#use Gnome::Glib::T-option:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::Repository:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(girepository-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::GIRepository::Repository' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GIRepository');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-repository => %( :type(Constructor), :is-symbol<gi_repository_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  enumerate-versions => %(:is-symbol<gi_repository_enumerate_versions>, :returns(gchar-pptr), :parameters([Str, gsize-ptr]), ),
  find-by-error-domain => %(:is-symbol<gi_repository_find_by_error_domain>, :returns(N-Object), :parameters([GQuark]), ),
  find-by-gtype => %(:is-symbol<gi_repository_find_by_gtype>, :returns(N-Object), :parameters([GType]), ),
  find-by-name => %(:is-symbol<gi_repository_find_by_name>, :returns(N-Object), :parameters([Str, Str]), ),
  get-c-prefix => %(:is-symbol<gi_repository_get_c_prefix>, :returns(Str), :parameters([Str]), ),
  get-dependencies => %(:is-symbol<gi_repository_get_dependencies>, :returns(gchar-pptr), :parameters([Str, gsize-ptr]), ),
  get-immediate-dependencies => %(:is-symbol<gi_repository_get_immediate_dependencies>, :returns(gchar-pptr), :parameters([Str, gsize-ptr]), ),
  get-info => %(:is-symbol<gi_repository_get_info>, :returns(N-Object), :parameters([Str, guint-ptr]), ),
  get-library-path => %(:is-symbol<gi_repository_get_library_path>, :returns(gchar-pptr), :parameters([gsize-ptr]), ),
  get-loaded-namespaces => %(:is-symbol<gi_repository_get_loaded_namespaces>, :returns(gchar-pptr), :parameters([gsize-ptr]), ),
  get-n-infos => %(:is-symbol<gi_repository_get_n_infos>, :returns(guint-ptr), :parameters([Str]), ),
  get-object-gtype-interfaces => %(:is-symbol<gi_repository_get_object_gtype_interfaces>, :parameters([GType, gsize-ptr, CArray[N-Object]]), ),
  get-search-path => %(:is-symbol<gi_repository_get_search_path>, :returns(gchar-pptr), :parameters([gsize-ptr]), ),
  get-shared-libraries => %(:is-symbol<gi_repository_get_shared_libraries>, :returns(gchar-pptr), :parameters([Str, gsize-ptr]), ),
  get-typelib-path => %(:is-symbol<gi_repository_get_typelib_path>, :returns(Str), :parameters([Str]), ),
  get-version => %(:is-symbol<gi_repository_get_version>, :returns(Str), :parameters([Str]), ),
  is-registered => %(:is-symbol<gi_repository_is_registered>, :returns(gboolean), :cnv-return(Bool), :parameters([Str, Str]), ),
  load-typelib => %(:is-symbol<gi_repository_load_typelib>, :returns(Str), :parameters([N-Object, GFlag, CArray[N-Error]]), ),
  prepend-library-path => %(:is-symbol<gi_repository_prepend_library_path>, :parameters([Str]), ),
  prepend-search-path => %(:is-symbol<gi_repository_prepend_search_path>, :parameters([Str]), ),
  require => %(:is-symbol<gi_repository_require>, :returns(N-Object), :parameters([Str, Str, GFlag, CArray[N-Error]]), ),
  require-private => %(:is-symbol<gi_repository_require_private>, :returns(N-Object), :parameters([Str, Str, Str, GFlag, CArray[N-Error]]), ),

  #--[Functions]----------------------------------------------------------------
  dump => %( :type(Function), :is-symbol<gi_repository_dump>, :returns(gboolean), :parameters([ Str, Str, CArray[N-Error]]), ),
  dup-default => %( :type(Function), :is-symbol<gi_repository_dup_default>, :returns(N-Object), ),
  error-quark => %( :type(Function), :is-symbol<gi_repository_error_quark>, :returns(GQuark), ),
  get-option-group => %( :type(Function), :is-symbol<gi_repository_get_option_group>, :returns(N-Object), ),
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
        :library(girepository-lib())
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
