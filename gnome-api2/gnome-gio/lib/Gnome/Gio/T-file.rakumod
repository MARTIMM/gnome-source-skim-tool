=comment Package: Gio, C-Source: file
use v6.d;
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Glib::T-error:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::T-file:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( ) {
  # Initialize helper
  $!routine-caller .= new(:library(gio-lib()));
}

#-------------------------------------------------------------------------------
#--[Standalone functions]-------------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(
  
  #--[Functions]----------------------------------------------------------------
  file-new-build-filenamev => %( :type(Function), :is-symbol<g_file_new_build_filenamev>, :returns(N-Object), :parameters([gchar-pptr]), ),
  file-new-for-commandline-arg => %( :type(Function), :is-symbol<g_file_new_for_commandline_arg>, :returns(N-Object), :parameters([Str]), ),
  file-new-for-commandline-arg-and-cwd => %( :type(Function), :is-symbol<g_file_new_for_commandline_arg_and_cwd>, :returns(N-Object), :parameters([ Str, Str]), ),
  file-new-for-path => %( :type(Function), :is-symbol<g_file_new_for_path>, :returns(N-Object), :parameters([Str]), ),
  file-new-for-uri => %( :type(Function), :is-symbol<g_file_new_for_uri>, :returns(N-Object), :parameters([Str]), ),
  file-new-tmp => %( :type(Function), :is-symbol<g_file_new_tmp>, :returns(N-Object), :parameters([ Str, CArray[N-Object], CArray[N-Error]]), ),
  file-new-tmp-async => %( :type(Function), :is-symbol<g_file_new_tmp_async>, :parameters([ Str, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $data ), gpointer]), ),
  file-new-tmp-dir-async => %( :type(Function), :is-symbol<g_file_new_tmp_dir_async>, :parameters([ Str, gint, N-Object, :( N-Object $source-object, N-Object $res, gpointer $data ), gpointer]), ),
  file-new-tmp-dir-finish => %( :type(Function), :is-symbol<g_file_new_tmp_dir_finish>, :returns(N-Object), :parameters([ N-Object, CArray[N-Error]]), ),
  file-new-tmp-finish => %( :type(Function), :is-symbol<g_file_new_tmp_finish>, :returns(N-Object), :parameters([ N-Object, CArray[N-Object], CArray[N-Error]]), ),
  file-parse-name => %( :type(Function), :is-symbol<g_file_parse_name>, :returns(N-Object), :parameters([Str]), ),

);
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods
    );
  }

  else {
    callsame;
  }
}
