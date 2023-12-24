=comment Package: Gtk4, C-Source: aboutdialog
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-AboutDialog:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::AboutDialog:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Window;

#-------------------------------------------------------------------------------
#--[BUILD variables]------------------------------------------------------------
#-------------------------------------------------------------------------------

# Define callable helper
has Gnome::N::GnomeRoutineCaller $!routine-caller;

# Add signal registration helper
my Bool $signals-added = False;

#-------------------------------------------------------------------------------
#--[BUILD submethod]------------------------------------------------------------
#-------------------------------------------------------------------------------

submethod BUILD ( *%options ) {
  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w1<activate-link>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::AboutDialog' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAboutDialog');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-aboutdialog => %( :type(Constructor), :is-symbol<gtk_about_dialog_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  add-credit-section => %(:is-symbol<gtk_about_dialog_add_credit_section>,  :parameters([Str, gchar-pptr])),
  get-artists => %(:is-symbol<gtk_about_dialog_get_artists>,  :returns(gchar-pptr)),
  get-authors => %(:is-symbol<gtk_about_dialog_get_authors>,  :returns(gchar-pptr)),
  get-comments => %(:is-symbol<gtk_about_dialog_get_comments>,  :returns(Str)),
  get-copyright => %(:is-symbol<gtk_about_dialog_get_copyright>,  :returns(Str)),
  get-documenters => %(:is-symbol<gtk_about_dialog_get_documenters>,  :returns(gchar-pptr)),
  get-license => %(:is-symbol<gtk_about_dialog_get_license>,  :returns(Str)),
  get-license-type => %(:is-symbol<gtk_about_dialog_get_license_type>,  :returns(GEnum), :cnv-return(GtkLicense)),
  get-logo => %(:is-symbol<gtk_about_dialog_get_logo>,  :returns(N-Object)),
  get-logo-icon-name => %(:is-symbol<gtk_about_dialog_get_logo_icon_name>,  :returns(Str)),
  get-program-name => %(:is-symbol<gtk_about_dialog_get_program_name>,  :returns(Str)),
  get-system-information => %(:is-symbol<gtk_about_dialog_get_system_information>,  :returns(Str)),
  get-translator-credits => %(:is-symbol<gtk_about_dialog_get_translator_credits>,  :returns(Str)),
  get-version => %(:is-symbol<gtk_about_dialog_get_version>,  :returns(Str)),
  get-website => %(:is-symbol<gtk_about_dialog_get_website>,  :returns(Str)),
  get-website-label => %(:is-symbol<gtk_about_dialog_get_website_label>,  :returns(Str)),
  get-wrap-license => %(:is-symbol<gtk_about_dialog_get_wrap_license>,  :returns(gboolean), :cnv-return(Bool)),
  set-artists => %(:is-symbol<gtk_about_dialog_set_artists>,  :parameters([gchar-pptr])),
  set-authors => %(:is-symbol<gtk_about_dialog_set_authors>,  :parameters([gchar-pptr])),
  set-comments => %(:is-symbol<gtk_about_dialog_set_comments>,  :parameters([Str])),
  set-copyright => %(:is-symbol<gtk_about_dialog_set_copyright>,  :parameters([Str])),
  set-documenters => %(:is-symbol<gtk_about_dialog_set_documenters>,  :parameters([gchar-pptr])),
  set-license => %(:is-symbol<gtk_about_dialog_set_license>,  :parameters([Str])),
  set-license-type => %(:is-symbol<gtk_about_dialog_set_license_type>,  :parameters([GEnum])),
  set-logo => %(:is-symbol<gtk_about_dialog_set_logo>,  :parameters([N-Object])),
  set-logo-icon-name => %(:is-symbol<gtk_about_dialog_set_logo_icon_name>,  :parameters([Str])),
  set-program-name => %(:is-symbol<gtk_about_dialog_set_program_name>,  :parameters([Str])),
  set-system-information => %(:is-symbol<gtk_about_dialog_set_system_information>,  :parameters([Str])),
  set-translator-credits => %(:is-symbol<gtk_about_dialog_set_translator_credits>,  :parameters([Str])),
  set-version => %(:is-symbol<gtk_about_dialog_set_version>,  :parameters([Str])),
  set-website => %(:is-symbol<gtk_about_dialog_set_website>,  :parameters([Str])),
  set-website-label => %(:is-symbol<gtk_about_dialog_set_website_label>,  :parameters([Str])),
  set-wrap-license => %(:is-symbol<gtk_about_dialog_set_wrap_license>,  :parameters([gboolean])),
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
        :library(gtk4-lib())
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
