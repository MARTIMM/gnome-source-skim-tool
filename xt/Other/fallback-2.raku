
#-------------------------------------------------------------------------------
class X {
  method FALLBACK ( $name, |c ) {
    my Bool $_fallback-v2-ok = False;
    my $r = self._fallback( $name, $_fallback-v2-ok, |c);
    die "method $name not found" unless $_fallback-v2-ok;
    $r
  }
}

#-------------------------------------------------------------------------------
class T {
  method caller ( $name, Hash $h, |c ) {
    $h<extra> //= 'function address';
    return "Calling: $name, using $h.gist() and {|c.gist}";
  }
}

#-------------------------------------------------------------------------------
role OO::RA {
  my Hash $methods = %(
    func2a => %(
      :type<Role>,
    )
  );

  method _fallback ( $name, Bool $_fallback-v2-ok is rw, |c ) {
    say "test OO::RA";
    if $methods{$name} {
      $_fallback-v2-ok = True;
      return self.caller( $name, $methods, |c);
    }
  }
}

#-------------------------------------------------------------------------------
role RB {
  my Hash $methods = %(
    func2b => %(
      :type<Dunno>,
    )
  );

  method _fallback ( $name, Bool $_fallback-v2-ok is rw, |c ) {
    say "test RB";
    if $methods{$name} {
      $_fallback-v2-ok = True;
      return self.caller( $name, $methods, |c);
    }
  }
}

#-------------------------------------------------------------------------------
class A is X is T does OO::RA does RB {
  my Hash $methods = %(
    func1 => %(
      :type<Constructor>,
    )
  );

  method _fallback ( $name, Bool $_fallback-v2-ok is rw, |c ) {
    say "test A";
#    note "A, fallbacks in fallback before use: ", self.^can('_fallback').gist;
    if $methods{$name} {
      $_fallback-v2-ok = True;
      return self.caller( $name, $methods, |c);
    }

    else {
#      note "A, fallbacks in fallback: ";
#      for @(self.^can('_fallback')) -> $f {
#        note '  fb: ', $f.signature;
#      }

      my $r = self.OO::RA::_fallback( $name, $_fallback-v2-ok, |c);
      return $r if $_fallback-v2-ok;

      $r = self.RB::_fallback( $name, $_fallback-v2-ok, |c);
      return $r if $_fallback-v2-ok;

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

  method _fallback ( $name, Bool $_fallback-v2-ok is rw, |c ) {
    say "test B";
    if $methods{$name} {
      $_fallback-v2-ok = True;
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
note $a.func1( 'a', [<b c>], :g, :!h).gist();                 # func1 in A

print "\n";
my B $b .= new;
note $b.func2( 'a', [7,4,2], :b<k>, :h(2,4...10)).gist();     # func2 in B
note $b.func1( 'c', [^3], :!g, :h).gist();                    # func1 in A

note $b.func2a( 'ra', ['2a'], :s<ka>, :qq(0,4...16)).gist();  # func2a in RA
note $b.func2b( 'ra', ['2a'], :s<ka>, :qq(0,4...16)).gist();  # func2b in RB

note $b.f1( 'c', [^3], :!g, :h).gist();










=finish
# this hash is build using the gir repo
my Hash $methods = %(
  new => %(                 # We know to prefix 'gtk_window_' in this module
    :type(Constructor),     # Type of routine
    :parameters([GEnum]),   # Parameter types
    :returns(N-Object),    # Return type if any,
  ),

  get_default_size => %(
    :parameters([ gint-ptr, gint-ptr]),
  ),

  get_position => %(
    :parameters([ gint-ptr, gint-ptr]),
  ),
