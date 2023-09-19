
use v6;

use NativeCall;
use fatal;

use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
#use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;
use Gnome::N::X;

#use Gnome::Glib::N-GError:api<2>;

#-------------------------------------------------------------------------------
unit class Gnome::N::GnomeRoutineCaller:auth<github:MARTIMM>:api<2>;
#also is Gnome::N::TopLevelClassSupport;

#-------------------------------------------------------------------------------
enum RoutineType is export (
  'Constructor',            # Constructors will return an object of this class
  'Method',                 # First argument must be an instance parameter
                            # but is not noted in the parameters list. This
                            # is the default type and maybe left.
  'Function'                # The instance parameter is not inserted.
);

has Bool $!pointers-in-args;
has Str $!library is required;
has Str $!sub-prefix is required;
#has $!widget is required;
#has Str $!widget-name is required;
#has Bool $!is-leaf;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!library, Str :$!sub-prefix ) { }

#-------------------------------------------------------------------------------
method call-native-sub (
  Str $name, @arguments, Hash $methods, :$native-object,
) {
#say Backtrace.new.nice;
#note "$?LINE $name @arguments.gist()";

  # Set False, is set in native-parameters() as a side effect
  $!pointers-in-args = False;

  my Hash $routine := $methods{$name};
  my Str $real-name = $methods{$name}<isnew>:exists ?? 'new' !! $name;

  my Array $arguments = [|@arguments];
  my Array $parameters =
     $routine<parameters>:exists ?? [|$routine<parameters>] !! [];

  my Bool $variable-list = False;
  my Str $func-pattern = '';
  if $routine<variable-list>:exists {
    $variable-list = True;
    ( $arguments, $parameters, $func-pattern ) =
       self!adjust-data( $arguments, $parameters);
  }

  $func-pattern = $func-pattern ?? "$name\-$func-pattern" !! $name;

  # Get native parameters converted from $arguments
  my Array $native-args = self!native-parameters(
    $arguments, $parameters, $routine, :$native-object, :$variable-list
  );

#note "\n$?LINE '$func-pattern'\n$parameters.gist()\n$native-args.gist()";

  # Get routine address
  my Callable $c;
  $routine<function-address> = %() unless $routine<function-address>:exists;

  if ?$routine<function-address>{$func-pattern} {
    note "Reuse native profile of function $name\()" if $Gnome::N::x-debug;
    $c = $routine<function-address>{$func-pattern};
  }

  else {
    note "Get native profile of function $name\()" if $Gnome::N::x-debug;
    $c = self!native-function(
      $real-name, $parameters, $routine, $variable-list
    );
    $routine<function-address>{$func-pattern} = $c;
  }

#note "\n$?LINE '$func-pattern', $routine<function-address>.keys()";

  # Call routine

  # If there are pointers in the argument list, values are placed
  # there. Mostly returned like this when there is more than one value,
  # otherwise it could have been returned the normal way using the
  # return value of functions $x.
#note "$?LINE $!pointers-in-args, $native-args.gist()";
  if $!pointers-in-args {
#self.touch-elems($native-args);
    my $x = $c(|$native-args);
    return self!make-list-from-result(
      $native-args, $parameters, $routine, $x
    ).List
  }

  else {
    my $x;

    if $routine<type-name>:exists {
      $x = self!convert-return(
        $c(|$native-args),
        $routine<returns>, :type($routine<type-name>)
      );
    }

    else {
#note "$?LINE ", $native-args.gist;
      $x = $c(|$native-args);
      $x = self!convert-return( $x, $routine<returns>);
    }

    return $x
  }
}

#-------------------------------------------------------------------------------
method !native-parameters (
  Array $arguments, Array $parameters, Hash $routine,
  :$native-object, Bool :$variable-list
  --> Array
) {
  my Array $native-args = [];

  given $routine<type> {
    when Constructor { }
    when Function { }
    #when Method { }
    default {
#note "$?LINE np: ", $native-object.^name;
      $native-args.push: $native-object;
    }
  }

  loop (my $i = 0; $i < $parameters.elems; $i++ ) {
    my $p = $parameters[$i];
    my $a = self!convert-args( $arguments[$i], $p);
    $native-args.push: $a;
#note "$?LINE np: ", $a.^name;
    $!pointers-in-args = True if $p.^name ~~ m/ CArray /;
  }

  $native-args.push: gpointer.new if $variable-list;

  $native-args
}

#-------------------------------------------------------------------------------
method !native-function (
  Str $name is copy, Array $parameters, Hash $routine, Bool $variable-list
  --> Callable
) {

  $name ~~ s:g/ '-' /_/;
  my Str $routine-name = $!sub-prefix ~ $name;

  # Create list of parameter types and start with inserting fixed arguments
  my @parameterList = ();

  given $routine<type> {
    # Constructors and functions do not have an instance parameter
    when Constructor { }
    when Function { }
    #when Method { }
    default {
#note "$?LINE nf: ", N-GObject.^name;
      @parameterList.push: Parameter.new(type => N-GObject);
    }
  }

  for @$parameters -> $p {
     @parameterList.push: Parameter.new(type => $p);
  }

  @parameterList.push: Parameter.new(type => gpointer) if $variable-list;

  # Create return type
  my $returns = $routine<returns>:exists ?? $routine<returns> !! Pointer;

  # Create signature
  my Signature $signature .= new( :params(|@parameterList), :$returns);

  # Get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  my Callable $f = nativecast(
    $signature, cglobal( $!library, $routine-name, Pointer)
  );

  $f
}

#-------------------------------------------------------------------------------
method !make-list-from-result (
  Array $native-args, Array $parameters, Hash $routine, $x
  --> List
) {
  my @return-list = ();
  @return-list.push: $x if $routine<returns>:exists;

  # Drop the first one when routine type is a Method
  my Int $start = 0;
  given $routine<type> {
    when Constructor { $start = 0; }
    when Function { $start = 0; }
    #when Method { $start = 1; }
    default { $start = 1; }
  }

  loop ( my Int $i = 0; $i < $parameters.elems; $i++ ) {
    my $p = $parameters[$i];
    my $v = $native-args[$i + $start];
    next unless $p.^name ~~ m/ CArray /;
    @return-list.push: self!convert-return( $v, $p);
  }

  @return-list
}

#-------------------------------------------------------------------------------
method !convert-args ( $v, $p ) {
  my $c;
#note "$?LINE $p.^name(), $v.gist()";

  given $p {
    # May be used to receive an array of strings or to provide one.
    when gchar-pptr {
      $c = CArray[Str].new(|$v);
    }

    # Only used to return a value
    when gint-ptr {
      $c = CArray[gint].new(0);
    }

#`{{

    # Only used to return a value
    when .^name ~~ / CArray .*? 'N-GError' / {
#note "$?LINE";
#      my N-GObject() $v0 = $v;
#      $c = $v0;
      $c = CArray[$p].new; #($p.new);
note "$?LINE $c.gist()";
    }
}}

    when N-GObject {
      my N-GObject() $no = $v;
      $c = $no;
    }

    # Most values do not need conversion
    default {
      $c = $v;
    }
  }

#note "$?LINE $p.gist(), {$v.defined ?? $v !! $v.gist}, {$c.defined ?? $c !! $c.gist}";
  $c
}

#-------------------------------------------------------------------------------
method !convert-return ( $v, $p, :$type = Any ) {
  my $c;

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

    when GEnum {
      $c = $type($v);
    }

    # Most values do not need conversion
    default {
      $c = $v;
    }
  }

  $c
}

#-------------------------------------------------------------------------------
method !adjust-data ( Array $arguments, Array $parameters --> List ) {
  my Int $np = $parameters.elems;
  my Array $new-arguments = [|$arguments[0..^$np]];
  my Array $new-parameters = [|$parameters];
  my Str $func-pattern = '';

  if $arguments.elems > $np {
    for $arguments[$np..*-1] -> $type, $value {
      $new-arguments.push: $value;
      $new-parameters.push: $type;
      $func-pattern ~= $type.^name;
    }
  }

  ( $new-arguments, $new-parameters, $func-pattern )
}

#=finish
#-------------------------------------------------------------------------------
# temp routine
method touch-elems ( $a ) {
  print "\n$?LINE\n";
  for @$a -> $e {
    note "  {?$e ?? $e !! $e.gist()}";
  }
}