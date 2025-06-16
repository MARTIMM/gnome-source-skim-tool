#!/usr/bin/env -S rakudo
#-------------------------------------------------------------------------------

use NativeCall;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;
use Gnome::N::X:api<2>;
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
#use Gnome::Gdk4::T-types:api<2>;

use Gnome::Pango::Layout:api<2>;
use Gnome::Pango::T-types:api<2>;

use Gnome::Glib::N-MainLoop:api<2>;

#-------------------------------------------------------------------------------
constant N-MainLoop = Gnome::Glib::N-MainLoop;
constant Widget = Gnome::Gtk4::Widget;
constant Window = Gnome::Gtk4::Window;
constant Label = Gnome::Gtk4::Label;
constant Snapshot = Gnome::Gtk4::Snapshot;
constant Picture = Gnome::Gtk4::Picture;
constant Box = Gnome::Gtk4::Box;
constant PLayout = Gnome::Pango::Layout;

my N-MainLoop $main-loop .= new-mainloop( N-Object, True);

#-------------------------------------------------------------------------------
class Helper {
  method exit ( ) {
    $main-loop.quit;
  }
}

#-------------------------------------------------------------------------------
class RotateLabel is Picture {
  has Str $!label;
  has Num $!angle;

  submethod BUILD ( Str :$!label, Num() :$!angle is copy ) {
    $!angle %= 360;

    my PLayout() $layout = self.create-pango-layout('');
    $layout.set-indent(0);
    $layout.set-text( $!label, $!label.chars);

    # Get size info of string
    my Int ( $x, $y, $w, $h) = self.get-text-info($layout);
#note "o: ( $x, $y), w x h: $w, $h";

#TODO test angle
# below 0 ≤ angle < 90
    my ( $w1, $w2, $h1, $h2, $new_width, $new_height, $nx, $ny);

    # Raku calculates with radians, Gnome with degrees.
    my $radians = $!angle*2*pi/360;

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
    my Gnome::Gdk4::Texture() $texture = $snapshot.free-to-paintable($n-size);

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
    ( $log.x, $log.y, $log.width, $log.height)
  }
}

#-------------------------------------------------------------------------------
sub MAIN ( Int $angle = 10 ) {
  my Helper $helper .= new;

  my RotateLabel $RotateLabel1 .= new-picture(
    :label('Big Test Label Text'), :$angle
  );

  my RotateLabel $RotateLabel2 .= new-picture(
    :label('Big Test Label Text'), :angle($angle + 90)
  );

  my RotateLabel $RotateLabel3 .= new-picture(
    :label('Big Test Label Text'), :angle($angle + 180)
  );

  my RotateLabel $RotateLabel4 .= new-picture(
    :label('Big Test Label Text'), :angle($angle + 270)
  );
  with my Box $box .= new-box( GTK_ORIENTATION_HORIZONTAL, 0) {
    .append($RotateLabel1);
    .append($RotateLabel2);
    .append($RotateLabel3);
    .append($RotateLabel4);
  }

  with my Window $window .= new-window {
    .set-title('Rotated text widget');

    .set-child($box);
    .present;

    .set-margin-top(0);
    .set-margin-bottom(0);
    .set-margin-start(0);
    .set-margin-end(0);

    .register-signal( $helper, 'exit', 'close-request');
  }

  $main-loop.run;
}
