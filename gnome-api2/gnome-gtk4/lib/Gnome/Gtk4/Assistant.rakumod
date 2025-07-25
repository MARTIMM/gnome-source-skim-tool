=comment Package: Gtk4, C-Source: assistant
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;




use Gnome::Gtk4::T-assistant:api<2>;
use Gnome::Gtk4::Window:api<2>;
#use Gnome::N:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Assistant:auth<github:MARTIMM>:api<2>;
also is Gnome::Gtk4::Window;

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
    'Gnome::Gtk4::Assistant', ', Str, ',
    '4.10', Str,
    :class, :gnome-lib(gtk4-lib())  
  );

  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<cancel close escape apply>,
      :w1<prepare>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Assistant' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkAssistant');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-assistant => %( :type(Constructor), :is-symbol<gtk_assistant_new>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),

  #--[Methods]------------------------------------------------------------------
  add-action-widget => %(:is-symbol<gtk_assistant_add_action_widget>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  append-page => %(:is-symbol<gtk_assistant_append_page>, :returns(gint), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  commit => %(:is-symbol<gtk_assistant_commit>, :deprecated, :deprecated-version<4.10>, ),
  get-current-page => %(:is-symbol<gtk_assistant_get_current_page>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-n-pages => %(:is-symbol<gtk_assistant_get_n_pages>, :returns(gint), :deprecated, :deprecated-version<4.10>, ),
  get-nth-page => %(:is-symbol<gtk_assistant_get_nth_page>, :returns(N-Object), :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  get-page => %(:is-symbol<gtk_assistant_get_page>, :returns(N-Object), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-page-complete => %(:is-symbol<gtk_assistant_get_page_complete>, :returns(gboolean), :cnv-return(Bool), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-page-title => %(:is-symbol<gtk_assistant_get_page_title>, :returns(Str), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-page-type => %(:is-symbol<gtk_assistant_get_page_type>,  :returns(GEnum), :cnv-return(GtkAssistantPageType),:parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  get-pages => %(:is-symbol<gtk_assistant_get_pages>, :returns(N-Object), :deprecated, :deprecated-version<4.10>, ),
  insert-page => %(:is-symbol<gtk_assistant_insert_page>, :returns(gint), :parameters([N-Object, gint]), :deprecated, :deprecated-version<4.10>, ),
  next-page => %(:is-symbol<gtk_assistant_next_page>, :deprecated, :deprecated-version<4.10>, ),
  prepend-page => %(:is-symbol<gtk_assistant_prepend_page>, :returns(gint), :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  previous-page => %(:is-symbol<gtk_assistant_previous_page>, :deprecated, :deprecated-version<4.10>, ),
  remove-action-widget => %(:is-symbol<gtk_assistant_remove_action_widget>, :parameters([N-Object]), :deprecated, :deprecated-version<4.10>, ),
  remove-page => %(:is-symbol<gtk_assistant_remove_page>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-current-page => %(:is-symbol<gtk_assistant_set_current_page>, :parameters([gint]), :deprecated, :deprecated-version<4.10>, ),
  set-forward-page-func => %(:is-symbol<gtk_assistant_set_forward_page_func>, :parameters([:( gint $current-page, gpointer $data ), gpointer, :( gpointer $data )]), :deprecated, :deprecated-version<4.10>, ),
  set-page-complete => %(:is-symbol<gtk_assistant_set_page_complete>, :parameters([N-Object, gboolean]), :deprecated, :deprecated-version<4.10>, ),
  set-page-title => %(:is-symbol<gtk_assistant_set_page_title>, :parameters([N-Object, Str]), :deprecated, :deprecated-version<4.10>, ),
  set-page-type => %(:is-symbol<gtk_assistant_set_page_type>, :parameters([N-Object, GEnum]), :deprecated, :deprecated-version<4.10>, ),
  update-buttons-state => %(:is-symbol<gtk_assistant_update_buttons_state>, :deprecated, :deprecated-version<4.10>, ),
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
