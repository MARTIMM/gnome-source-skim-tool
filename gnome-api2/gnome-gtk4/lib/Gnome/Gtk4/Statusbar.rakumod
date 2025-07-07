=comment Package: Gtk4, C-Source: statusbar
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::Widget:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Statusbar:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Widget;

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
    'Gnome::Gtk4::Statusbar', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w2<text-pushed text-popped>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Statusbar' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkStatusbar');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-statusbar => %( :type(Constructor), :is-symbol<gtk_statusbar_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),

  #--[Methods]------------------------------------------------------------------
  get-context-id => %(:is-symbol<gtk_statusbar_get_context_id>, :returns(guint), :parameters([Str]), :deprecated, :deprecated-version<4.10>, ),
  pop => %(:is-symbol<gtk_statusbar_pop>, :parameters([guint]), :deprecated, :deprecated-version<4.10>, ),
  push => %(:is-symbol<gtk_statusbar_push>, :returns(guint), :parameters([guint, Str]), :deprecated, :deprecated-version<4.10>, ),
  remove => %(:is-symbol<gtk_statusbar_remove>, :parameters([guint, guint]), :deprecated, :deprecated-version<4.10>, ),
  remove-all => %(:is-symbol<gtk_statusbar_remove_all>, :parameters([guint]), :deprecated, :deprecated-version<4.10>, ),
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
