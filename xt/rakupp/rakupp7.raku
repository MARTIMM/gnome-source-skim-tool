use v6.d;

use NativeCall;

class N-Error:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {
  has uint32 $.domain;
  has int32 $.code;
  has Str $.message;
}

my $e = CArray[N-Error].new(N-Error);
say $e[0].raku;
say $e.raku;

my uint32 $domain = 45444;
my int32 $code = 1012342;
my Str $message = 'my error';


# First try goes ok
my Callable $g_set_error_literal =
  native-function( CArray[N-Error], uint32, int32, Str);
$g_set_error_literal( $e, $domain, $code, $message);

say $e[0].raku;


# Second try using an extra sub layer fails
$e = CArray[N-Error].new(N-Error);
call-native-sub( $e, $domain, $code, $message);

say $e[0].raku;



sub call-native-sub ( *@arguments ) {
  my Callable $g_set_error_literal =
    native-function( CArray[N-Error], uint32, int32, Str);
  $g_set_error_literal(|@arguments);
  say @arguments[0][0].raku;
}


sub native-function ( *@parameters --> Callable ) {
  # Create list of parameter types and start with inserting fixed arguments
  my @parameterList = ();

  for @parameters -> $p {
    @parameterList.push: Parameter.new(type => $p);
  }

  # Create return type
  my $returns = Pointer[void];

  # Create signature
  my Signature $signature .= new( :params(|@parameterList), :$returns);

  # Get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  my Callable $f = nativecast(
    $signature, cglobal( 'glib-2.0', 'g_set_error_literal', Pointer)
  );

  $f
}
