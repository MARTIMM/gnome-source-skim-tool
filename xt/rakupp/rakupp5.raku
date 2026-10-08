use v6.d;

class A {
}


my A $a;

say $a.^can('index');
say $a.index();
say $a.index('ca','be','any', 'anything');









=finish
#TL:1:Gnome::Glib::N-SList:
#-------------------------------------------------------------------------------
#--[Module Imports]-------------------------------------------------------------
#-------------------------------------------------------------------------------

use NativeCall;
use lib '../../gnome-api2/gnome-glib/lib', '../../gnome-api2/gnome-native/lib';

use Gnome::Glib::N-SList:api<2>;
use Gnome::Glib::T-slist:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
#use Gnome::N::N-Object:api<2>;
use Gnome::N::NativeLib:api<2>;
#use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

# Keep is needed because the data is always owned by the caller. This means
# that we must prevent Raku to clean it up when going out of scpe.
my @keep = ();
sub pack ( Int $n --> gpointer ) {
  my $o = CArray[gint].new($n);
  @keep.push($o);
  nativecast( gpointer, $o)
}

my Gnome::Glib::N-SList() $slist .= new;
my N-SList() $n-slist;
my gpointer $data;


#Gnome::N::debug(:on);
$n-slist = $slist.prepend( $n-slist, $data = pack(100));
say "length: ",  $slist.length($n-slist);

#my N-Object() $nsl = $n-slist;
say "$?LINE g_slist_index: ", g_slist_index( $n-slist, $data);
say "$?LINE \$slist.index: ", $slist.index( $n-slist, $data);

say $slist.^can("index").raku;

#.say for $slist.^methods(:all);

sub g_slist_index ( N-SList, gpointer --> gint )
  is native(glib-lib())
  {*}


#  index => %( :type(Function), :is-symbol<g_slist_index>,  :returns(gint), :parameters([ N-Object, gpointer])),
