

use NativeCall;

use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
#use Gnome::N::TopLevelClassSupport;
use Gnome::N::GlibToRakuTypes;

use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
unit class Gnome::Glib::GnomeRoutineCaller:api('gir');
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
#note "$?LINE $name, ", ($native-object // '-').gist;

  # Dashes to underscores
#  if $methods{$name}:exists {

    # Set False, is set in native-parameters() as a side effect
    $!pointers-in-args = False;

    my Hash $routine := $methods{$name};
#note $?LINE, ', ', $routine.gist;

  # this check fails when pointers to variables are used.
  #  die "Number of arguments not sufficient"
  #    unless @arguments.elems >= abs($routine<parameters>.elems);

    my @parameters = $routine<parameters>:exists
                  ?? @($routine<parameters>)
                  !! ();

    # Get native parameters converted from @arguments
    my @native-args = self.native-parameters(
      @arguments, @parameters, $routine, :$native-object
    );

#note "$?LINE ", @arguments.gist, ', ',  @native-args.gist;

    # Get routine address
    $routine<function-address> //=
      self.native-function( $name, @parameters, $routine);

    # Call routine

    # If there are pointers in the argument list, values are placed
    # there. Mostly returned like this when there is more than one value,
    # otherwise it could have been returned the normal way using $x.
#note "$?LINE pointers-in-args $!pointers-in-args";
    if $!pointers-in-args {
      my $x = $routine<function-address>(|@native-args);
      return self.make-list-from-result(
        @native-args, @parameters, $routine, $x
      )
    }

    else {
      my $x;

      if $routine<type-name>:exists {
        $x = self.convert-return(
          $routine<function-address>(|@native-args),
          $routine<returns>, :type($routine<type-name>)
        );
      }

      else {
        $x = self.convert-return(
          $routine<function-address>(|@native-args), $routine<returns>
        );
      }

      return $x
    }
#  }
}

#-------------------------------------------------------------------------------
method native-parameters (
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
#`{{
      if $!is-leaf {
        @native-args.push: $!widget._get-native-object-no-reffing;
      }

      else {
        @native-args.push: $!widget._f($!widget-name);
      }
}}
    }
  }

  loop (my $i = 0; $i < @parameters.elems; $i++ ) {
    my $p = @parameters[$i];
    my $a = self.convert-args( @arguments[$i], $p);
#note "$?LINE $i, @arguments[$i].gist(), {$p.^name}, convert-args $a.gist()";
    @native-args.push: $a;
    $!pointers-in-args = True if $p.^name ~~ m/ CArray /;
  }

  @native-args
}

#-------------------------------------------------------------------------------
method native-function ( Str $name, @parameters, Hash $routine --> Callable ) {
  my Str $routine-name = $!sub-prefix ~ $name;

  # Create parameter list and start with inserting fixed arguments
  my @parameterList = ();

  given $routine<type> {
    # Constructors and functions do not have an instance parameter
    when Constructor { }
    when Function { }
    #when Method { }
    default {
      @parameterList.push: Parameter.new(type => N-GObject);
    }
  }

  for @parameters -> $p {
    @parameterList.push: Parameter.new(type => $p);
  }

  # Create signature
  my $returns = $routine<returns>:exists ?? $routine<returns> !! Pointer;
  my Signature $signature .= new( :params(|@parameterList), :$returns);

  # Get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  my Callable $f = nativecast(
    $signature, cglobal( $!library, $routine-name, Pointer)
  );

  $f
}

#-------------------------------------------------------------------------------
method make-list-from-result (
  @native-args, @parameters, Hash $routine, $x
  --> List
) {
#note "$?LINE make-list-from-result: ", $routine.gist;
#note "$?LINE, ", @native-args.gist;
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

#  @native-args.shift unless ?$routine<type> ~~ Function;
  loop ( my Int $i = 0; $i < @parameters.elems; $i++ ) {
    my $p = @parameters[$i];
    my $v = @native-args[$i + $start];
    next unless $p.^name ~~ m/ CArray /;
    @return-list.push: self.convert-return( $v, $p);
  }
#note "$?LINE result list: ", @return-list.gist;

  @return-list
}

#-------------------------------------------------------------------------------
method convert-args ( $v, $p ) {
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

    when N-GObject {
      my N-GObject() $no = $v;
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
method convert-return ( $v, $p, :$type = Any ) {
  my $c;

#note "$?LINE return: ", $p.^name, ', ', $v.^name, ', ', $v.gist;

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
      $c = ?$v
         ?? Gnome::Glib::Error.new(:native-object($v[0]))
         !! Gnome::Glib::Error.new(:native-object(N-GError));
#note "$?LINE converted: ", $c.gist;
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








=finish
#-------------------------------------------------------------------------------
has Int $!indent-level;

method display-hash ( Hash $info ) {
  $!indent-level = 0;
  self!dhash($info);
}

#-------------------------------------------------------------------------------
method !dhash ( Hash $info ) {

  for $info.keys.sort -> $k {
#note $k;
#dd $info{$k};
#exit;
    if $info{$k} ~~ Hash {
      say '  ' x $!indent-level, $k, ':';
      $!indent-level++;
      self!dhash($info{$k});
      $!indent-level--;
#exit;
    }

#    elsif $info{$k} ~~ Array {
#      self!dhash(%($info.kv));
#    }

    else {
      say '  ' x $!indent-level, $k, ': ', $info{$k}.gist;
    }
  }
}


=finish

  # Call routine
  # If there are pointers in the argument list, values are placed
  # there. Mostly returned like this when there is more than one value,
  # otherwise it could have been returned the normal way using $x.
#note "$?LINE $!pointers-in-args";
  if $!pointers-in-args {
    my $x = $routine<function-address>(|@native-args);
    return self.make-list-from-result( @native-args, @parameters, $routine, $x)
  }

  else {
    my $x;
      $x = self.convert-return(
        $routine<function-address>(@native-args), $routine<returns>
      );
#`{{
    if $routine<return-type>:exists {
      $x = self.convert-return(
        $routine<function-address>(@native-args),
        $routine<returns>, :type($routine<return-type>)
      );
    }

    else {
      $x = self.convert-return(
        $routine<function-address>(@native-args), $routine<returns>
      );
    }
  }}
    return $x
  }
