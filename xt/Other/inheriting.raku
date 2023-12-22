use v6.d;

use Gnome::Gtk4::Label:api<2>;


class MyLabel is Gnome::Gtk4::Label {
  submethod BUILD ( *%options ) {
note "$?LINE %options.gist()";
  }

  method l ( --> Str ) {
    self.get-label;
  }

  method t ( --> Str ) {
    self.get-text;
  }
}


my MyLabel $t1 .= new-label( 'test1', :!my-opt, :abc(1));
note "$?LINE $t1.gist()";
note "$?LINE $t1.t;
note "$?LINE $t1.l;

my MyLabel $t2 .= new-with-mnemonic('_test2');
note "$?LINE $t2.gist()";
note "$?LINE $t2.t";
note "$?LINE $t2.l";
