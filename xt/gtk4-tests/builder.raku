
use v6.d;
use NativeCall;

use XML;
use XML::XPath;

use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;

use Gnome::N::NativeLib:api<2>;
use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);


use Gnome::Gtk4::Builder:api<2>;
use Gnome::Gtk4::BuilderCScope:api<2>;
use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Window:api<2>;

#-------------------------------------------------------------------------------
constant MainLoop = Gnome::Glib::N-MainLoop;

constant Window = Gnome::Gtk4::Window;
constant Button = Gnome::Gtk4::Button;
constant Builder = Gnome::Gtk4::Builder;
constant BuilderScope = Gnome::Gtk4::BuilderCScope;
#-------------------------------------------------------------------------------
my MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class SH {
  method stopit ( --> gboolean ) {
    say 'close request';
    $main-loop.quit;

    0
  }

  method b1-press (
    Button() :_native-object($button1), Button :$button2, :$new-label
  ) {
    say 'button1 pressed';
    $button1.set-label($new-label);
    $button2.set-sensitive(True);
    $button1.set-sensitive(False);
  }

  method b2-press ( ) {
    say 'button2 pressed';
    $main-loop.quit;
  }

  method query (
    gint $x, gint $y, gboolean $kmode, N-Object $tooltip
    --> gboolean
  ) {
    note "X & Y: $x, $y";
    False;
  }




  has Gnome::Gtk4::BuilderCScope $!builder-scope;
  has Gnome::Gtk4::Builder $!builder;
  submethod BUILD ( ) {
    $!builder-scope .= new-buildercscope;
  }

#TODO need to remove first and last argument from |c
#TODO must be able to handle more types in named arguments instead of only
#     the [ type, build-id] construction
  method add-callback-signals ( Hash $h ) {
    for $h.keys -> $function-name {
      my $object = $h{$function-name}[0];
      my Hash $option-structures = $h{$function-name}[1];
      $!builder-scope.add-callback-symbol(
        $function-name, sub ( *@c ) {

#TODO Find out why there are no arguments. Should be 2 at least.
#DONE The definition of the callback function defined in the Hash entry for the function add-callback-symbol is :(). This means there are no arguments expected. Now tested with :(N-Object) because first arg is always the object for the signal. Below shown by getting this first argument (a button) and getting the label text from it. Now we need different definitions for the several types of exents and handle it as in register-signal(). What we need is the type of object and the name of the signal.

          my Hash $options = %();
          for $option-structures.keys -> $named-arg {
            my $type = $option-structures{$named-arg}[0];
            my $value = $option-structures{$named-arg}[1];
            if $type.^name ~~ m/ Gnome '::' .+? '::' .+ / {
              $options{$named-arg} = $type.new(:build-id($value));
            }

            else {
              $options{$named-arg} = $value;
            }
          }
note "$?LINE $function-name, @c.raku()";
          # Test first argument
          my N-Object $o = @c.shift;
          my Str $n = _name_from_instance($o);
          note "Object name: ", $n;
          note "Object type: ", _from_name($n), ', ', $!builder.get-type-from-name($n);

          my Button() $b = $o;
          note "Object type: ", $b.get-class-gtype;
          note "Object name: ", $b.get-class-name;
          note "Label text: ", $b.get-label;
          
          # Call user function to handle event
          $object."$function-name"( |@c, |$options)
        }
      );
    }
  }

#TODO test if build ids are still found when new builders are created
  method load-ui-old ( Str:D $path, Hash $h = %() --> Gnome::Gtk4::Builder ) {
    die "Error file $path not found or not readable" unless $path.IO.r;
    $!builder .= new-builder;
    self.add-callback-signals($h) if ?$h;
    $!builder.set-scope($!builder-scope);

    my $e = CArray[N-Error].new(N-Error);
    my Bool $r = $!builder.add-from-file( $path, $e);
    die "Error reading from file in builder: $e[0].message()" if !$r;
    $!builder
  }

  method load-ui ( Str:D $file ) {
    my XML::XPath $xpath .= new(:$file);

  }

  method find-objects ( XML::XPath $xpath ) {
    my @elements = $xpath.find('//object');
    for @elements -> XML::Element $element {
    }
  }

  method set-handler (
    Mu $handler-object, Str $method, Str $signal-name, *%options
  ) {
  }
}

sub _from_name ( Str $name --> GType )
  is native(&gobject-lib)
  is symbol('g_type_from_name')
  { * }

sub _name_from_instance ( N-Object $instance --> Str )
  is native(&gobject-lib)
  is symbol('g_type_name_from_instance')
  { * }

my SH $sh .= new;
 
#-------------------------------------------------------------------------------
my BuilderScope $builder-scope .= new-buildercscope;
my Builder $builder .= new-builder;

##`{{
my Str $path = "$*HOME/Languages/Raku/Projects/gnome-source-skim-tool";
$sh.set-handler( $sh, 'stopit', 'close-request');
$sh.load-ui-old(
  "$path/xt/Other/Cambalache/t1.ui", %(
    :stopit( $sh, %()),
    :b1-press( $sh, %(
      :button2( [ Button, 'GoodByeButton']),
      :_native-object( [ Button, 'HelloButton']),
      :new-label( [ Str, 'Have a nice day']),
    )),
    :query( $sh, %()), 
    :b2-press( $sh, %()),
  )
);
#}}





#`{{
my $e;
my Str $path = "$*HOME/Languages/Raku/Projects/gnome-source-skim-tool";

$builder-scope.add-callback-symbol(
  'stopit', sub ( |c ) { $sh.stopit(|c); },
);

$builder-scope.add-callback-symbol(
  'b1-press', sub ( |c ) {
    $sh.b1-press(
      |c,
      :button2(Button.new(:build-id<GoodByeButton>)),
      :_native-object(Button.new(:build-id<HelloButton>)),
    );
  },
);

$builder-scope.add-callback-symbol(
  'b2-press', sub ( |c ) { $sh.b2-press(|c); },
);

$builder.set-scope($builder-scope);

$e = CArray[N-Error].new(N-Error);
my Bool $r = $builder.add-from-file( "$path/xt/Other/Cambalache/t1.ui", $e);
if !$r {
  note "Error: $e[0].message()";
  exit;
}
#}}

with my Window $window .= new(:build-id<MyWindow>) {
  .present;
}

#Gnome::N::debug(:on);
$main-loop.run;