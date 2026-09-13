use v6.d;
use NativeCall;

my Str $library = 'libglib-2.0.so.0';

class N-Object is repr('CPointer') { };

sub native-function ( Array $parameters --> Callable ) {
  # Create list of parameter types and start with inserting fixed arguments
  my @parameterList = ();

  for @$parameters -> $p {
    @parameterList.push: Parameter.new(type => $p);
  }

  # End argument list with a Null pointer if the list is of variable length
  @parameterList.push: Parameter.new(type => Pointer);

  # Create signature
  my Signature $signature .= new(
    :params(|@parameterList), :returns(N-Object));

  # Get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  my Callable $f = nativecast(
    $signature, cglobal( $library, 'g_error_new', Pointer)
  );

  $f
}

my Callable $new-error = native-function([uint32, int32, Str]);


my uint32 $domain = 45444;
my int32 $code = 1012342;
my Str $message = 'my error';
my $error = $new-error( $domain, $code, $message);
note $error.raku;


class N-Error:auth<github:MARTIMM>:api<2> is repr('CStruct') {
  has uint32 $.domain;
  has int32 $.code;
  has Str $.message;

  submethod BUILD (
    uint32 :$!domain, int32 :$!code, 
  ) {
  }
}

my N-Error $ne = nativecast( N-Error, $error);
note $ne.domain;
note $ne.message;
