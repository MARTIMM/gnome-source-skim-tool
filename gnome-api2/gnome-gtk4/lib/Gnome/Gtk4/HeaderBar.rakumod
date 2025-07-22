=comment Package: Gtk4, C-Source: headerbar
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::HeaderBar:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
  if self.^name eq 'Gnome::Gtk4::HeaderBar' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkHeaderBar');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-headerbar => %( :type(Constructor), :is-symbol<gtk_header_bar_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  get-decoration-layout => %(:is-symbol<gtk_header_bar_get_decoration_layout>, :returns(Str), ),
  get-show-title-buttons => %(:is-symbol<gtk_header_bar_get_show_title_buttons>, :returns(gboolean), :cnv-return(Bool), ),
  get-title-widget => %(:is-symbol<gtk_header_bar_get_title_widget>, :returns(N-Object), ),
  pack-end => %(:is-symbol<gtk_header_bar_pack_end>, :parameters([N-Object]), ),
  pack-start => %(:is-symbol<gtk_header_bar_pack_start>, :parameters([N-Object]), ),
  remove => %(:is-symbol<gtk_header_bar_remove>, :parameters([N-Object]), ),
  set-decoration-layout => %(:is-symbol<gtk_header_bar_set_decoration_layout>, :parameters([Str]), ),
  set-show-title-buttons => %(:is-symbol<gtk_header_bar_set_show_title_buttons>, :parameters([gboolean]), ),
  set-title-widget => %(:is-symbol<gtk_header_bar_set_title_widget>, :parameters([N-Object]), ),
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
