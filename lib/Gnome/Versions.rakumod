use v6.d;

use META6;
use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
unit class Gnome::Versions;

has Str $!repopath;
has Hash $!repolib;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!repolib = %();
  $!repopath = '.';
}

#-------------------------------------------------------------------------------
method set-repopath ( Str:D $path where $path.IO.d ) {
  $!repopath = $path;
}

#-------------------------------------------------------------------------------
method add-repos ( *%repo-pairs ) {
  for %repo-pairs.kv -> Str $repokey, Str $repo {
    my Str $rpk = $!repopath ~ '/' ~ $repo;
    if $rpk.IO.d {
      given $!repolib{$repokey} {
        .<path> = $rpk;
        .<package> = SkimSource(SkimSource.enums{$repokey});
        .<name> = "Gnome::$repokey";
        if $repokey eq 'GdkPixbuf' {
          .<libname> = 'gdk-pixbuf2';
        }
        
        else {
          .<libname> = $repokey.lc;
        }
      }
      self.raku-version($repokey);
      self.gnome-version($repokey);
    }
  }

note "$?LINE $!repolib<Gtk4>.gist()";
}

#-------------------------------------------------------------------------------
method raku-version ( Str $repokey ) {
  my Str $meta-file = $!repolib{$repokey}<path> ~ '/META6.json';
  $!repolib{$repokey}<raku-version> =
    META6.new(:file($meta-file))<version>.Str if $meta-file.IO.e;
}

#-------------------------------------------------------------------------------
method gnome-version ( Str $repokey ) {
  my Str $version;

  given $repokey {
    when m/ Gtk3 / {
      $version = self.dnf-versions($!repolib{$repokey}<libname>);
      return unless ?$version;

      $!repolib<Gtk3><lib-version> = $version;
      $!repolib<Gdk3><lib-version> = $version;
    }

    when m/ Gtk4 / {
      $version = self.dnf-versions($!repolib{$repokey}<libname>);
      return unless ?$version;

      $!repolib<Gtk4><lib-version> = $version;
      $!repolib<Gdk4><lib-version> = $version;
      $!repolib<Gsk4><lib-version> = $version;
    }

    when m/ Gdk\-Pixbuf2 / {
      $version = self.dnf-versions($!repolib{$repokey}<libname>);
      return unless ?$version;

      $!repolib<GdkPixbuf><lib-version> = $version;
    }

    when m/ Graphene / {
      $version = self.dnf-versions($!repolib{$repokey}<libname>);
      return unless ?$version;

      $!repolib<Graphene><lib-version> = $version;
    }

    when m/ Pango / {
      $version = self.dnf-versions($!repolib{$repokey}<libname>);
      return unless ?$version;

      $!repolib<Pango><lib-version> = $version;
    }

    when m/ Glib / {
      $version = self.dnf-versions($!repolib{$repokey}<libname>);
      return unless ?$version;

      $!repolib<Glib><lib-version> = $version;
      $!repolib<GObject><lib-version> = $version;
      $!repolib<Gio><lib-version> = $version;
    }
  }
}

#-------------------------------------------------------------------------------
method dnf-versions ( Str $libname --> Str ) {
  my Str $version;

  # Get the library version using Fedora dnf package manager
  my Proc $p = shell "dnf list $libname | grep x86_64", :out, :err;
  for $p.out.lines -> $l {
    # skip some messages
    next if $l ~~ m/ Updating | Repositories /;

    # Example output: glib.x86_64 1:1.2.10-75.fc42 fedora
    # Split on spaces and ignore libname
    my Str ( $, $v) = $l.split(' ');

    # Remove part from version starting from a dash and system name
    $v ~~ s/ '-' .* $//;
    if ?$v {
      $version = $v;
      last;
    }
  }

  # Close in/out
  $p.out.close;
  $p.err.close;
  
  $version
}
