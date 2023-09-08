

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGirSource::ApiIndex;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare;
constant \ApiIndex = Gnome::SourceSkimTool::SkimGirSource::ApiIndex;

#-------------------------------------------------------------------------------
my SkimSource $*gnome-package = Gtk3;
my Str $*gnome-class = 'GtkButton';
my Hash $*work-data;
my Bool $*verbose = True;

my Prepare $gfl .= new;

my ApiIndex $api-actions;
$api-actions .= new;
#$api-actions.load-objects;
#exit(0);

add-hierarchy($gfl.get-gtkdoc-file( '.hierarchy', :!txt));
my Hash $objects := $api-actions.objects;
$gfl.display-hash( $objects<GtkWindow>, :label<GtkWindow>);

#-------------------------------------------------------------------------------
sub add-hierarchy ( Str $gtkdoc-text ) {
 
  my Str $text = $gtkdoc-text.IO.slurp;
  my Hash $objects := $api-actions.objects;

  my Hash $tree = %();
  my Hash $o;

  my Str $current-top-class = '';
  my Array $classes = [];
  my Int $previous-indent = 0;
  for $text.lines -> $line {
    my Int $indent = 0;
    $line ~~ m/^ $<indent> = [\s*] $<class> = [.+] $/;
    $indent = ($<indent>.Str.chars / 2).Int if ?$<indent>;
    my $class = $<class>.Str;
    $classes[$indent] = $class;

    # it starts at indent 0 so $current-top-class is defined quick
    if $indent == 0 {
      $current-top-class = $class;
    }

    if $current-top-class eq 'GInterface' {
      if $indent > 0 {
        $objects{$class}<class-type> = 'role';
        $objects{$class}<location> = 'leaf';
      }
    }

    elsif $current-top-class eq 'GBoxed' {
      $objects{$class}<class-type> = 'boxed';
      $objects{$class}<location> = 'leaf';
    }

    elsif $current-top-class eq 'GFlags' {
      $objects{$class}<class-type> = 'enum';
      $objects{$class}<location> = 'leaf';
    }

    elsif $indent == 1 {
      $objects{$class}<class-type> = 'gobject';
      $objects{$class}<location> = 'top';
      $objects{$class}<leaf> = True;
      $objects{$classes[$indent-1]}<leaf> = False;
    }

    elsif $indent > 1 {
      $objects{$class}<class-type> = $classes[2] eq 'GtkWidget'
                                     ?? 'widget' !! 'gobject';
      $objects{$class}<parent> = $classes[$indent-1];

      # Assume this class is a leaf. Then make the parent <leaf> False
      $objects{$class}<leaf> = True;
      $objects{$classes[$indent-1]}<leaf> = False;
    }

    $previous-indent = $indent;
#note "$?LINE: $indent, $class";
  }
}
