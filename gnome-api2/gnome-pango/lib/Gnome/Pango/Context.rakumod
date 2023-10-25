# Command to generate: generate.raku -c -t Pango context
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


use Gnome::GObject::Object:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;
#use Gnome::Pango::N-FontDescription:api<2>;
#use Gnome::Pango::N-FontMetrics:api<2>;
#use Gnome::Pango::N-Language:api<2>;
#use Gnome::Pango::N-Matrix:api<2>;
use Gnome::Pango::T-Direction:api<2>;
use Gnome::Pango::T-Gravity:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Pango::Context:auth<github:MARTIMM>:api<2>;
also is Gnome::GObject::Object;

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
  $!routine-caller .= new( :library(pango-lib()), :sub-prefix<pango_context_>);

  # Prevent creating wrong widgets
  if self.^name eq 'Gnome::Pango::Context' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    die X::Gnome.new(:message("Native object not defined"))
      unless self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('PangoContext');
  }
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Constructors]-------------------------------------------------------------
  new-context => %( :type(Constructor), :isnew, :returns(N-GObject) ),

  #--[Methods]------------------------------------------------------------------
  changed => %(),
  get-base-dir => %( :returns(GEnum), :cnv-return(PangoDirection)),
  get-base-gravity => %( :returns(GEnum), :cnv-return(PangoGravity)),
  #get-font-description => %( :returns(N-FontDescription )),
  get-font-map => %( :returns(N-GObject)),
  get-gravity => %( :returns(GEnum), :cnv-return(PangoGravity)),
  get-gravity-hint => %( :returns(GEnum), :cnv-return(PangoGravityHint)),
  #get-language => %( :returns(N-Language )),
  #get-matrix => %( :returns(N-Matrix )),
  #get-metrics => %( :returns(N-FontMetrics ), :parameters([N-FontDescription , N-Language ])),
  get-round-glyph-positions => %( :returns(gboolean), :cnv-return(Bool)),
  get-serial => %( :returns(guint)),
  list-families => %( :parameters([CArray[N-GObject], gint-ptr])),
  #load-font => %( :returns(N-GObject), :parameters([N-FontDescription ])),
  #load-fontset => %( :returns(N-GObject), :parameters([N-FontDescription , N-Language ])),
  set-base-dir => %( :parameters([GEnum])),
  set-base-gravity => %( :parameters([GEnum])),
  #set-font-description => %( :parameters([N-FontDescription ])),
  set-font-map => %( :parameters([N-GObject])),
  set-gravity-hint => %( :parameters([GEnum])),
  #set-language => %( :parameters([N-Language ])),
  #set-matrix => %( :parameters([N-Matrix ])),
  set-round-glyph-positions => %( :parameters([gboolean])),
);

#-------------------------------------------------------------------------------
# This method is recognized in class Gnome::N::TopLevelClassSupport.
method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
  if $methods{$name}:exists {
    $_fallback-v2-ok = True;
    if $methods{$name}<type>:exists and $methods{$name}<type> eq 'Constructor' {
      my Gnome::N::GnomeRoutineCaller $routine-caller .= new(
        :library(pango-lib()), :sub-prefix<pango_context_>
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
