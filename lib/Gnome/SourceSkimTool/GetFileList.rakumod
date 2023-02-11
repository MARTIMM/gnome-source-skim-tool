
use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GetFileList;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$test-cwd is copy ) {

  # $test-cwd may be significant part of path
  with $test-cwd // $*CWD {
    when / 'gnome-gtk3' / { $*use-doc-source = Gtk3; }
    when / 'gnome-gdk3' / { $*use-doc-source = Gdk3; }
    when / 'gnome-gtk4' / { $*use-doc-source = Gtk4; }
    when / 'gnome-gdk4' / { $*use-doc-source = Gdk4; }
    when / 'gnome-glib' / { $*use-doc-source = Glib; }
    when / 'gnome-gio' / { $*use-doc-source = Gio; }
    when / 'gnome-gobject' / { $*use-doc-source = GObject; }
    when / 'gnome-cairo' / { $*use-doc-source = Cairo; }
    when / 'gnome-pango' / { $*use-doc-source = Pango; }

    default {
      die 'Use :$test-cwd to specify gnome source for testing';
    }
  }
}

#-------------------------------------------------------------------------------
method set-source-dir ( --> Str ) {
  my $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my $source-dir = '';

  with $*use-doc-source {
    when Gtk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gtk'; }
    when Gdk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gdk'; }
    when Gtk4 { $source-dir = [~] $source-root, 'gtk+-', VGtk4, '/gtk'; }
    when Gdk4 { $source-dir = [~] $source-root, 'gtk+-', VGtk4, '/gdk'; }
#    when  { $source-dir = [~] $source-root, '', , ''; }
  }

  $source-dir
}

#-------------------------------------------------------------------------------
method set-gtkdoc-dir ( --> Str ) {
  my $dir = '';

  with $*use-doc-source {
    when Gtk3 { $dir = 'Gtkdoc/Gtk3'; }
    when Gdk3 { $dir= 'Gtkdoc/Gdk3'; }
    when Gtk4 { $dir = 'Gtkdoc/Gtk4'; }
    when Gdk4 { $dir = 'Gtkdoc/Gdk4'; }
#    when  {  = ''; }
  }

  mkdir (SKIMTOOLROOT ~ 'Gtkdoc/Gtk3'), 0o700 unless (SKIMTOOLROOT ~ 'Gtkdoc/Gtk3').IO.e;

  $dir
}

#-------------------------------------------------------------------------------
method generate-gtkdoc ( ) {
  my Str $gd = self.set-gtkdoc-dir;
  my Str $out1 = '--output-dir ' ~ SKIMTOOLROOT ~ $gd;
  my Str $src = '--source-dir ' ~ self.set-source-dir;
  my Str $mod = '--module ' ~ $*use-doc-source.key.lc;

  #my Proc $p;
  shell "/usr/bin/gtkdoc-scan $out1 $src $mod";

  my $curr-dir = $*CWD;
  chdir SKIMTOOLROOT ~ $gd;
  my Str $out2 = '--output-dir ' ~ SKIMTOOLROOT ~ $gd ~ '/docs';
  shell "/usr/bin/gtkdoc-mkdb $out2 $src $mod --xml-mode";
  chdir $curr-dir;
}








=finish


gtkdoc-scan --output-dir d --source-dir Gnome/gtk-4.6.3/gtk --module gtk4
gtkdoc-mkdb --module gtk3 --source-dir ../Gnome/gtk+-3.24.24/gtk --output-dir e --xml-mode


#-------------------------------------------------------------------------------
method make-dir-list ( ) {
  my $source-dir = self.set-source-dir;
  my $sl-name = self.set-source-list-name;

  # get a sorted list of c code filenames from the source directory
  my Str $list-text = '';
  for (dir $source-dir).sort -> $f is copy {
    next unless $f.Str ~~ / \. c $/;
    $f .= basename;
    $f ~~ s/ \. c $//;
    $list-text ~= "$f\n";
  }

  # test for the programs config directory and write the list of names
  mkdir (SKIMTOOLROOT ~ 'Lists'), 0o700 unless (SKIMTOOLROOT ~ 'Lists').IO.e;
  ( [~] SKIMTOOLROOT, 'Lists/', $sl-name).IO.spurt($list-text);

  # test for dir 'xt/NewModules'
  $*dump-result-dir = 'xt/NewModules';
  mkdir( $*dump-result-dir, 0o766) unless 'xt/NewModules'.IO.e;
}

#-------------------------------------------------------------------------------
# load the list of source filenames
method load-dir-list ( --> List ) {
  my $source-dir = self.set-source-dir;
  my $sl-name = self.set-source-list-name;
  
  ( [~] SKIMTOOLROOT, 'Lists/', $sl-name).IO.slurp.lines.List;
}

#-------------------------------------------------------------------------------
method set-source-dir ( --> Str ) {
  my $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my $source-dir = '';

  with $*use-doc-source {
    when Gtk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gtk'; }
    when Gdk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gdk'; }
    when Gtk4 { $source-dir = [~] $source-root, 'gtk+-', VGtk4, '/gtk'; }
    when Gdk4 { $source-dir = [~] $source-root, 'gtk+-', VGtk4, '/gdk'; }
#    when  { $source-dir = [~] $source-root, '', , ''; }
  }

  $source-dir
}

#-------------------------------------------------------------------------------
method set-source-list-name ( --> Str ) {
  my $source-list-name = '';

  with $*use-doc-source {
    when Gtk3 { $source-list-name = '/gtk3.txt'; }
    when Gdk3 { $source-list-name = '/gdk3.txt'; }
    when Gtk4 { $source-list-name = '/gtk4.txt'; }
    when Gdk4 { $source-list-name = '/gdk4.txt'; }
#    when  { $source-dir = [~] $source-root, '', , ''; }
  }

  $source-list-name
}

#-------------------------------------------------------------------------------
method get-sources ( ) {
  my Str $src-fname = $*sub-prefix;

  with $*use-doc-source {
    when Pango { $src-fname ~~ s:g/ '_' /-/; }
    default { $src-fname ~~ s:g/ '_' //; }
  }

  my @parts = $*other-prefix.split(/<[_-]>/);
  $*lib-classname = @parts>>.tc.join;
  $*raku-classname = @parts[1..*-1]>>.tc.join;

  my $source-dir = self.set-source-dir;
#  my $source-root = SKIMTOOLROOT ~ 'Gnome/';

  $*include-content = "$source-dir/$src-fname.h".IO.slurp;
  $*source-content = "$source-dir/$src-fname.c".IO.slurp
    if "$source-dir/$src-fname.c".IO.r;

  with $*use-doc-source {
    when Gtk3 { $*library = '&gtk-lib'; $*raku-modname = 'Gtk3'; }
    when Gdk3 { $*library = '&gdk-lib'; $*raku-modname = 'Gdk3'; }
    when Gtk4 { $*library = '&gtk4-lib'; $*raku-modname = 'Gtk4'; }
    when Gdk4 { $*library = '&gdk4-lib'; $*raku-modname = 'Gtk4'; }
#    when  { $source-dir = [~] $source-root, '', , ''; }
  }
}

