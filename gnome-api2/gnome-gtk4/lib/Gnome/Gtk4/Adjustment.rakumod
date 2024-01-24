=comment Package: Gtk4, C-Source: adjustment
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::InitiallyUnowned:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Adjustment:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::InitiallyUnowned;

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
      :w0<changed value-changed>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Adjustment' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAdjustment');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-adjustment => %( :type(Constructor), :is-symbol<gtk_adjustment_new>, :returns(N-Object), :parameters([ gdouble, gdouble, gdouble, gdouble, gdouble, gdouble])),

  #--[Methods]------------------------------------------------------------------
  clamp-page => %(:is-symbol<gtk_adjustment_clamp_page>,  :parameters([gdouble, gdouble])),
  configure => %(:is-symbol<gtk_adjustment_configure>,  :parameters([gdouble, gdouble, gdouble, gdouble, gdouble, gdouble])),
  get-lower => %(:is-symbol<gtk_adjustment_get_lower>,  :returns(gdouble)),
  get-minimum-increment => %(:is-symbol<gtk_adjustment_get_minimum_increment>,  :returns(gdouble)),
  get-page-increment => %(:is-symbol<gtk_adjustment_get_page_increment>,  :returns(gdouble)),
  get-page-size => %(:is-symbol<gtk_adjustment_get_page_size>,  :returns(gdouble)),
  get-step-increment => %(:is-symbol<gtk_adjustment_get_step_increment>,  :returns(gdouble)),
  get-upper => %(:is-symbol<gtk_adjustment_get_upper>,  :returns(gdouble)),
  get-value => %(:is-symbol<gtk_adjustment_get_value>,  :returns(gdouble)),
  set-lower => %(:is-symbol<gtk_adjustment_set_lower>,  :parameters([gdouble])),
  set-page-increment => %(:is-symbol<gtk_adjustment_set_page_increment>,  :parameters([gdouble])),
  set-page-size => %(:is-symbol<gtk_adjustment_set_page_size>,  :parameters([gdouble])),
  set-step-increment => %(:is-symbol<gtk_adjustment_set_step_increment>,  :parameters([gdouble])),
  set-upper => %(:is-symbol<gtk_adjustment_set_upper>,  :parameters([gdouble])),
  set-value => %(:is-symbol<gtk_adjustment_set_value>,  :parameters([gdouble])),
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
