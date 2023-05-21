use v6;

module M {

  our sub m1 ( Int $i --> Int ) {
    $i * 3
  }
};

say M::m1(23);
