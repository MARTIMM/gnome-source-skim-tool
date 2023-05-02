use Gnome::N::X;

class A {
  sub x_y_b_do_test1 ( Int $i ) { $i * 10; }
  method do-test1 ( Int $i ) { x_y_b_do_test1($i); }

  method FALLBACK ( $native-sub is copy, **@params ) {
    my Callable $s = self._fallback($native-sub);
    $s(|@params) if ?$s;
  }

  method _fallback ( $native-sub is copy --> Callable ) {
    my Str $pfix = 'x_y_b_';
    my @pfix-parts = $pfix.split('_');
    my Int $cfix = @pfix-parts.elems +2;
    my Str $new-patt = $native-sub.subst( '-', '_', :g);

    my Callable $s;

    loop ( my Int $dash-count = 2; $dash-count < $cfix; $dash-count++ ) {
      my Str $tv = @pfix-parts[0 .. * - $dash-count].join('_');
      my Str $match = ?$tv ?? "{$tv}_$new-patt" !! "$tv$new-patt";
      try { $s = &::($match); }
      if ?$s {
        $match ~~ s/ $pfix //;
        $match ~~ s:g/ '_' /-/;
        Gnome::N::deprecate(
          "$native-sub", $match, '0.47.4', '0.50.0'
        );

        last;
      }
    }

    $s
  }
}

my A $a .= new;
note "$?LINE x-y-b-do_test1: ",  $a.x-y-b-do-test1(9);
note "$?LINE x_y_b_do_test1: ",  $a.x_y_b_do_test1(10);
note "$?LINE y_b_do_test1: ",    $a.y_b_do_test1(11);
note "$?LINE b_do_test1: ",      $a.b_do_test1(12);
note "$?LINE b-do-test1: ",      $a.b-do-test1(13);
note "$?LINE do_test1: ",        $a.do_test1(14);
note "$?LINE do-test1: ",        $a.do-test1(14);
#`{{
}}
