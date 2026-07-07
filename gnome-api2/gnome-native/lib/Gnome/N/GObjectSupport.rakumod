
use v6.d;

use NativeCall;

use Gnome::N::X;
use Gnome::N::NativeLib;
use Gnome::N::N-Object;
#use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

#-------------------------------------------------------------------------------
unit role Gnome::N::GObjectSupport:auth<github:MARTIMM>:api<2>;

my Hash $signal-types = {};

#-------------------------------------------------------------------------------
method native-object-ref ( $n-native-object --> N-Object ) {
  if _g_object_is_floating($n-native-object) {
    _g_object_ref_sink($n-native-object);
  }

  else {
    _g_object_ref($n-native-object);
  }
}

#-------------------------------------------------------------------------------
method native-object-unref ( $n-native-object ) {
#  _g_object_free($n-native-object)
  _g_object_unref($n-native-object)
}

#-------------------------------------------------------------------------------
# no pod. user does not have to know about it.
# Called from Build's in widgets who have signals to process. Structure is
#
# self.add-signal-types( $?CLASS.^name,
#   :w0<signal names>,
#   :w1<signal names>,
#   …
# );
#
# where wo, w1, … is the number of parameters an event handler gets
#
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

method register-signal (
  Mu $handler-object, Str:D $handler-name, Str:D $signal-name, *%user-options
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
    my Str $signal-name-check;
    if $signal-name ~~ m/^ $<signal-name> = [ <-[:]>+ ]
                           [ '::' .* ]?
                       $/
    {
      $signal-name-check = $/<signal-name>.Str;
    }

    my @module-names = self.^name, |(map( {.^name}, self.^parents));
    for @module-names -> $mn {
      note "  search in class: $mn, $signal-name" if $Gnome::N::x-debug;
      if $signal-types{$mn}:exists
         and $signal-types{$mn}{$signal-name-check}:exists
      {
        $signal-type = $signal-types{$mn}{$signal-name-check};
        $module-name = $mn;
        note "  found key '$signal-type' for $mn" if $Gnome::N::x-debug;
        last;
      }
    }

    return False unless ?$signal-type;

    my %named-args = %user-options;
    %named-args<_handler-id> = $handler-id;

    sub w0 ( N-Object $w, gpointer $d ) is export {
      CONTROL { when CX::Warn {  note .gist; .resume; } }
      CATCH { default { .message.note; .backtrace.concise.note } }

      %named-args<_native-object> := $w;
      note "\nw0, call $handler-name\() for $signal-name: %named-args.gist()"
        if $Gnome::N::x-debug;

      # Mu is not an accepted value for the NativeCall interface
      # _convert_g_signal_connect_object() in Signal makes it a gpointer
      my $retval = $handler-object."$handler-name"(|%named-args);

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w0 handler result: $retval";
      }

      $retval
    }

    sub w1( N-Object $w, $h0, gpointer $d ) is export {
      CONTROL { when CX::Warn {  note .gist; .resume; } }
      CATCH { default { .message.note; .backtrace.concise.note } }

      %named-args<_native-object> := $w;
      note "\nw1, call $handler-name\() for $signal-name: $h0.gist(), %named-args.gist()"
        if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args($h0);
#      $handler-object."$handler-name"( |@converted-args, |%named-args);
      my $retval = $handler-object."$handler-name"( $h0, |%named-args);

      if $sh.signature.returns.gist ~~ '(Mu)' {
        $retval = gpointer;
      }

      elsif $Gnome::N::x-debug {
        note "w1 handler result: $retval";
      }

      $retval
    }

    sub w2( N-Object $w, $h0, $h1, gpointer $d ) is export {
      CONTROL { when CX::Warn {  note .gist; .resume; } }
      CATCH { default { .message.note; .backtrace.concise.note } }

      %named-args<_native-object> := $w;
      note "\nw2, call $handler-name\() for $signal-name: $h0.gist(), $h1.gist(), %named-args.gist()"
        if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1);
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

    sub w3( N-Object $w, $h0, $h1, $h2, gpointer $d ) is export {
      CONTROL { when CX::Warn {  note .gist; .resume; } }
      CATCH { default { .message.note; .backtrace.concise.note } }

      %named-args<_native-object> := $w;
      note "\nw3, call $handler-name\() for $signal-name: $h0.gist(), $h1.gist(), $h2.gist(), %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2);
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

    sub w4( N-Object $w, $h0, $h1, $h2, $h3, gpointer $d ) is export {
      CONTROL { when CX::Warn {  note .gist; .resume; } }
      CATCH { default { .message.note; .backtrace.concise.note } }

      %named-args<_native-object> := $w;
      note "\nw4, call $handler-name\() for $signal-name: $h0.gist(), $h1.gist(), $h2.gist(), $h3.gist(), %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2, $h3);
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
      N-Object $w, $h0, $h1, $h2, $h3, $h4, gpointer $d
    ) is export {
      CONTROL { when CX::Warn {  note .gist; .resume; } }
      CATCH { default { .message.note; .backtrace.concise.note } }

      %named-args<_native-object> := $w;
      note "\nw5, call $handler-name\() for $signal-name: $h0.gist(), $h1.gist(), $h2.gist(), $h3.gist(), $h4.gist(), %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2, $h3, $h4);
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
      N-Object $w, $h0, $h1, $h2, $h3, $h4, $h5, gpointer $d
    ) is export {
      CONTROL { when CX::Warn {  note .gist; .resume; } }
      CATCH { default { .message.note; .backtrace.concise.note } }

      %named-args<_native-object> := $w;
      note "\nw6, call $handler-name\() for $signal-name: $h0.gist(), $h1.gist(), $h2.gist(), $h3.gist(), $h4.gist(), $h5.gist(), %named-args.gist()" if $Gnome::N::x-debug;

#      my List @converted-args = self!check-args( $h0, $h1, $h2, $h3, $h4, $h5);
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
  N-Object $instance, Str $detailed-signal,
  Callable $user-handler, Callable $provided-handler
  --> gulong
) {

  # create callback handlers signature using the users callback.
  # first argument is always a native widget.
  my @sub-parameter-list = (
    Parameter.new(type => N-Object),     # object which received the signal
  );

  # then process all parameters of the callback. Skip the first which is the
  # instance which is not needed in the argument list to the handler.
  for $user-handler.signature.params[1..*-1] -> $p {
    # Named arguments are skipped. Also skip undefined names.
    next if $p.named;
    next if $p.name ~~ Nil;       # seems to be possible
    next if $p.name eq '%_';      # only at the end I think

    @sub-parameter-list.push: self!convert-type($p.type);
  }

  # finish with data pointer argument which is ignored
  @sub-parameter-list.push: self!convert-type(gpointer);

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
    Parameter.new(type => N-Object),      # $instance
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

  note [~] "Calling: .g_signal_connect_object\(\n",
    "  $instance.gist(),\n",
    "  '$detailed-signal',\n",
    "  $provided-handler.gist(),\n",
    "  Pointer,\n",
    "  0\n",
    ');'  if $Gnome::N::x-debug;

  # returns the signal id
  my $v = $f( $instance, $detailed-signal, $provided-handler, Pointer, 0);
  $v
}

#-------------------------------------------------------------------------------
method !convert-type ( Mu $type, Bool :$type-only = False --> Any ) {
  my $converted-type;

  # Get the type name and drop the coercion marks
  my $t = $type.^name;
  $t ~~ s/\(.*?\)//;

  given $t {
    when 'Bool' { $converted-type = gboolean; }
    when 'UInt' { $converted-type = guint; }
    when 'Int' { $converted-type = gint; }
    when 'Num' { $converted-type = gfloat; }
    when 'Rat' { $converted-type = gdouble; }
#    when 'Pointer' { $converted-type = Pointer; }
    when 'Str' { $converted-type = gchar-ptr; }
    when /^ Gnome '::' / { $converted-type = N-Object; }

    # Assume that all other class types have a Gnome class parent
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
#TM:1:_g_object_ref_sink:
#TM:1:_g_object_is_floating:

sub _g_object_ref ( N-Object $object --> N-Object )
  is native(&gobject-lib)
  is symbol('g_object_ref')
  { * }

sub _g_object_ref_sink ( N-Object $object --> N-Object )
  is native(&gobject-lib)
  is symbol('g_object_ref_sink')
  { * }

sub _g_object_is_floating ( N-Object $object --> gboolean )
  is native(&gobject-lib)
  is symbol('g_object_is_floating')
  { * }

#-------------------------------------------------------------------------------
#TM:1:_g_object_unref:

sub _g_object_unref ( N-Object $object )
  is native(&gobject-lib)
  is symbol('g_object_unref')
  { * }
