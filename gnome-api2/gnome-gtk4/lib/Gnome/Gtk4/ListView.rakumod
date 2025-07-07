=comment Package: Gtk4, C-Source: listview
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;

use Cairo;


use Gnome::Gtk4::ListBase:api<2>;
use Gnome::Gtk4::N-ScrollInfo:api<2>;
use Gnome::Gtk4::T-enums:api<2>;
use Gnome::Gtk4::T-types:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::ListView:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::ListBase;

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
      :w1<activate>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::ListView' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkListView');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-listview => %( :type(Constructor), :is-symbol<gtk_list_view_new>, :returns(N-Object), :parameters([ N-Object, N-Object]), ),

  #--[Methods]------------------------------------------------------------------
  get-enable-rubberband => %(:is-symbol<gtk_list_view_get_enable_rubberband>, :returns(gboolean), ),
  get-factory => %(:is-symbol<gtk_list_view_get_factory>, :returns(N-Object), ),
  get-header-factory => %(:is-symbol<gtk_list_view_get_header_factory>, :returns(N-Object), ),
  get-model => %(:is-symbol<gtk_list_view_get_model>, :returns(N-Object), ),
  get-show-separators => %(:is-symbol<gtk_list_view_get_show_separators>, :returns(gboolean), ),
  get-single-click-activate => %(:is-symbol<gtk_list_view_get_single_click_activate>, :returns(gboolean), ),
  get-tab-behavior => %(:is-symbol<gtk_list_view_get_tab_behavior>,  :returns(GEnum), :cnv-return(GtkListTabBehavior)),
  scroll-to => %(:is-symbol<gtk_list_view_scroll_to>, :parameters([guint, GFlag, N-Object]), ),
  set-enable-rubberband => %(:is-symbol<gtk_list_view_set_enable_rubberband>, :parameters([gboolean]), ),
  set-factory => %(:is-symbol<gtk_list_view_set_factory>, :parameters([N-Object]), ),
  set-header-factory => %(:is-symbol<gtk_list_view_set_header_factory>, :parameters([N-Object]), ),
  set-model => %(:is-symbol<gtk_list_view_set_model>, :parameters([N-Object]), ),
  set-show-separators => %(:is-symbol<gtk_list_view_set_show_separators>, :parameters([gboolean]), ),
  set-single-click-activate => %(:is-symbol<gtk_list_view_set_single_click_activate>, :parameters([gboolean]), ),
  set-tab-behavior => %(:is-symbol<gtk_list_view_set_tab_behavior>, :parameters([GEnum]), ),
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
