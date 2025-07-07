=comment Package: Gtk4, C-Source: stringfilter
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::Filter:api<2>;
use Gnome::Gtk4::T-stringfilter:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::StringFilter:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Filter;

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
  if self.^name eq 'Gnome::Gtk4::StringFilter' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkStringFilter');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-stringfilter => %( :type(Constructor), :is-symbol<gtk_string_filter_new>, :returns(N-Object), :parameters([ N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  get-expression => %(:is-symbol<gtk_string_filter_get_expression>, :returns(N-Object), ),
  get-ignore-case => %(:is-symbol<gtk_string_filter_get_ignore_case>, :returns(gboolean), ),
  get-match-mode => %(:is-symbol<gtk_string_filter_get_match_mode>,  :returns(GEnum), :cnv-return(GtkStringFilterMatchMode)),
  get-search => %(:is-symbol<gtk_string_filter_get_search>, :returns(Str), ),
  set-expression => %(:is-symbol<gtk_string_filter_set_expression>, :parameters([N-Object]), ),
  set-ignore-case => %(:is-symbol<gtk_string_filter_set_ignore_case>, :parameters([gboolean]), ),
  set-match-mode => %(:is-symbol<gtk_string_filter_set_match_mode>, :parameters([GEnum]), ),
  set-search => %(:is-symbol<gtk_string_filter_set_search>, :parameters([Str]), ),
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
