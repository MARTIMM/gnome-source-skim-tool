# Command to generate: gnome-source-skim-tool.raku -c -v Gtk3 aboutdialog
use v6;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Gtk3::Dialog:api<2>;
#use Gnome::Gtk3::T-Aboutdialog:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk3::AboutDialog:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk3::Dialog;

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
  $!routine-caller .= new( :library(gtk-lib()), :sub-prefix<gtk_about_dialog_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk3::AboutDialog' or %options<GtkAboutDialog> {

    # If already initialized in some parent, the object is valid
    if self.is-valid { }

    # Check if common options are handled by some parent
    elsif %options<native-object>:exists { }
    elsif %options<build-id>:exists { }

    else {
      my N-GObject() $no;

      # Create default object
      $no = self._fallback-v2( 'new', my Bool $x);
      self._set-native-object($no);
      if ?$no {
        self._set-native-object($no);
      }

      else {
        die X::Gnome.new(:message('Native object for class Gnome::Gtk3::AboutDialog not created'));
      }
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAboutDialog');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new => %( :type(Constructor),:returns(N-GObject), ),

  #--[Methods]------------------------------------------------------------------
  add-credit-section => %( :parameters([Str, gchar-pptr])),
  get-artists => %( :returns(gchar-pptr)),
  get-authors => %( :returns(gchar-pptr)),
  get-comments => %( :returns(Str)),
  get-copyright => %( :returns(Str)),
  get-documenters => %( :returns(gchar-pptr)),
  get-license => %( :returns(Str)),
  get-license-type => %( :returns(GEnum), :type-name(GtkLicense)),
  get-logo => %( :returns(N-GObject)),
  get-logo-icon-name => %( :returns(Str)),
  get-program-name => %( :returns(Str)),
  get-translator-credits => %( :returns(Str)),
  get-version => %( :returns(Str)),
  get-website => %( :returns(Str)),
  get-website-label => %( :returns(Str)),
  get-wrap-license => %( :returns(gboolean)),
  set-artists => %( :parameters([gchar-pptr])),
  set-authors => %( :parameters([gchar-pptr])),
  set-comments => %( :parameters([Str])),
  set-copyright => %( :parameters([Str])),
  set-documenters => %( :parameters([gchar-pptr])),
  set-license => %( :parameters([Str])),
  set-license-type => %( :parameters([GEnum])),
  set-logo => %( :parameters([N-GObject])),
  set-logo-icon-name => %( :parameters([Str])),
  set-program-name => %( :parameters([Str])),
  set-translator-credits => %( :parameters([Str])),
  set-version => %( :parameters([Str])),
  set-website => %( :parameters([Str])),
  set-website-label => %( :parameters([Str])),
  set-wrap-license => %( :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    my $native-object = self.get-native-object-no-reffing;
    $_fallback-v2-ok = True;
    return $!routine-caller.call-native-sub(
      $name, @arguments, $methods, :$native-object
    );
  }

  else {
    callsame;
  }
}
