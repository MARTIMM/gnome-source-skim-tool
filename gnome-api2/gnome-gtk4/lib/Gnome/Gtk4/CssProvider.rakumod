=comment Package: Gtk4, C-Source: cssprovider
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::Object:api<2>;
use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::T-array:api<2>;
use Gnome::Gtk4::R-StyleProvider:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::CssProvider:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;
also does Gnome::Gtk4::R-StyleProvider;

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
      :w2<parsing-error>,
    );

    # Signals from interfaces
    self._add_gtk_style_provider_signal_types($?CLASS.^name)
      if self.^can('_add_gtk_style_provider_signal_types');
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::CssProvider' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCssProvider');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-cssprovider => %( :type(Constructor), :is-symbol<gtk_css_provider_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  load-from-bytes => %(:is-symbol<gtk_css_provider_load_from_bytes>, :parameters([N-Object]), ),
  load-from-data => %(:is-symbol<gtk_css_provider_load_from_data>, :parameters([Str, gssize]), :deprecated, :deprecated-version<4.12>, ),
  load-from-file => %(:is-symbol<gtk_css_provider_load_from_file>, :parameters([N-Object]), ),
  load-from-path => %(:is-symbol<gtk_css_provider_load_from_path>, :parameters([Str]), ),
  load-from-resource => %(:is-symbol<gtk_css_provider_load_from_resource>, :parameters([Str]), ),
  load-from-string => %(:is-symbol<gtk_css_provider_load_from_string>, :parameters([Str]), ),
  load-named => %(:is-symbol<gtk_css_provider_load_named>, :parameters([Str, Str]), ),
  to-string => %(:is-symbol<gtk_css_provider_to_string>, :returns(Str), ),
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
    my $r;
    my $native-object = self.get-native-object-no-reffing;
    $r = self._do_gtk_style_provider_fallback-v2(
      $name, $_fallback-v2-ok, $!routine-caller, @arguments, $native-object
    ) if self.^can('_do_gtk_style_provider_fallback-v2');
    return $r if $_fallback-v2-ok;

    callsame;
  }
}
