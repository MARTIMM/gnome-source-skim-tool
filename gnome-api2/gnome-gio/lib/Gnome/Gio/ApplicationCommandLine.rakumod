=comment Package: Gio, C-Source: applicationcommandline
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::Glib::N-Variant:api<2>;
use Gnome::Glib::N-VariantDict:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::ApplicationCommandLine:auth<github:MARTIMM>:api<2>;
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
  $!routine-caller .= new(:library(gio-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gio::ApplicationCommandLine' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GApplicationCommandLine');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  create-file-for-arg => %(:is-symbol<g_application_command_line_create_file_for_arg>,  :returns(N-Object), :parameters([Str])),
  get-arguments => %(:is-symbol<g_application_command_line_get_arguments>,  :returns(gchar-pptr), :parameters([gint-ptr])),
  get-cwd => %(:is-symbol<g_application_command_line_get_cwd>,  :returns(Str)),
  get-environ => %(:is-symbol<g_application_command_line_get_environ>,  :returns(gchar-pptr)),
  get-exit-status => %(:is-symbol<g_application_command_line_get_exit_status>,  :returns(gint)),
  get-is-remote => %(:is-symbol<g_application_command_line_get_is_remote>,  :returns(gboolean), :cnv-return(Bool)),
  get-options-dict => %(:is-symbol<g_application_command_line_get_options_dict>,  :returns(N-VariantDict)),
  get-platform-data => %(:is-symbol<g_application_command_line_get_platform_data>,  :returns(N-Variant)),
  get-stdin => %(:is-symbol<g_application_command_line_get_stdin>,  :returns(N-Object)),
  getenv => %(:is-symbol<g_application_command_line_getenv>,  :returns(Str), :parameters([Str])),
  print => %(:is-symbol<g_application_command_line_print>, :variable-list,  :parameters([Str])),
  printerr => %(:is-symbol<g_application_command_line_printerr>, :variable-list,  :parameters([Str])),
  set-exit-status => %(:is-symbol<g_application_command_line_set_exit_status>,  :parameters([gint])),
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
        :library(gio-lib())
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
