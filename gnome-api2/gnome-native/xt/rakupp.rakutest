
use v6.d;

class A {
  our $var = 'foo';

  our &set-var1 = sub ( Str $new-var ) {
    $var = $new-var;
  }

  method set-var2 ( Str $new-var ) {
    $var = $new-var;
  }
}

say $A::var;

&A::set-var1('bar');
say $A::var;

my A $a .= new;
$a.set-var2('baz');
say $A::var;