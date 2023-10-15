
#use lib 'xt/Other/lib';

use NativeCall;

use Gnome::Glib::N-GList:api<2>;
use Gnome::Glib::List:api<2>;
use Gnome::Glib::T-List:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-GObject:api<2>;
use Gnome::N::NativeLib:api<2>;

#use Gnome::N::GnomeRoutineCaller:api<2>;

#-------------------------------------------------------------------------------
# Helpers to get data in and out

my Gnome::Glib::List $list .= new;

# Fill list
sub fill-list ( --> N-GList ) {
  say "\nFill list with numbers";

  my N-GList $n-glist .= new;
  for 2..12 -> $i {
    my gpointer $data = pack($i);
    note "Data inserted: ", unpack($data);
    $n-glist = $list.append( $n-glist, $data);
  }
  
  $n-glist
}


# Pack and store data to prevent garbage collecting
my Hash $saved-data = %();
sub pack ( Int $n --> gpointer ) {
  my $o = CArray[gint].new;
  $o[0] = $n;
  my gpointer $data = nativecast( gpointer, $o);

  $saved-data{$n} = $o;
  $data
}

sub unpack ( gpointer $p --> Int ) {
  my $o = nativecast( CArray[gint], $p);
  $o[0]
}

sub destroy ( gpointer $p ) {
  say 'destroy data: ', unpack($p);
}

#`{{
sub show-sig ( Signature $sig, Str $i = '' ) {
note $?LINE, $i, $sig.gist;
  for $sig.params -> $p {
note $?LINE, $i, $p.gist;
#    say "$i name => $p.name(), type => $p.type()";
    show-sig( $p.sub_signature, $i ~ '   ') if $p.sub_signature.defined;
  }
}
}}

#`{{
Signature of x_clear_list:
  (NativeCall::Types::CArray[N-GList] $, Callable $h (NativeCall::Types::Pointer $, int32 $, Str $))
  (Sub+{NativeCall::Native[Sub,Str]})
P name and type: , (CArray[N-GList]), (Signature)
P name and type: $h, (Callable), (NativeCall::Types::Pointer, int32, Str)

sub x_clear_list ( CArray[N-GList], Callable $h ( gpointer, int32, Str) )
  is native(glib-lib())
  is symbol('g_clear_list')
  { * }

show-sig(&x_clear_list.signature);
}}

#-------------------------------------------------------------------------------
# T1 direct use of native sub
say "\n1st try …";
sub g_clear_list ( CArray[N-GList], Callable $h (gpointer) )
  is native(glib-lib())
#  is symbol('g_clear_list')
  { * }

#say "\nSignature:\n  ", &g_clear_list.signature, "\n  ", &g_clear_list.WHAT;
#for &g_clear_list.signature.params -> $p {
#  say 'P name and type: ', $p.name, ', ', $p.type, ', ', $p.sub_signature, ', ', $p.sub_signature.^name;
#}


my N-GList $n-glist = fill-list();
my $list-ptr = CArray[N-GList].new($n-glist);
g_clear_list( $list-ptr, &destroy);

#-------------------------------------------------------------------------------
# T2 Test the helper
say "\n2nd try …";

$n-glist = fill-list();
$list-ptr = CArray[N-GList].new($n-glist);
#show-sig(&g_clear_list.signature);

my $f = native-function;
$f( $list-ptr, &destroy);

#-------------------------------------------------------------------------------
sub native-function ( --> Callable ) {

  # Create list of parameter types and start with inserting fixed arguments
  my @parameterList = (
    Parameter.new(type => CArray[N-GList]),
    Parameter.new(
      name => '$cb',
      type => Callable,
      sub-signature => Signature.new(
        :params(
          Parameter.new(
            type => gpointer,
            name => '$p',
          ),
        ),
        :returns(Pointer),
      ),
    )
  );

  # Create return type
  my $returns = Pointer;

  # Create signature
  my Signature $signature .= new( :params(|@parameterList), :$returns);
#note "$?LINE $routine-name, $signature.gist()";

  # Get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  my Callable $f = nativecast(
    $signature, cglobal( glib-lib(), 'g_clear_list', Pointer)
  );

  $f
}


#-------------------------------------------------------------------------------
# T3 use the class where it is defined
my Gnome::Glib::T-List $t-list .= new;
say "\n3rd try …";
$n-glist = fill-list();
$list-ptr = CArray[N-GList].new($n-glist);
$t-list.clear-list( $list-ptr, &destroy);

