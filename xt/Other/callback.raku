

sub f1 ( Int $i --> Int ) { $i + 1; }
say f1(20);

sub f2 ( Str $s --> Str ) { $s ~ ' def'; }
say f2('20');

my Signature $sig = :( Int --> Int );
say $sig;

my Capture $c = \(23);
say f1(|$c);
say $c ~~ $sig;


sub f3 ( &fa:( Int --> Int ) ) { fa(30) + 20; }
say f3(&f1);
try {
  say f3(&f2);
  CATCH { default { note 'cannot run f3 with f2'; } }
}


my Signature \sig2 = :( Str --> Str );
say sig2;
sub f4 ( &fb:( Str --> Str ) ) { fb('pqr') ~ ' 20'; }
say f4(&f2);
try {
  say f4(&f1);
  CATCH { default { note 'cannot run f4 with f1'; } }
}


=finish
subset F5 of Callable where * ~~ sig2;
say F5.WHAT;
my F5 $f5 = &f4;
sub f5 ( F5 fb ) { fb('pqr') ~ ' 20'; }
