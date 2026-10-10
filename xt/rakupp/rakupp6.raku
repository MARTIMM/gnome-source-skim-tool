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
g_set_error_literal( $e, $domain, $code, $message);
say $e[0].raku;
say $e.raku;

# Take care of the library name of libglib!
sub g_set_error_literal ( CArray[N-Error], uint32, int32, Str )
  is native('libglib-2.0.so.0')
  {*}
