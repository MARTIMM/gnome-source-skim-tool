#!/usr/bin/env rakudo
use v6.d;

# Benchmarks of calling a series of GnomeRoutineCaller based functions
# which use FALLBACk, and TopLevelClassSupport based functions.

use Gnome::Gtk4::Button:api<2>;

use Benchmark;

# FALLBACK method for normal routines
sub set1-fallback ( ) {
  with my Gnome::Gtk4::Button $button .= new-button('text') {
    .set-label('t2');
    my Str $txt = .get-label;
    .clear-object;
  }
}

# Methods for renamed routines
sub set2-methods ( ) {
  with my Gnome::Gtk4::Button $button .= M-new-button {
    .M-set-label('label');
    my Str $txt = .M-get-label;
    .clear-object;
  }
}

# Function create
set1-fallback;
set2-methods;

my %r = timethese 10000, {
  set1-fallback => &set1-fallback,
  set2-methods => &set2-methods,
}, :statistics;


say ~%r;