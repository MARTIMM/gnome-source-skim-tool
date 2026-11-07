=comment Package: GIRepo, C-Source: girepository
use v6.d;
#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::GIRepository::T-repository:auth<github:MARTIMM>:api<2>;
#-------------------------------------------------------------------------------
#--[Enumerations]---------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GIRepositoryError is export <
  GI_REPOSITORY_ERROR_TYPELIB_NOT_FOUND GI_REPOSITORY_ERROR_NAMESPACE_MISMATCH GI_REPOSITORY_ERROR_NAMESPACE_VERSION_CONFLICT GI_REPOSITORY_ERROR_LIBRARY_NOT_FOUND 
>;

#-------------------------------------------------------------------------------
#--[Bitfields]------------------------------------------------------------------
#-------------------------------------------------------------------------------
enum GIRepositoryLoadFlags is export (
  :GI_REPOSITORY_LOAD_FLAG_NONE(0), :GI_REPOSITORY_LOAD_FLAG_LAZY(1)
);

