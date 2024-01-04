
use v6.d;

use NativeCall;
use fatal;

use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::X:api<2>;

#use Gnome::GObject::Object:api<2>;

#-------------------------------------------------------------------------------
unit class Gnome::N::GnomeRoutineCaller:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
# Define the error structure here too. It belongs in Gnome::Glib but
# taking it from there creates a circular depency
class N-GError is repr('CStruct') {

  has GQuark $.domain;
  has gint $.code;
  has Str $.message;

  submethod BUILD (
    GQuark :$!domain, gint :$!code, Str :$!message, 
  ) {
  }

  method COERCE ( $no --> N-GError ) {
    note "Coercing from {$no.^name} to ", self.^name if $Gnome::N::x-debug;
    nativecast( N-GError, $no)
  }
}

#-------------------------------------------------------------------------------
enum RoutineType is export (
  'Constructor',            # Constructors will return an object of this class
  'Method',                 # First argument must be an instance parameter
                            # but is not noted in the parameters list. This
                            # is the default type and maybe left.
  'Function'                # The instance parameter is not inserted.
);

#has Bool $!pointers-in-args;
has Str $!library is required;
has Str $!sub-prefix;

# Check on native library initialization.
my Bool $gui-initialized = False;
my Bool $may-not-initialize-gui = False;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!library, Str :$!sub-prefix = '' ) {

  # check GTK+ init except when GtkApplication / GApplication is used
  $may-not-initialize-gui = [or]
    $may-not-initialize-gui,
    $gui-initialized,

    # Check for Application from Gio. That one inherits from Object.
    # Application from Gtk3 inherits from Gio, so this test is always ok.
    ?(self.^mro[0..*-3].gist ~~ m/'(Application) (Object)'/);

  self.gtk-initialize unless $may-not-initialize-gui;
}

#-------------------------------------------------------------------------------
method gtk-initialize ( ) {

  note "Initialize Gtk" if $Gnome::N::x-debug;

  if $!library ~~ / 3 / {
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
    _init_check_v3( $argc, $argv);

    # now refill the ARGS list with left over commandline arguments
    @*ARGS = ();
    for ^$argc[0] -> $i {
      # skip first argument == programname
      next unless $i;
      @*ARGS.push: $argv[0][$i];
    }
  }

  else {
    _init_check_v4();
  }

  $gui-initialized = True;
}

#-------------------------------------------------------------------------------
# This sub belongs to GtkMain but is needed here.
sub _init_check_v3 ( gint-ptr $argc, char-ppptr $argv --> gboolean )
  is native(&gtk3-lib)
  is symbol('gtk_init_check')
  { * }

#-------------------------------------------------------------------------------
# This sub belongs to GtkMain but is needed here.
sub _init_check_v4 ( --> gboolean )
  is native(&gtk4-lib)
  is symbol('gtk_init_check')
  { * }

#-------------------------------------------------------------------------------
# Call for Contructors and Functions. They do not have a native
# object as their 1st argument.
multi method call-native-sub ( Str $name, @arguments, Hash $methods ) {
#say Backtrace.new.nice;

  my Hash $routine := $methods{$name};
  my Array $arguments = [|@arguments];
  my Array $native-args;
  my Array $parameters =
     $routine<parameters>:exists ?? [|$routine<parameters>] !! [];

  my Str $func-pattern = '';
  if $routine<variable-list>:exists {
    ( $arguments, $parameters, $func-pattern ) =
       self!adjust-data( $arguments, $parameters);

    # Get native arguments converted from $arguments. True ≡ variable list.
    $native-args = self.native-parameters(
      $arguments, $parameters, $routine, True
    );
  }

  else {
    $native-args = self.native-parameters( $arguments, $parameters, $routine);
  }

  # Set the function pattern under which the function is to be stored.
  # Mostly just the function name. With variable argument list a type
  # pattern is attached.
  $func-pattern = $func-pattern ?? "$name\-$func-pattern" !! $name;

  # Get routine address. Search for the name, if not found
  # create native function and store
  my Callable $c;
  $routine<function-address> = %() unless $routine<function-address>:exists;
  if ?$routine<function-address>{$func-pattern} {
    note "Reuse native function address of $name\()" if $Gnome::N::x-debug;
    $c = $routine<function-address>{$func-pattern};
  }

  else {
    note "Get native function address of $name\()" if $Gnome::N::x-debug;
    $c = self!native-function( $name, $parameters, $routine);
    $routine<function-address>{$func-pattern} = $c;
  }

#note "\n$?LINE '$func-pattern'\n\[{$native-args>>.gist.join(', ')}\]";

  self.convert-return( $c(|$native-args), $routine);
}

#-------------------------------------------------------------------------------
# Call for methods
multi method call-native-sub (
  Str $name, @arguments, Hash $methods, N-Object $native-object
  --> Any
) {
#say Backtrace.new.nice;

  my Hash $routine := $methods{$name};

  my Array $arguments = [|@arguments];
  my Array $native-args;
  my Array $parameters =
     $routine<parameters>:exists ?? [|$routine<parameters>] !! [];

  my Str $func-pattern = '';
  if $routine<variable-list>:exists {
    ( $arguments, $parameters, $func-pattern ) =
       self!adjust-data( $arguments, $parameters);

    # Get native parameters converted from $arguments
    $native-args = self.native-parameters(
      $arguments, $parameters, $routine, $native-object, True
    );
  }

  else {
    $native-args = self.native-parameters(
      $arguments, $parameters, $routine, $native-object
    );
  }


  # Set the function pattern under which the function is to be stored.
  # Mostly just the function name. With variable argument list a type
  # pattern is attached.
  $func-pattern = $func-pattern ?? "$name\-$func-pattern" !! $name;

  # Get routine address. Search for the name, if not found create
  # native function and store
  my Callable $c;
  $routine<function-address> = %() unless $routine<function-address>:exists;
  if ?$routine<function-address>{$func-pattern} {
    note "Reuse native function address of $name\()" if $Gnome::N::x-debug;
    $c = $routine<function-address>{$func-pattern};
  }

  else {
    note "Get native function address of $name\()" if $Gnome::N::x-debug;
    $c = self!native-function( $name, $parameters, $routine);
    $routine<function-address>{$func-pattern} = $c;
  }

#note "\n$?LINE '$func-pattern', $routine.gist(), $native-args.gist()";

  self.convert-return( $c(|$native-args), $routine);
}

#-------------------------------------------------------------------------------
# Native parameters for Contructors and Functions with optionally a
# variable argument list
multi method native-parameters (
  Array $arguments, Array $parameters,
  Hash $routine, Bool $variable-list = False
  --> Array
) {
  my Array $native-args = [];
#note "$?LINE {$arguments>>.gist()}";

  loop (my $i = 0; $i < $parameters.elems; $i++ ) {
    my $p = $parameters[$i];
    my $a = self!convert-args( $arguments[$i], $p);
    $native-args.push: $a;
  }

  $native-args.push: gpointer.new if $variable-list;
#note "$?LINE {$native-args>>.gist()}";

  $native-args
}

#-------------------------------------------------------------------------------
# Native parameters for Methods, a native object is provided
# as its first argument
multi method native-parameters (
  Array $arguments, Array $parameters, Hash $routine,
  N-Object $native-object, Bool $variable-list = False
  --> Array
) {
  my Array $native-args = [$native-object];

  loop (my $i = 0; $i < $parameters.elems; $i++ ) {
    my $p = $parameters[$i];
    my $a = self!convert-args( $arguments[$i], $p);
    $native-args.push: $a;
  }

  $native-args.push: gpointer.new if $variable-list;
#note "$?LINE {$native-args>>.gist()}";

  $native-args
}

#-------------------------------------------------------------------------------
method !native-function (
  Str $name, Array $parameters, Hash $routine --> Callable
) {

  # Create list of parameter types and start with inserting fixed arguments
  my @parameterList = ();

  given $routine<type> {
    # Constructors and functions do not have an instance parameter
    when Constructor { }
    when Function { }
    #when Method { }
    default {
      @parameterList.push: Parameter.new(type => N-Object);
    }
  }

  for @$parameters -> $p {
    if $p.^name() eq 'Signature' {
      @parameterList.push: Parameter.new(
        type => Callable,
        sub-signature => $p,
      );
    }

    else {
      @parameterList.push: Parameter.new(type => $p);
    }
  }

  # End argument list with a Null pointer if the list is of variable length
  @parameterList.push: Parameter.new(type => gpointer)
    if $routine<variable-list>:exists;

  # Create return type
  my $returns = $routine<returns>:exists ?? $routine<returns> !! Pointer[void];

  # Create signature
  my Signature $signature .= new( :params(|@parameterList), :$returns);

  # Get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  my Callable $f = nativecast(
    $signature, cglobal(
      $!library, self.set-routine-name( $name, $routine), Pointer
    )
  );

  $f
}

#-------------------------------------------------------------------------------
# Final change will that $routine<realname> and $routine<isnew> are changed to
# $routine<is-symbol> holding the full native name. All entries will have
# this field eventually. After all changes, this method may also dissappear.

method set-routine-name ( Str $name, Hash $routine, Str :$sub-prefix --> Str ) {
  my Str $routine-name;

  if $routine<isnew>:exists {
    $routine-name = 'new';
    $routine-name = ($sub-prefix // $!sub-prefix) ~ $routine-name;
  }

  elsif $routine<is-symbol>:exists {
    $routine-name = $routine<is-symbol>;
  }

  elsif $routine<realname>:exists {
    $routine-name = $routine<realname>;
    $routine-name ~~ s:g/ '-' /_/;
    $routine-name = ($sub-prefix // $!sub-prefix) ~ $routine-name;
  }

  else {
    $routine-name = $name;
    $routine-name ~~ s:g/ '-' /_/;
    $routine-name = ($sub-prefix // $!sub-prefix) ~ $routine-name;
  }

#note "$?LINE $name, {$sub-prefix//'-'}, $routine-name, $routine.gist()";
  $routine-name
}

#-------------------------------------------------------------------------------
method !convert-args ( Mu $v, $p ) {
  my $c;

#note "$?LINE $p.^name(), $v.gist(), ", $v.^mro;
  if $v.can('get-native-object-no-reffing') {
    my N-Object $no = $v.get-native-object-no-reffing;
    $c = $no;
  }

  else {
    given $p {
      # May be used to receive an array of strings or to provide one.
      when gchar-pptr {
        $c = CArray[Str].new(|$v);
      }

      # Only used to return a value
      when gint-ptr {
        $c = CArray[gint].new(0);
      }

      # Only used to return a value
      when .^name ~~ / CArray .*? 'N-GError' / {
        $c = CArray[N-GError].new(N-GError); #($p.new);
      }

      when .^name ~~ / num / {
        $c = $v.Num if $v.defined;
      }

      when .^name ~~ / int / {
        $c = $v.Int if $v.defined;
      }

      when .^name ~~ / Str / {
        $c = $v.Str if $v.defined;
      }

#`{{
      when N-Object {
        my N-Object $no = $v.get-native-object-no-reffing;
        $c = $no;
      }
      when Signature {
        die X::Gnome.new(
          :message('Signature of callback routine does not match')
        ) unless $p ~~ $v.signature;

        $c = $v;
      }
}}

      # Most values do not need conversion
      default {
        $c = $v;
      }
    }
  }

#note "$?LINE $c.gist()";
  $c
}

#-------------------------------------------------------------------------------
multi method convert-return ( $v, Hash $routine ) {
  my $c;
  my $p = $routine<returns>;
#note "$?LINE p = {$p.^name}, $p.gist(), $v.gist()";

  # Use 'given' because $p is a type and is always undefined
  given $p {
    when GEnum {
      $c = $routine<cnv-return>($v);
    }

    when GFlag {
      $c = $v.UInt;
    }

    when gchar-pptr {
      my Int $i = 0;
      $c = [];
      while $v[$i].defined {
        $c.push: $v[$i++];
      }
    }

    when gint-ptr {
      $c = $v[0];
    }

    # gboolean is an int32 so it is not visible if it should be a boolean
    when gboolean {
      $c = $v[0].Bool if $routine<cnv-return> ~~ Bool;
    }

    when .^name ~~ / CArray / {
      $c = ?$v[0] ?? $v[0] !! $p;
    }

    # Most values do not need conversion
    default {
      $c = $v;
    }
  }

  $c
}

#-------------------------------------------------------------------------------
# called from make-list-from-result() to make lists of returned values via
# argument pointers
multi method convert-return ( $v, $p ) {
  my $c;
#note "$?LINE p = {$p.^name}, $p.gist()";

  # Use 'given' because $p is a type and is always undefined
  given $p {      
    when gchar-pptr {
      my Int $i = 0;
      $c = [];
      while $v[$i].defined {
        $c.push: $v[$i++];
      }
    }

    when gint-ptr {
      $c = $v[0];
    }

    when .^name ~~ / CArray / {
      $c = ?$v[0] ?? $v[0] !! $p;
    }

#    # Most values do not need conversion
#    default {
#      $c = $v;
#    }
  }

  $c
}

#-------------------------------------------------------------------------------
method !adjust-data ( Array $arguments, Array $parameters --> List ) {
  my Int $np = $parameters.elems;
  my Array $new-arguments = [|$arguments[0..^$np]];
  my Array $new-parameters = [|$parameters];
  my Str $func-pattern = '';

#`{{
  if $arguments[0] ~~ List {
    for @($arguments[$np]) -> Pair $pair {
      my ( $type, $value ) = $pair.kv;

      # Must be an undefined type followed by a defined value
      if $type.defined and !$value.defined {
        die X::Gnome.new(:message(
            'A type must not be a value, is it perhaps written as a string?' ~
            "\n" ~ 'A value however must be defined, e.g. :gint32(42)';
          )
        )
      }

      note "extend list with a $type.gist() followed $value.gist()"
        if $Gnome::N::x-debug;

      $new-arguments.push: $value;
      $new-parameters.push: $type;
      $func-pattern ~= $type.^name;
    }
  }

  elsif $arguments.elems > $np {
}}
  if $arguments.elems > $np {
    for $arguments[$np..*-1] -> $type, $value {
      # Must be an undefined type followed by a defined value
      if $type.defined and !$value.defined {
        die X::Gnome.new(
          :message('Variable lists must be extended by paired variables: a type and a value')
        )
      }

      note "extend list with a $type.gist() followed $value.gist()"
        if $Gnome::N::x-debug;

      $new-arguments.push: $value;
      $new-parameters.push: $type;
      $func-pattern ~= $type.^name;
    }
  }

  ( $new-arguments, $new-parameters, $func-pattern )
}
