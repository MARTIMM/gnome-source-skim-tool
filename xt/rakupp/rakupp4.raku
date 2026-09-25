use v6.d;
use NativeCall;

constant gchar-pptr = CArray[Str];

class N-Error is repr('CStruct') {
  has uint32 $.domain;
}

my $e = CArray[N-Error].new(N-Error);
say $e.WHAT, ', ', gchar-pptr.WHAT;
say $e ~~ gchar-pptr;
say $e ~~ CArray[Str];
say $e ~~ CArray[N-Error];
say gchar-pptr ~~ CArray[Str];
say CArray[int] ~~ Int;
say Array[Int] ~~ Array[Str];
say Array[Int] ~~ Array[Int];