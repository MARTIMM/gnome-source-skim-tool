
use v6.d;

use NativeCall;

use Gnome::N::N-Object;
use Gnome::N::NativeLib;
#use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::N-GError:api<2>;

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
  Str $name, @arguments, Hash $methods, :$native-object
) {
#say Backtrace.new.nice;

  # Set False, is set in native-parameters() as a side effect
  $!pointers-in-args = False;

  my Hash $routine := $methods{$name};

  my @parameters = $routine<parameters>:exists
                ?? @($routine<parameters>)
                !! ();

  my Bool $variable-list = False;
  my Array $pattern = [];
  if $routine<pattern>:exists {
    $variable-list = True;
    $pattern = $routine<pattern>;
    $routine<function-addresses> = [];
    self!adjust-data( @arguments, @parameters, $pattern);
  }

  # Get native parameters converted from @arguments
  my @native-args = self!native-parameters(
    @arguments, @parameters, $routine, :$native-object,
  );

  # Get routine address
  $routine<function-address> //=
    self!native-function( $name, @parameters, $routine);

  # Call routine

  # If there are pointers in the argument list, values are placed
  # there. Mostly returned like this when there is more than one value,
  # otherwise it could have been returned the normal way using the
  # return value of functions $x.
  if $!pointers-in-args {
    my $x = $routine<function-address>(|@native-args);
    return self!make-list-from-result(
      @native-args, @parameters, $routine, $x
    ).List
  }

  else {
    my $x;

    if $routine<type-name>:exists {
      $x = self!convert-return(
        $routine<function-address>(|@native-args),
        $routine<returns>, :type($routine<type-name>)
      );
    }

    else {
      $x = $routine<function-address>(|@native-args);
      $x = self!convert-return( $x, $routine<returns>);
    }

    return $x
  }
}

#-------------------------------------------------------------------------------
method !native-parameters (
  @arguments, @parameters, Hash $routine, :$native-object
  --> List
) {
  my @native-args = ();

  given $routine<type> {
    when Constructor { }
    when Function { }
    #when Method { }
    default {
      @native-args.push: $native-object;
    }
  }

  loop (my $i = 0; $i < @parameters.elems; $i++ ) {
    my $p = @parameters[$i];
    my $a = self!convert-args( @arguments[$i], $p);
    @native-args.push: $a;
    $!pointers-in-args = True if $p.^name ~~ m/ CArray /;
  }

  @native-args
}

#-------------------------------------------------------------------------------
method !native-function ( Str $name, @parameters, Hash $routine --> Callable ) {
  my Str $routine-name = $!sub-prefix ~ $name;

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

  for @parameters -> $p {
    @parameterList.push: Parameter.new(type => $p);
  }

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
  @native-args, @parameters, Hash $routine, $x
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

  loop ( my Int $i = 0; $i < @parameters.elems; $i++ ) {
    my $p = @parameters[$i];
    my $v = @native-args[$i + $start];
    next unless $p.^name ~~ m/ CArray /;
    @return-list.push: self!convert-return( $v, $p);
  }

  @return-list
}

#-------------------------------------------------------------------------------
method !convert-args ( $v, $p ) {
  my $c;

  given $p {
    when gchar-pptr {
      $c = CArray[Str].new(|$v);
    }

    when gint-ptr {
      $c = CArray[gint].new(0);
    }

    when CArray[N-GError] {
      $c = CArray[N-GError].new(N-GError);
    }

    when N-Object {
      my N-Object() $no = $v;
      $c = $no;
    }

    # Most values do not need conversion
    default {
      $c = $v;
    }
  }

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

    when CArray[N-GError] {
      $c = ?$v[0] ?? $v[0] !! N-GError;
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
method !adjust-data ( @arguments, @parameters, Array $pattern --> List ) {
note "$?LINE adjust-data";
  my @new-parameters = |@parameters;
  my @new-arguments = ();

  my Int $pattern-start = @parameters.elems;
  loop ( my Int $i = 0; $i < $pattern-start; $i++ ) {
    @new-arguments.push: 
  }

  ( @new-parameters, @new-arguments)
}