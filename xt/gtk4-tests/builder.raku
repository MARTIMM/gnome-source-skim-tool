
use v6.d;
use NativeCall;

use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::Glib::N-Error:api<2>;
use Gnome::Glib::T-error:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;


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

  method b1-press ( Button() :_native-object($button1), Button :$button2 ) {
    say 'button1 pressed';
    $button2.set-sensitive(True);
    $button1.set-sensitive(False);
  }

  method b2-press ( ) {
    say 'button2 pressed';
    $main-loop.quit;
  }
}

my SH $sh .= new;

#-------------------------------------------------------------------------------
my $e;
my Str $path = "$*HOME/Languages/Raku/Projects/gnome-source-skim-tool";
my BuilderScope $builder-scope .= new-buildercscope;

my Builder $builder .= new-builder;

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

with my Window $window .= new(:build-id<MyWindow>) {
  .present;
}

$main-loop.run;