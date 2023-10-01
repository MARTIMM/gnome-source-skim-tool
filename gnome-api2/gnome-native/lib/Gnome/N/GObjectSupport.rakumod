
use v6;

use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
unit role Gnome::N::GObjectSupport:auth<github:MARTIMM>:api<2>;

my Hash $signal-types = {};

#`{{
# Check on native library initialization.
my Bool $gui-initialized = False;
my Bool $may-not-initialize-gui = False;

#-------------------------------------------------------------------------------
#TODO The library to use and its call to this method depend on which 
# package we need to use;
#   gtk-3 for Gnome::Gtk3 modules
#   gtk-4 for Gnome::Gtk4 modules
#   no call when from Gio, Cairo or Pango
method gtk-initialize ( Str $library ) {
#note "$?LINE {self.^mro}";

#`{{
  # check GTK+ init except when GtkApplication / GApplication is used
  $may-not-initialize-gui = [or]
    $may-not-initialize-gui,
    $gui-initialized,
    # check for Application from Gio. that one inherits from Object.
    # Application from Gtk3 inherits from Gio, so this test is always ok.
    $mro[0..*-3].gist ~~ m/'(Application) (Object)'/;

  unless $may-not-initialize-gui {
    if not $gui-initialized #`{{and !%options<skip-init>}} {
}}
note "$?LINE @*ARGS.gist()";

      # must setup gtk otherwise Raku will crash
      my $argc = int-ptr.new;
      $argc[0] = 1 + @*ARGS.elems;

      my $arg_arr = char-pptr.new;
      my Int $arg-count = 0;
      $arg_arr[$arg-count++] = $*PROGRAM.Str;
      for @*ARGS -> $arg {
        $arg_arr[$arg-count++] = $arg;
      }

      my $argv = char-ppptr.new;
      $argv[0] = $arg_arr;

      # call gtk_init_check
      my Callable $f = nativecast(
        :( gint-ptr $argc, char-ppptr $argv --> gboolean),
        cglobal( $library, 'gtk_init_check', gpointer)
      );
      $f( $argc, $argv);

#      _object_init_check( $argc, $argv);
      $gui-initialized = True;

      # now refill the ARGS list with left over commandline arguments
      @*ARGS = ();
      for ^$argc[0] -> $i {
        # skip first argument == programname
        next unless $i;
        @*ARGS.push: $argv[0][$i];
      }
#    }
#  }
}

#-------------------------------------------------------------------------------
# This sub belongs to GtkMain but is needed here.
#sub _object_init_check (
#  gint-ptr $argc, char-ppptr $argv
#  --> gboolean
#) is native(&gtk4-lib)
#  is symbol('gtk_init_check')
#  { * }
}}

#-------------------------------------------------------------------------------
method _set-native-object ( $n-native-object ) {
  if ? $n-native-object {
    # when object is set, create signal object too
    #$!g-signal .= new(:g-object($n-native-object));
  }

  # now call the one from TopLevelClassSupport
  callsame
}

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-GObject ) {
  _g_object_ref($n-native-object)
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
#  _g_object_free($n-native-object)
  _g_object_unref($n-native-object)
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
method add-signal-types ( Str $module-name, *%signal-descriptions --> Bool ) {

  # must store signal names under the class name because I found the use of
  # the same signal name with different handler signatures in different classes.
  $signal-types{$module-name} //= {};

  note "\nTest signal names for $module-name" if $Gnome::N::x-debug;
  for %signal-descriptions.kv -> $signal-type, $signal-names {
    my @names = $signal-names ~~ List ?? @$signal-names !! ($signal-names,);
    for @names -> $signal-name {
      if $signal-type ~~ any(<w0 w1 w2 w3 w4 w5 w6 w7 w8 w9 signal event nativewidget>) {
        note "  $module-name, $signal-name --> $signal-type"
          if $Gnome::N::x-debug;
        $signal-types{$module-name}{$signal-name} = $signal-type;
      }

      # TODO cleanup deprecated and not supported
      elsif $signal-type eq 'deprecated' {
        note "  $signal-name is deprecated" if $Gnome::N::x-debug;
      }

      elsif $signal-type eq 'notsupported' {
        note "  $signal-name is not supported" if $Gnome::N::x-debug;
      }

      else {
        note "  $signal-name is not yet supported" if $Gnome::N::x-debug;
      }
    }
  }

  True
}

#-------------------------------------------------------------------------------
#TM:2:register-signal:
=begin pod
=head2 register-signal

Register a handler to process a signal or an event. There are several types of callbacks which can be handled by this regstration. They can be controlled by using a named argument with a special name.

  method register-signal (
    $handler-object, Str:D $handler-name,
    Str:D $signal-name, *%user-options
    --> Int
  )

=item $handler-object; The object wherein the handler is defined.
=item $handler-name; The name of the method.
=begin item
$signal-name; The name of the event to be handled. Each gtk object has its own series of signals.
=end item

=begin item
%user-options; Any other user data in whatever type provided as one or more named arguments. These arguments are provided to the user handler when an event for the handler is fired. The names starting with '_' are reserved to provide other info to the user.

The following reserved named arguments are available;
  =item C<:$_widget>; The instance which registered the signal.
  =item C<:$_handler-id>; The handler id which is returned from the registration
  =item C<:$_native-object>; The native object provided by the caller.
  =begin code
    method some-button-click-handler (
      …,
      Gnome::Gtk3::Button() :_native-object($button)
    ) {
      …
    }
  =end code
=end item

The method returns a handler id which can be used for example to disconnect the callback later.

=head3 Callback handlers

=begin item
Simple handlers; e.g. a click event handler has only named arguments and are optional.
=end item

=begin item
Complex handlers (only a bit) also have positional arguments and B<MUST> be typed because they are checked to create a signature for the call to a native subroutine. You can use the raku native types like C<int32> but several types are automatically converted to native types. The types such as gboolean, etc are defined in B<Gnome::N::GlibToRakuTypes>.
  =begin table
  Raku type | Native glib type | Native Raku type
  ===============================================
  Bool      | gboolean         | int32
  UInt      | guint            | uint32/uint64
  Int       | gint             | int32/int64
  Num       | gfloat           | num32
  Rat       | gdouble          | num64
  =end table
=end item

=begin item
Some handlers must return a value and is used by the calling process. You B<MUST> describe this too in the andlers API, otherwise the returned value is thrown away.
=end item

=begin item
Any user options are provided via named arguments from the call to C<register-signal()>.
=end item

=head3 Example 1

An example of a registration and the handlers signature to handle a button click event.

  # Handler class with callback methods
  class ButtonHandlers {
    method click-button (
      Gnome::Gtk3::Button() :_native-object($button),
      Int :$_handler_id, :$my-option ) {
      …
    }
  }

  $button.register-signal(
    ButtonHandlers.new, 'click-button', 'clicked', :my-option(…)
  );


=head3 Example 2

An example where a keyboard press is handled.

  # Handler class with callback methods
  class KeyboardHandlers {
    method keyboard-handler (
      N-GdkEvent $event,
      Int :$_handler_id, :$my-option
      Gnome::Gtk3::Window() :_native-object($bwindow),
      --> gboolean
    ) {
      …

    }
  }

  $window.register-signal(
    KeyboardHandlers.new, 'keyboard-handler',
    'key-press-event', :my-option(…)
  );


=end pod

method register-signal (
  $handler-object, Str:D $handler-name, Str:D $signal-name, *%user-options
  --> Int
) {

  my Int $handler-id = 0;

  # don't register if handler is not available
  my Method $sh = $handler-object.^lookup($handler-name) // Method;
  if ? $sh {
    if $Gnome::N::x-debug {
      note "\nregister $handler-object\.$handler-name\() for signal $signal-name, options are ", %user-options;
    }

    # search for signal name defined by this class as well as its parent classes
    my Str $signal-type;
    my Str $module-name;
    my @module-names = self.^name, |(map( {.^name}, self.^parents));
    for @module-names -> $mn {
      note "  search in class: $mn, $signal-name" if $Gnome::N::x-debug;
      if $signal-types{$mn}:exists and ?$signal-types{$mn}{$signal-name} {
        $signal-type = $signal-types{$mn}{$signal-name};
        $module-name = $mn;
        note "  found key '$signal-type' for $mn" if $Gnome::N::x-debug;
        last;
      }
    }

    return False unless ?$signal-type;

    # self can't be closed over
    my $current-object = self;

    my %named-args = %user-options;
    %named-args<_widget> = $current-object;
    %named-args<_handler-id> = $handler-id;

    sub w0 ( N-GObject $w, gpointer $d ) is export {
      CATCH { default { .message.note; .backtrace.concise.note } }

      note "\nw0, $handler-name for $signal-name: %named-args.gist()"
        if $Gnome::N::x-debug;

      # Mu is not an accepted value for the NativeCall interface
      # _convert_g_signal_connect_object() in Signal makes it a gpointer
      %named-args<_native-object> := $w;
      my $retval = $handler-object."$handler-name"(|%named-args);

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w0 handler result: $retval";
      }

      $retval
    }

    sub w1( N-GObject $w, $h0, gpointer $d ) is export {
      CATCH { default { .message.note; .backtrace.concise.note } }

      note "\nw1, $handler-name for $signal-name: $h0, %named-args.gist()"
        if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args($h0);
#      $handler-object."$handler-name"( |@converted-args, |%named-args);
      %named-args<_native-object> := $w;
      my $retval = $handler-object."$handler-name"( $h0, |%named-args);

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w1 handler result: $retval";
      }

      $retval
    }

    sub w2( N-GObject $w, $h0, $h1, gpointer $d ) is export {
      CATCH { default { .message.note; .backtrace.concise.note } }

      note "\nw2, $handler-name for $signal-name: $h0, $h1, %named-args.gist()"
        if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1);
      %named-args<_native-object> := $w;
      my $retval = $handler-object."$handler-name"(
        $h0, $h1, |%named-args
      );

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w2 handler result: $retval";
      }

      $retval
    }

    sub w3( N-GObject $w, $h0, $h1, $h2, gpointer $d ) is export {
      CATCH { default { .message.note; .backtrace.concise.note } }

      note "\nw3, $handler-name for $signal-name: $h0, $h1, $h2, %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2);
      %named-args<_native-object> := $w;
      my $retval = $handler-object."$handler-name"(
        $h0, $h1, $h2, |%named-args
      );

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w3 handler result: $retval";
      }

      $retval
    }

    sub w4( N-GObject $w, $h0, $h1, $h2, $h3, gpointer $d ) is export {
      CATCH { default { .message.note; .backtrace.concise.note } }

      note "\nw4, $handler-name for $signal-name: $h0, $h1, $h2, $h3, %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2, $h3);
      %named-args<_native-object> := $w;
      my $retval = $handler-object."$handler-name"(
        $h0, $h1, $h2, $h3, |%named-args
      );

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w4 handler result: $retval";
      }

      $retval
    }

    sub w5(
      N-GObject $w, $h0, $h1, $h2, $h3, $h4, gpointer $d
    ) is export {
      CATCH { default { .message.note; .backtrace.concise.note } }

      note "\nw5, $handler-name for $signal-name: $h0, $h1, $h2, $h3, $h4, %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2, $h3, $h4);
      %named-args<_native-object> := $w;
      my $retval = $handler-object."$handler-name"(
        $h0, $h1, $h2, $h3, $h4, |%named-args
      );

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w5 handler result: $retval";
      }

      $retval
    }

    sub w6(
      N-GObject $w, $h0, $h1, $h2, $h3, $h4, $h5, gpointer $d
    ) is export {
      CATCH { default { .message.note; .backtrace.concise.note } }

      note "\nw6, $handler-name for $signal-name: $h0, $h1, $h2, $h3, $h4, $h5, %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2, $h3, $h4, $h5);
      %named-args<_native-object> := $w;
      my $retval = $handler-object."$handler-name"(
        $h0, $h1, $h2, $h3, $h4, $h5, |%named-args
      );

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w6 handler result: $retval";
      }

      $retval
    }

    # Set the handler for the specified signal
    state %shkeys = %( :&w0, :&w1, :&w2, :&w3, :&w4, :&w5, :&w6);
    my $no = self._get-native-object-no-reffing;
    $handler-id = self._convert_g_signal_connect_object(
      $no, $signal-name, $sh, %shkeys{$signal-type}
    );

    note "\nSignal type and name: $signal-type, $handler-id, $signal-name\nHandler: $sh.gist(),\n" if $Gnome::N::x-debug;
  }

  else {
    note "\nCannot register $handler-object, $handler-name, options: ",
      %user-options, ', method, not found' if $Gnome::N::x-debug;
  }

  $handler-id
}

#-------------------------------------------------------------------------------
# sub with conversion of user callback. $user-handler is used to get the types
# from, while the $provided-handler is an intermediate between native and user.
method _convert_g_signal_connect_object (
  N-GObject $instance, Str $detailed-signal,
  Callable $user-handler, Callable $provided-handler
  --> gulong
) {

  # create callback handlers signature using the users callback.
  # first argument is always a native widget.
  my @sub-parameter-list = (
    Parameter.new(type => N-GObject),     # object which received the signal
  );

  # then process all parameters of the callback. Skip the first which is the
  # instance which is not needed in the argument list to the handler.
  for $user-handler.signature.params[1..*-1] -> $p {

    # named argument. test for '$_widget` and deprecate the use of it. then skip
    if $p.named {
      Gnome::N::deprecate(
        'named argument :$_widget', ':$_native-object', '0.19.8', '0.21.0'
      ) if $p.name eq '$_widget';

      next;
    }

    next if $p.name ~~ Nil;       # seems to be possible
    next if $p.name eq '%_';      # only at the end I think

    @sub-parameter-list.push(self!convert-type($p.type));
  }

  # finish with data pointer argument which is ignored
#  @sub-parameter-list.push(Parameter.new(type => gpointer));
  @sub-parameter-list.push(self!convert-type(gpointer));

  # create signature from user handler, test for return value
  my Signature $sub-signature;

  # Mu is not an accepted value for the NativeCall interface make it
  # an OpaquePointer.
  if $user-handler.signature.returns.gist ~~ '(Mu)' {
    $sub-signature .= new(
      :params( |@sub-parameter-list ),
      :returns(gpointer)
    );
  }

  else {
    $sub-signature .= new(
      :params( |@sub-parameter-list ),
      :returns(self!convert-type( $user-handler.signature.returns, :type-only))
    );
  }

  # create parameter list for call to g_signal_connect_object
  my @parameterList = (
    Parameter.new(type => N-GObject),     # $instance
    Parameter.new(type => Str),           # $detailed-signal
    Parameter.new(                        # wrapper around $user-handler
      :type(Callable),
      :$sub-signature
    ),
    Parameter.new(type => gpointer),      # $data is ignored
    Parameter.new(type => GEnum)          # $connect-flags is ignored
  );

  # create signature for call to g_signal_connect_object
  my Signature $signature .= new(
    :params( |@parameterList ),
    :returns(gulong)
  );

  # get a pointer to the sub, then cast it to a sub with the created
  # signature. after that, the sub can be called, returning a value.
  state $ptr = cglobal( gobject-lib(), 'g_signal_connect_object', Pointer);

  my Callable $f = nativecast( $signature, $ptr);
#note "F: $f.gist()";

  note [~] "Calling: .g_signal_connect_object\(\n",
    "  $instance.perl(),\n",
    "  '$detailed-signal',\n",
    "  $provided-handler.perl(),\n",
    "  gpointer,\n",
#    "  OpaquePointer,\n",
    "  0\n",
    ');'  if $Gnome::N::x-debug;

  # returns the signal id

#note "F: $instance.gist(), $detailed-signal, $provided-handler.gist()";
  $f( $instance, $detailed-signal, $provided-handler, gpointer, 0)
}

#-------------------------------------------------------------------------------
method !convert-type ( $type, Bool :$type-only = False --> Any ) {
  my $converted-type;

#note 'type: ', $type.^name;
  given $type.^name {
    when Bool { $converted-type = gboolean; }
    when UInt { $converted-type = guint; }
    when Int { $converted-type = gint; }
    when Num { $converted-type = gfloat; }
    when Rat { $converted-type = gdouble; }
    when /^ Gnome '::' / { $converted-type = N-GObject; }
    default { $converted-type = $type; }
  }

  if $type-only {
    $converted-type
  }

  else {
    Parameter.new(type => $converted-type)
  }
}

#-------------------------------------------------------------------------------
#--[Native subs]----------------------------------------------------------------
#-------------------------------------------------------------------------------
#TM:1:_g_object_ref:
#`{{
=begin pod
=head2 [g_] object_ref

Increases the reference count of this object and returns the same object.

  method g_object_ref ( --> N-GObject )

=end pod
}}

sub _g_object_ref ( N-GObject $object --> N-GObject )
  is native(&gobject-lib)
  is symbol('g_object_ref')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_object_unref:
#`{{
=begin pod
=head2 [g_] object_unref

Decreases the reference count of the native object. When its reference count drops to 0, the object is finalized (i.e. its memory is freed).

When the object has a floating reference because it is not added to a container or it is not a toplevel window, the reference is first sunk followed by C<g_object_unref()>.

  method g_object_unref ( )

=item N-GObject $object; a native I<GObject>.

=end pod

sub g_object_unref ( N-GObject $object is copy ) {

  $object = g_object_ref_sink($object) if g_object_is_floating($object);
  _g_object_unref($object)
}
}}

sub _g_object_unref ( N-GObject $object )
  is native(&gobject-lib)
  is symbol('g_object_unref')
  { * }
