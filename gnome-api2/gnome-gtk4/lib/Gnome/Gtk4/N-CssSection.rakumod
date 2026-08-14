=comment Package: Gtk4, C-Source: csssection
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;



use Gnome::Glib::T-array:api<2>;
#use Gnome::Glib::T-string:api<2>;
#use Gnome::Gtk4::T-csslocation:api<2>;
#use Gnome::Gtk4::T-csssection:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::TopLevelClassSupport:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Structure Declaration]------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::N-CssSection:auth<github:MARTIMM>:api<2>;
also is Gnome::N::TopLevelClassSupport;

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
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::CssSection' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCssSection');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
#  self._fallback-v2( 'free', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-csssection => %( :type(Constructor), :is-symbol<gtk_css_section_new>, :returns(N-Object), :parameters([ N-Object, N-Object, N-Object]), ),
  new-with-bytes => %( :type(Constructor), :is-symbol<gtk_css_section_new_with_bytes>, :returns(N-Object), :parameters([ N-Object, N-Object, N-Object, N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  get-bytes => %(:is-symbol<gtk_css_section_get_bytes>, :returns(N-Object), ),
  get-end-location => %(:is-symbol<gtk_css_section_get_end_location>, :returns(N-Object), ),
  get-file => %(:is-symbol<gtk_css_section_get_file>, :returns(N-Object), ),
  get-parent => %(:is-symbol<gtk_css_section_get_parent>, :returns(N-Object), ),
  get-start-location => %(:is-symbol<gtk_css_section_get_start_location>, :returns(N-Object), ),
  print => %(:is-symbol<gtk_css_section_print>, :parameters([N-Object]), ),
  ref => %(:is-symbol<gtk_css_section_ref>, :returns(N-Object), ),
  to-string => %(:is-symbol<gtk_css_section_to_string>, :returns(Str), ),
  unref => %(:is-symbol<gtk_css_section_unref>, ),
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
