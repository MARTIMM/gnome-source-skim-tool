#!/usr/bin/env -S rakudo
#-------------------------------------------------------------------------------

#use NativeCall;

#use Gnome::N::GlibToRakuTypes:api<2>;
#use Gnome::N::X:api<2>;
#Gnome::N::debug(:on);

use Gnome::Gtk4::Widget:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Label:api<2>;
use Gnome::Gtk4::Snapshot:api<2>;
use Gnome::Gtk4::Picture:api<2>;
use Gnome::Gtk4::Box:api<2>;
use Gnome::Gtk4::T-enums:api<2>;

use Gnome::Graphene::T-point:api<2>;
use Gnome::Graphene::T-size:api<2>;

use Gnome::Gdk4::T-rgba:api<2>;
use Gnome::Gdk4::Texture:api<2>;

use Gnome::Pango::Layout:api<2>;
use Gnome::Pango::T-types:api<2>;

#-------------------------------------------------------------------------------
my constant Texture = Gnome::Gdk4::Texture;
my constant PLayout = Gnome::Pango::Layout;

my constant Widget = Gnome::Gtk4::Widget;
my constant Window = Gnome::Gtk4::Window;
my constant Label = Gnome::Gtk4::Label;
my constant Snapshot = Gnome::Gtk4::Snapshot;
my constant Picture = Gnome::Gtk4::Picture;
my constant Box = Gnome::Gtk4::Box;

#-------------------------------------------------------------------------------
class RotateLabel is Picture {
  has Str $!label;
  has Num $!angle;

  submethod BUILD ( Str :$!label, Num() :$!angle is copy ) {
    $!angle %= 360;

    # Raku calculates with radians, Gnome with degrees.
    my $radians = $!angle*2*pi/360;

    my PLayout() $layout = self.create-pango-layout('');
#    $layout.set-indent(0);
    $layout.set-markup( $!label, $!label.chars);

    # Get size info of string
    my Int ( $x, $y, $w, $h) = self.get-text-info($layout);
#note "o: ( $x, $y), w x h: $w, $h";

#TODO test angle
# below 0 ≤ angle < 90
    my ( $w1, $w2, $h1, $h2, $new_width, $new_height, $nx, $ny);

    if 0 < $!angle ≤ 90 {
      ( $w1, $w2, $h1, $h2, $new_width, $new_height) =
        self.get-new-wh( $radians, $w, $h);
      $nx = $w2;
      $ny = 0;
    }

    elsif 90 < $!angle ≤ 180 {
      ( $w1, $w2, $h1, $h2, $new_width, $new_height) =
        self.get-new-wh( $radians - 0.5 * pi, $h, $w);
      $nx = $w1 + $w2;
      $ny = $h1;
    }

    elsif 180 < $!angle ≤ 270 {
      ( $w1, $w2, $h1, $h2, $new_width, $new_height) =
        self.get-new-wh( $radians - pi, $w, $h);
      $nx = $w1;
      $ny = $h1 + $h2;
    }

    elsif 270 < $!angle ≤ 360 {
      ( $w1, $w2, $h1, $h2, $new_width, $new_height) =
        self.get-new-wh( $radians - 1.5 * pi, $h, $w);
      $nx = 0;
      $ny = $h2;
    }

#note "nx, ny: $nx.Int(), $ny.Int()";
#note "new w and h: $new_width, $new_height";

    # Now we can use the values found above
    my Snapshot $snapshot .= new-snapshot;

    # Translate snapshots coordinate system
    my N-Point $n-point .= new( :x($nx), :y($ny));
    $snapshot.translate($n-point);

    # Rotate by $!angle egrees clockwise around origin
    $snapshot.rotate($!angle);

    # Now add the string in some color. It is rotated and moved.
    $snapshot.append-layout(
      $layout, N-RGBA.new( :red(1), :green(1), :blue(0), :alpha(1))
    );
    my N-Size() $n-size .= new( :width($new_width), :height($new_height));
    my Texture() $texture = $snapshot.free-to-paintable($n-size);

    self.set-size-request( $new_width, $new_height);
    self.set-paintable($texture);
    self.set-halign(GTK_ALIGN_START);
    self.set-valign(GTK_ALIGN_START);
  }

  #-----------------------------------------------------------------------------
  # Calculate new width and height
  method get-new-wh( $radians, $w, $h --> List ) {
    my $w1 = abs($w * cos($radians));
    my $w2 = abs($h * sin($radians));

    my $h1 = abs($w * sin($radians));
    my $h2 = abs($h * cos($radians));

    my $new_width = ($w1 + $w2).Int;
    my $new_height = ($h1 + $h2).Int;

    $w1, $w2, $h1, $h2, $new_width, $new_height
  }

  #-----------------------------------------------------------------------------
  # Get info of string
  method get-text-info( PLayout $layout --> List ) {
    my N-Rectangle $ink .= new;
    my N-Rectangle $log .= new;
    $layout.get-pixel-extents( $ink, $log);
    $log.x, $log.y, $log.width, $log.height
#    $ink.x, $ink.y, $ink.width, $ink.height
  }
}

#-------------------------------------------------------------------------------
use Gnome::Gdk4::Display:api<2>;
use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::N::N-Object:api<2>;

use Gnome::Gtk4::CssProvider:api<2>;
use Gnome::Gtk4::StyleContext:api<2>;
use Gnome::Gtk4::T-styleprovider:api<2>;

my constant N-MainLoop = Gnome::Glib::N-MainLoop;
my constant Display = Gnome::Gdk4::Display;
my constant CssProvider = Gnome::Gtk4::CssProvider;
my constant StyleContext = Gnome::Gtk4::StyleContext;

my N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class Helper {
  method exit ( ) {
    $main-loop.quit;
  }
}

#-------------------------------------------------------------------------------
sub MAIN ( Rat $angle = 10.5 ) {
  my Str $css = Q:q:to/EOCSS/;
    .rotate-label {
      border-style: solid;
      border-color: #aeaeff;
      border-width: 2px;
    }
    EOCSS

  my CssProvider $css-provider .= new-cssprovider;
  $css-provider.load-from-data( $css, $css.chars);
  my StyleContext $style-context .= new;
  $style-context.add-provider-for-display(
    Display.new.get-default,
    $css-provider,
    GTK_STYLE_PROVIDER_PRIORITY_APPLICATION
  );

  my RotateLabel $rotate-label1 .= new-picture(
    :label('Big <b>Test</b> Label Text'), :$angle
  );
  $rotate-label1.add-css-class('rotate-label');
  
  my RotateLabel $rotate-label2 .= new-picture(
    :label('<span bgcolor="purple">Big Test Label <b><span fgcolor="lightblue">Text</span></b></span>'),
    :angle($angle + 90)
  );
  $rotate-label2.add-css-class('rotate-label');

  my RotateLabel $rotate-label3 .= new-picture(
    :label('<i>Big Test Label Text</i>'), :angle($angle + 180)
  );
  $rotate-label3.add-css-class('rotate-label');

  my RotateLabel $rotate-label4 .= new-picture(
    :label('<span fgcolor="lightgreen">Big</span> Test Label Text'),
    :angle($angle + 270)
  );
  $rotate-label4.add-css-class('rotate-label');

  with my Box $box .= new-box( GTK_ORIENTATION_HORIZONTAL, 0) {
    .append($rotate-label1);
    .append($rotate-label2);
    .append($rotate-label3);
    .append($rotate-label4);
  }

  with my Window $window .= new-window {
    .set-title('Rotated text widget');
    .set-child($box);
    .present;

    .register-signal( Helper.new, 'exit', 'close-request');
  }

  $main-loop.run;
}
