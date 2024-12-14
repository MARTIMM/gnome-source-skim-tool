use v6.d;

# prevent inheriting from class Any
class T {
  method append ( $i where $i.^name eq 'Int' ) { ... }
}

class X is T {
  
}


my X $x .= new;
$x.append(10);
