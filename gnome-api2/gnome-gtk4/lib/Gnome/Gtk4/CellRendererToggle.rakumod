=comment Package: Gtk4, C-Source: cellrenderertoggle
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::CellRenderer:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::CellRendererToggle:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::CellRenderer;

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

  Gnome::N::deprecate(
    'Gnome::Gtk4::CellRendererToggle', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w1<toggled>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::CellRendererToggle' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCellRendererToggle');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-cellrenderertoggle => %( :type(Constructor), :is-symbol<gtk_cell_renderer_toggle_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),

  #--[Methods]------------------------------------------------------------------
  get-activatable => %(:is-symbol<gtk_cell_renderer_toggle_get_activatable>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  get-active => %(:is-symbol<gtk_cell_renderer_toggle_get_active>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  get-radio => %(:is-symbol<gtk_cell_renderer_toggle_get_radio>,  :returns(gboolean), :cnv-return(Bool),:deprecated, :deprecated-version<4.10>, ),
  set-activatable => %(:is-symbol<gtk_cell_renderer_toggle_set_activatable>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
  set-active => %(:is-symbol<gtk_cell_renderer_toggle_set_active>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
  set-radio => %(:is-symbol<gtk_cell_renderer_toggle_set_radio>,  :parameters([gboolean]),:deprecated, :deprecated-version<4.10>, ),
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
