use v6.d;

use NativeCall;

class N-Error:auth<github:MARTIMM>:api<2> is export is repr('CStruct') {
  has uint32 $.domain;
  has int32 $.code;
  has Str $.message;

  submethod BUILD (
    uint32 :$!domain, int32 :$!code, Str :$message,
  ) {
    $!message := $message;
  }
}

my $v = CArray[N-Error].new(N-Error);
f1( $v, 2, 3);
say $v[0];

sub f1 ( *@args ) {
say "@args.raku(), @args.elems()";
  f2(|@args);
}

sub f2 ( *@args ) {
say "@args.raku(), @args.elems()";
  f3(|@args);
}

sub f3 ( CArray[N-Error] $v, $i1, $i2) {
  $v[0] = N-Error.new(
    :domain($i1), :code($i2), :message("$i1 + $i2 = {$i1 + $i2}")
  );
}

