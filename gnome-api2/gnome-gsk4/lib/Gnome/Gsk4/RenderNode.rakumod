=comment Package: Gsk4, C-Source: rendernode
use v6.d;

#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;


#use :api<2>;
#use Gnome::Cairo::N-Context:api<2>;
#use Gnome::Cairo::T-undefined-module-name:api<2>;
#use Gnome::Glib::N-Bytes:api<2>;
use Gnome::Glib::N-Error:api<2>;
#use Gnome::Glib::T-array:api<2>;
#use Gnome::Glib::T-error:api<2>;
use Gnome::Graphene::N-Rect:api<2>;
use Gnome::Graphene::T-rect:api<2>;
#use Gnome::Gsk4::N-ParseLocation:api<2>;
use Gnome::Gsk4::T-enums:api<2>;
use Gnome::Gsk4::T-rendernode:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::GnomeRoutineCaller:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::X:api<2>;


#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gsk4::RenderNode:auth<github:MARTIMM>:api<2>;
#also is ;

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
  if self.^name eq 'Gnome::Gsk4::RenderNode' {
    # If already initialized using ':$native-object', ':$build-id', or
    # any '.new*()' constructor, the object is valid.
    note "Native object not defined, .is-valid() will return False" if $Gnome::N::x-debug and !self.is-valid;

    # only after creating the native-object, the gtype is known
    self._set-class-info('GskRenderNode');
  }
}

# Next two methods need checks for proper referencing or cleanup 
method native-object-ref ( $n-native-object ) {
  $n-native-object
}

method native-object-unref ( $n-native-object ) {
  self._fallback-v2( 'unref', my Bool $x);
}

#-------------------------------------------------------------------------------
#--[Native Routine Definitions]-------------------------------------------------
#-------------------------------------------------------------------------------

my Hash $methods = %(

  #--[Methods]------------------------------------------------------------------
  draw => %(:is-symbol<gsk_render_node_draw>,  :parameters([N-Object])),
  get-bounds => %(:is-symbol<gsk_render_node_get_bounds>,  :parameters([N-Object])),
  get-node-type => %(:is-symbol<gsk_render_node_get_node_type>,  :returns(GEnum), :cnv-return(GskRenderNodeType)),
  ref => %(:is-symbol<gsk_render_node_ref>,  :returns(N-Object)),
  serialize => %(:is-symbol<gsk_render_node_serialize>,  :returns(N-Object)),
  unref => %(:is-symbol<gsk_render_node_unref>, ),
  write-to-file => %(:is-symbol<gsk_render_node_write_to_file>,  :returns(gboolean), :cnv-return(Bool), :parameters([Str, CArray[N-Error]])),

  #--[Functions]----------------------------------------------------------------
  deserialize => %( :type(Function), :is-symbol<gsk_render_node_deserialize>,  :returns(N-Object), :parameters([ N-Object, :( N-Object $start, N-Object $end, N-Object $error, gpointer $user-data ), gpointer])),
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
