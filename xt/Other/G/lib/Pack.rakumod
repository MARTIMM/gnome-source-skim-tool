unit class Pack;

BEGIN {
  note "Run Pack";

  'lib/Pack/Mod1.rakumod'.IO.spurt(Q:q:to/EOC/);
    unit class Pack::Mod1;
    submethod BUILD ( Str :$test-value ) { say $test-value; }
    EOC
}

