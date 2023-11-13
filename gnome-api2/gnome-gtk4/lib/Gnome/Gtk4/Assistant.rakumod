# Command to generate: generate.raku -c -t Gtk4 assistant
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::Gtk4::T-Assistant:api<2>;
use Gnome::Gtk4::Window:api<2>;
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
  # Add signal administration info.
  unless $signals-added {
    self.add-signal-types( $?CLASS.^name,
      :w0<escape apply close cancel>,
      :w1<prepare>,
    );
    $signals-added = True;
  }

  # Initialize helper
  $!routine-caller .= new( :library(gtk4-lib()), :sub-prefix<gtk_assistant_>);

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
  new-assistant => %( :type(Constructor), :isnew, :returns(N-Object), ),

  #--[Methods]------------------------------------------------------------------
  add-action-widget => %( :parameters([N-Object])),
  append-page => %( :returns(gint), :parameters([N-Object])),
  commit => %(),
  get-current-page => %( :returns(gint)),
  get-n-pages => %( :returns(gint)),
  get-nth-page => %( :returns(N-Object), :parameters([gint])),
  get-page => %( :returns(N-Object), :parameters([N-Object])),
  get-page-complete => %( :returns(gboolean), :cnv-return(Bool), :parameters([N-Object])),
  get-page-title => %( :returns(Str), :parameters([N-Object])),
  get-page-type => %( :returns(GEnum), :cnv-return(GtkAssistantPageType), :parameters([N-Object])),
  get-pages => %( :returns(N-Object)),
  insert-page => %( :returns(gint), :parameters([N-Object, gint])),
  next-page => %(),
  prepend-page => %( :returns(gint), :parameters([N-Object])),
  previous-page => %(),
  remove-action-widget => %( :parameters([N-Object])),
  remove-page => %( :parameters([gint])),
  set-current-page => %( :parameters([gint])),
  #set-forward-page-func => %( :parameters([:( gint $current-page, gpointer $data --> gint ), gpointer, ])),
  set-page-complete => %( :parameters([N-Object, gboolean])),
  set-page-title => %( :parameters([N-Object, Str])),
  set-page-type => %( :parameters([N-Object, GEnum])),
  update-buttons-state => %(),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(gtk4-lib()), :sub-prefix<gtk_assistant_>
      );

      # Check the function name. 
      return self.bless(
        :native-object(
          $routine-caller.call-native-sub( $name, @arguments, $methods)
        )
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
