
role A { method x (--> Int) {10;} }
role B { method x (--> Int) {10;} }
class D does A does B { method x (--> Int) {self.A::x + self.B::x} }
my D $x .= new;
$x.x.say      # output: 20

