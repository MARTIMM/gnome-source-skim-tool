=comment Package: Gtk4, C-Source: entrybuffer
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::GObject::Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::EntryBuffer:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
      :w2<deleted-text>,
      :w3<inserted-text>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::EntryBuffer' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkEntryBuffer');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-entrybuffer => %( :type(Constructor), :is-symbol<gtk_entry_buffer_new>, :returns(N-Object), :parameters([ Str, gint]), ),

  #--[Methods]------------------------------------------------------------------
  delete-text => %(:is-symbol<gtk_entry_buffer_delete_text>, :returns(guint), :parameters([guint, gint]), ),
  emit-deleted-text => %(:is-symbol<gtk_entry_buffer_emit_deleted_text>, :parameters([guint, guint]), ),
  emit-inserted-text => %(:is-symbol<gtk_entry_buffer_emit_inserted_text>, :parameters([guint, Str, guint]), ),
  get-bytes => %(:is-symbol<gtk_entry_buffer_get_bytes>, :returns(gsize), ),
  get-length => %(:is-symbol<gtk_entry_buffer_get_length>, :returns(guint), ),
  get-max-length => %(:is-symbol<gtk_entry_buffer_get_max_length>, :returns(gint), ),
  get-text => %(:is-symbol<gtk_entry_buffer_get_text>, :returns(Str), ),
  insert-text => %(:is-symbol<gtk_entry_buffer_insert_text>, :returns(guint), :parameters([guint, Str, gint]), ),
  set-max-length => %(:is-symbol<gtk_entry_buffer_set_max_length>, :parameters([gint]), ),
  set-text => %(:is-symbol<gtk_entry_buffer_set_text>, :parameters([Str, gint]), ),
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
