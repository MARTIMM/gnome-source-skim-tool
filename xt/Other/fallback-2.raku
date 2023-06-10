
#-------------------------------------------------------------------------------
class X {
  method FALLBACK ( |c ) {
    self._fallback(|c);
  }

  method _fallback ( $name, |c ) {
note "X";
    die "method $name not found";
  }

  # must go in other class
  method caller ( $name, Hash $h, |c ) {
    $h<extra> //= 'function address';
    return "Calling: $name, using $h.gist() and {|c.gist}";
  }
}

#-------------------------------------------------------------------------------
class A is X {
  my Hash $methods = %(
    func1 => %(
      :type<Constructor>,
    )
  );

  method _fallback ( $name, |c ) {
    say "test A";
    if $methods{$name} {
      return self.caller( $name, $methods, |c);
    }

    else {
      callsame;
    }
  }
}

#-------------------------------------------------------------------------------
class B is A {
  my Hash $methods = %(
    func2 => %(
      :type<Method>,
    )
  );

  method _fallback ( $name, |c ) {
    say "test B";
    if $methods{$name} {
      return self.caller( $name, $methods, |c);
    }

    else {
      callsame;
    }
  }
}


#-------------------------------------------------------------------------------
print "\n";

my A $a .= new;
note $a.func1( 'a', [<b c>], :g, :!h).gist();

print "\n";
my B $b .= new;
note $b.func2( 'a', [7,4,2], :b<k>, :h(2,4...10)).gist();
note $b.func1( 'c', [^3], :!g, :h).gist();

note $b.f1( 'c', [^3], :!g, :h).gist();










=finish
# this hash is build using the gir repo
my Hash $methods = %(
  new => %(                 # We know to prefix 'gtk_window_' in this module
    :type(Constructor),     # Type of routine
    :parameters([GEnum]),   # Parameter types
    :returns(N-GObject),    # Return type if any,
  ),

  get_default_size => %(
    :parameters([ gint-ptr, gint-ptr]),
  ),

  get_position => %(
    :parameters([ gint-ptr, gint-ptr]),
  ),
