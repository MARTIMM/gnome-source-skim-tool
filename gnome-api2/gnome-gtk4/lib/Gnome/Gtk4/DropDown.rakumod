=comment Package: Gtk4, C-Source: dropdown
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::T-stringfilter:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::DropDown:auth<github:MARTIMM>:api<2>;
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

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<activate>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::DropDown' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkDropDown');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-dropdown => %( :type(Constructor), :is-symbol<gtk_drop_down_new>, :returns(N-Object), :parameters([ N-Object, N-Object]), ),
  new-from-strings => %( :type(Constructor), :is-symbol<gtk_drop_down_new_from_strings>, :returns(N-Object), :parameters([ gchar-pptr]), ),

  #--[Methods]------------------------------------------------------------------
  get-enable-search => %(:is-symbol<gtk_drop_down_get_enable_search>, :returns(gboolean), ),
  get-expression => %(:is-symbol<gtk_drop_down_get_expression>, :returns(N-Object), ),
  get-factory => %(:is-symbol<gtk_drop_down_get_factory>, :returns(N-Object), ),
  get-header-factory => %(:is-symbol<gtk_drop_down_get_header_factory>, :returns(N-Object), ),
  get-list-factory => %(:is-symbol<gtk_drop_down_get_list_factory>, :returns(N-Object), ),
  get-model => %(:is-symbol<gtk_drop_down_get_model>, :returns(N-Object), ),
  get-search-match-mode => %(:is-symbol<gtk_drop_down_get_search_match_mode>,  :returns(GEnum), :cnv-return(GtkStringFilterMatchMode)),
  get-selected => %(:is-symbol<gtk_drop_down_get_selected>, :returns(guint), ),
  get-selected-item => %(:is-symbol<gtk_drop_down_get_selected_item>, :returns(gpointer), ),
  get-show-arrow => %(:is-symbol<gtk_drop_down_get_show_arrow>, :returns(gboolean), ),
  set-enable-search => %(:is-symbol<gtk_drop_down_set_enable_search>, :parameters([gboolean]), ),
  set-expression => %(:is-symbol<gtk_drop_down_set_expression>, :parameters([N-Object]), ),
  set-factory => %(:is-symbol<gtk_drop_down_set_factory>, :parameters([N-Object]), ),
  set-header-factory => %(:is-symbol<gtk_drop_down_set_header_factory>, :parameters([N-Object]), ),
  set-list-factory => %(:is-symbol<gtk_drop_down_set_list_factory>, :parameters([N-Object]), ),
  set-model => %(:is-symbol<gtk_drop_down_set_model>, :parameters([N-Object]), ),
  set-search-match-mode => %(:is-symbol<gtk_drop_down_set_search_match_mode>, :parameters([GEnum]), ),
  set-selected => %(:is-symbol<gtk_drop_down_set_selected>, :parameters([guint]), ),
  set-show-arrow => %(:is-symbol<gtk_drop_down_set_show_arrow>, :parameters([gboolean]), ),
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
