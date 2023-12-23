=comment Package: Gtk4, C-Source: calendar
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use Gnome::Glib::N-DateTime:api<2>;
use Gnome::Gtk4::Widget:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gtk4::Calendar:auth<github:MARTIMM>:api<2>;
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
      :w0<prev-month next-year next-month day-selected prev-year>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new(:library(gtk4-lib()));

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Gtk4::Calendar' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkCalendar');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-calendar => %( :type(Constructor), :is-symbol<gtk_calendar_new>, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  clear-marks => %(:is-symbol<gtk_calendar_clear_marks>, ),
  #get-date => %(:is-symbol<gtk_calendar_get_date>,  :returns(N-DateTime )),
  get-day-is-marked => %(:is-symbol<gtk_calendar_get_day_is_marked>,  :returns(gboolean), :cnv-return(Bool), :parameters([guint])),
  get-show-day-names => %(:is-symbol<gtk_calendar_get_show_day_names>,  :returns(gboolean), :cnv-return(Bool)),
  get-show-heading => %(:is-symbol<gtk_calendar_get_show_heading>,  :returns(gboolean), :cnv-return(Bool)),
  get-show-week-numbers => %(:is-symbol<gtk_calendar_get_show_week_numbers>,  :returns(gboolean), :cnv-return(Bool)),
  mark-day => %(:is-symbol<gtk_calendar_mark_day>,  :parameters([guint])),
  #select-day => %(:is-symbol<gtk_calendar_select_day>,  :parameters([N-DateTime ])),
  set-show-day-names => %(:is-symbol<gtk_calendar_set_show_day_names>,  :parameters([gboolean])),
  set-show-heading => %(:is-symbol<gtk_calendar_set_show_heading>,  :parameters([gboolean])),
  set-show-week-numbers => %(:is-symbol<gtk_calendar_set_show_week_numbers>,  :parameters([gboolean])),
  unmark-day => %(:is-symbol<gtk_calendar_unmark_day>,  :parameters([guint])),
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

      # Check the function name. 
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
