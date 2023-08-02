

sub f1 ( Int $i --> Int ) { $i + 1; }
say 'f1(20): ', f1(20);

sub f2 ( Str $s --> Str ) { $s ~ ' def'; }
say 'f2(20): ', f2('20');

my Signature $sig = :( Int --> Int );
say 'sig: ', $sig.gist;
say 'sig params: ', $sig.params.gist;
say 'sig returns: ', $sig.returns.gist;

my Capture $c = \(23);
say 'f1( ', $c.gist, ' ): ', f1(|$c);
say $c.gist, ' ~~ ', $sig.gist, ': ',  $c ~~ $sig;


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
#subset F5 of Callable where * ~~ sig2;
#say F5.WHAT;
#my F5 $f5 = &f4;

use NativeCall;
use Gnome::N::NativeLib;
use Gnome::N::N-GObject;
use Gnome::N::GlibToRakuTypes;

my Str $lib = gtk-lib;
say $lib;

sub gtk_label_new ( Str $str --> N-GObject )
  is native('gtk-3')
  { * }

sub gtk_label_get_label ( N-GObject $label --> Str )
  is native($lib)
  { * }

my N-GObject $lo0 = gtk_label_new('label');
say 'label: ', gtk_label_get_label($lo0);



=finish
my $pf5a = cglobal( $lib, 'gtk_label_new', Pointer);
say $pf5a.gist;
my Signature $sf5a .= new(
  :params(Parameter.new(:type(gchar-ptr)),), :returns(N-GObject)
);
say $sf5a.gist;

my Callable $f5a = nativecast( $sf5a, $pf5a);
say $f5a.gist;
my N-GObject $lo = $f5a('label');
say $lo.gist;

my Callable $f5b = nativecast(
  :( N-GObject --> gchar-ptr ), cglobal( $lib, 'gtk_label_get_label', Pointer)
);

say 'label: ', $f5b($lo);