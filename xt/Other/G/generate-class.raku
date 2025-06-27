#!/usr/bin/env -S raku -Ilib

use v6.d;

use Pack;
use Pack::Mod1;

my Pack::Mod1 $m1 .= new(:test-value('test text'));








'lib/Pack/Mod1.rakumod'.IO.unlink;