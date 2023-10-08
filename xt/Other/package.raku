use v6.d;

module M {

  our sub m1 ( Int $i --> Int ) {
    $i * 3
  }
};

say M::m1(23);
