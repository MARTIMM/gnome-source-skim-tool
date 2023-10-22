# Command to generate: generate.raku -c -t Gtk4 AboutDialog
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-Aboutdialog:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
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
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_about_dialog_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::AboutDialog' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAboutDialog');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-aboutdialog => %( :type(Constructor), :isnew, :returns(N-GObject), ),

  #--[Methods]------------------------------------------------------------------
  add-credit-section => %( :parameters([Str, gchar-pptr])),
  get-artists => %( :returns(gchar-pptr)),
  get-authors => %( :returns(gchar-pptr)),
  get-comments => %( :returns(Str)),
  get-copyright => %( :returns(Str)),
  get-documenters => %( :returns(gchar-pptr)),
  get-license => %( :returns(Str)),
  get-license-type => %( :returns(GEnum), :cnv-return(GtkLicense)),
  get-logo => %( :returns(N-GObject)),
  get-logo-icon-name => %( :returns(Str)),
  get-program-name => %( :returns(Str)),
  get-system-information => %( :returns(Str)),
  get-translator-credits => %( :returns(Str)),
  get-version => %( :returns(Str)),
  get-website => %( :returns(Str)),
  get-website-label => %( :returns(Str)),
  get-wrap-license => %( :returns(gboolean), :cnv-return(Bool)),
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
  set-system-information => %( :parameters([Str])),
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
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_about_dialog_>
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
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
