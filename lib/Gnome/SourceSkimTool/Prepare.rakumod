
use v6.d;

use Gnome::N::NativeLib; #:api<2>
use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::SkimGirSource;


#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Prepare:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  if $*generate-code {
    $*external-modules = %(
      :NativeCall(EMTRakudo), 'Gnome::N::NativeLib' => EMTInApi2,
      'Gnome::N::N-Object' => EMTInApi2,
      'Gnome::N::GlibToRakuTypes' => EMTInApi2,
    );
  }

  elsif $*generate-test {
    $*external-modules = %(
      :Test(EMTRakudo), :NativeCall(EMTRakudo),
      'Gnome::N::NativeLib' => EMTInApi2,
      'Gnome::N::N-Object' => EMTInApi2,
      'Gnome::N::GlibToRakuTypes' => EMTInApi2,
      'Gnome::N::X' => EMTInApi2,
    );
  }

  else {
    $*external-modules = %();
  }

  $*verbose //= False;

  # A list of keys to search for in the map depending in the package name
  # Initialisation delayed until needed
  @*map-search-list = ();

  # Remove package prefix if there is any attached to the gnome class
  # $*gnome-class is set before init of Prepare
  $*gnome-class = self.drop-prefix($*gnome-class);
  $*work-data = self.prepare-work-data($*gnome-package);

#note "$?LINE $*gnome-package $*gnome-class";

  mkdir $*work-data<gir-module-path>, 0o700
    unless $*work-data<gir-module-path>.IO ~~ :e;

  # Add/modify some more global work data
  if ?$*gnome-class {

    # Exceptions (as always >sic<)
    if $*gnome-class ~~ m/ SList / {
      $*work-data<sub-prefix> = 'g_slist_';
      $*work-data<raku-class-name> = $*work-data<raku-package> ~ '::SList';
    }

    elsif $*gnome-package ~~ GdkPixbuf {
      # done in prepare-work-data()
    }

    elsif $*gnome-package ~~ Graphene {
      # done in prepare-work-data()
      my Str $classname = $*work-data<gnome-name>;
      $classname ~~ s/^ graphene_ //;
      $classname ~~ s/ _t $//;
      $*work-data<raku-class-name> =
        [~] $*work-data<raku-package>, '::', $classname.tc;
      $*work-data<raku-name> = $classname.tc;
      $*work-data<sub-prefix> = "graphene_{$classname}_".lc;
    }

    else {
      $*work-data<raku-class-name> =
        $*work-data<raku-package> ~ "::$*gnome-class";

      my Str $c = $*gnome-class;
      $c ~~ s/^ (.) /$0.lc()/;
      $c ~~ s:g/ (<[A..Z]>) /_$0.lc()/;
      $*work-data<sub-prefix> = [~] $*work-data<name-prefix>, '_', $c, '_';
    }
 }

  self.display-hash( $*work-data, :label<work-data>) if $*verbose;

  note "Prepare for work" if $*verbose;
}

#-------------------------------------------------------------------------------
submethod prepare-work-data ( SkimSource $source --> Hash ) {

#note "$?LINE $*gnome-package.Str(), @*map-search-list.gist()";

  my Hash $work-data;
  with $source {
    when Gtk3 {
      $work-data = %(
        :library<gtk3-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk3/'),
        :raku-package<Gnome::Gtk3>,
        :gnome-name($*gnome-class ?? "Gtk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gtk-3.0.gir'),
        :name-prefix<gtk>,
        :result-mods(API2MODS ~ 'gnome-gtk3/lib/Gnome/Gtk3/'),
        :result-tests(API2MODS ~ 'gnome-gtk3/t/'),
        :result-docs(API2MODS ~ 'gnome-gtk3/doc/'),
      );
    }

    when Gdk3 {
      $work-data = %(
        :library<gdk-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gdk3/'),
        :raku-package<Gnome::Gdk3>,
        :gnome-name($*gnome-class ?? "Gdk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gdk-3.0.gir'),
        :name-prefix<gdk>,
        :result-mods(API2MODS ~ 'gnome-gdk3/lib/Gnome/Gdk3/'),
        :result-tests(API2MODS ~ 'gnome-gdk3/t/'),
        :result-docs(API2MODS ~ 'gnome-gdk3/doc/'),
      );
    }

    when GdkPixbuf {
      $work-data = %(
        :library<gdk-pixbuf-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'GdkPixbuf/'),
        :raku-package<Gnome::GdkPixbuf>,
        :gir(GIRROOT ~ 'GdkPixbuf-2.0.gir'),
        :name-prefix<gdk_pixbuf>,
        :result-mods(API2MODS ~ 'gnome-gdkpixbuf/lib/Gnome/GdkPixbuf/'),
        :result-tests(API2MODS ~ 'gnome-gdkpixbuf/t/'),
        :result-docs(API2MODS ~ 'gnome-gdkpixbuf/doc/'),
      );

      if ?$*gnome-class {
        my Str $c = $*gnome-class;
        $c = $*gnome-class;
        $c ~~ s:g/ '-' (<[a..z]>) /$0.uc()/;
        $c .= tc;
        $work-data<gnome-name> = $c;

        $c ~~ s/ GdkPixbuf //;
        $work-data<raku-name> = ?$c ?? $c !! 'Pixbuf';
        $work-data<raku-class-name> = "Gnome::GdkPixbuf::$work-data<raku-name>";
        $c = $*gnome-class;
        $c ~~ s/^ Gdk /gdk/;
        $c ~~ s:g/ (<[A..Z]>) /_$0.lc()/;
        $work-data<sub-prefix> = $c ~ '_';
      }
    }

    when Gtk4 {
      $work-data = %(
        :library<gtk4-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk4/'),
        :raku-package<Gnome::Gtk4>,
        :gnome-name($*gnome-class ?? "Gtk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gtk-4.0.gir'),
        :name-prefix<gtk>,
        :result-mods(API2MODS ~ 'gnome-gtk4/lib/Gnome/Gtk4/'),
        :result-tests(API2MODS ~ 'gnome-gtk4/t/'),
        :result-docs(API2MODS ~ 'gnome-gtk4/doc/'),
      );
    }

    when Gdk4 {
      $work-data = %(
        :library<gtk4-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gdk4/'),
        :raku-package<Gnome::Gdk4>,
        :gnome-name($*gnome-class ?? "Gdk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gdk-4.0.gir'),
        :name-prefix<gdk>,
        :result-mods(API2MODS ~ 'gnome-gdk4/lib/Gnome/Gdk4/'),
        :result-tests(API2MODS ~ 'gnome-gdk4/t/'),
        :result-docs(API2MODS ~ 'gnome-gdk4/doc/'),
      );
    }

    when Gsk4 {
      $work-data = %(
        :library<gtk4-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gsk4/'),
        :raku-package<Gnome::Gsk4>,
        :gnome-name($*gnome-class ?? "Gsk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gsk-4.0.gir'),
        :name-prefix<gsk>,
        :result-mods(API2MODS ~ 'gnome-gsk4/lib/Gnome/Gsk4/'),
        :result-tests(API2MODS ~ 'gnome-gsk4/t/'),
        :result-docs(API2MODS ~ 'gnome-gsk4/doc/'),
      );
    }

    when Glib {
      $work-data = %(
        :library<glib-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Glib/'),
        :raku-package<Gnome::Glib>,
        :gnome-name($*gnome-class ?? "G$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'GLib-2.0.gir'),
        :name-prefix<g>,
        :result-mods(API2MODS ~ 'gnome-glib/lib/Gnome/Glib/'),
        :result-tests(API2MODS ~ 'gnome-glib/t/'),
        :result-docs(API2MODS ~ 'gnome-glib/doc/'),
      );
    }

    when Gio {
      $work-data = %(
        :library<gio-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gio/'),
        :raku-package<Gnome::Gio>,
        :gnome-name($*gnome-class ?? "G$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gio-2.0.gir'),
        :name-prefix<g>,
        :result-mods(API2MODS ~ 'gnome-gio/lib/Gnome/Gio/'),
        :result-tests(API2MODS ~ 'gnome-gio/t/'),
        :result-docs(API2MODS ~ 'gnome-gio/doc/'),
      );
    }

    when GObject {
      $work-data = %(
        :library<gobject-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'GObject/'),
        :raku-package<Gnome::GObject>,
        :gnome-name($*gnome-class ?? "G$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'GObject-2.0.gir'),
        :name-prefix<g>,
        :result-mods(API2MODS ~ 'gnome-gobject/lib/Gnome/GObject/'),
        :result-tests(API2MODS ~ 'gnome-gobject/t/'),
        :result-docs(API2MODS ~ 'gnome-gobject/doc/'),
      );
    }

    when Graphene {
      $work-data = %(
        :library<graphene-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Graphene/'),
        :raku-package<Gnome::Graphene>,
        :gnome-name($*gnome-class ?? "$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Graphene-1.0.gir'),
        :name-prefix(''),
        :result-mods(API2MODS ~ 'gnome-graphene/lib/Gnome/Graphene/'),
        :result-tests(API2MODS ~ 'gnome-graphene/t/'),
        :result-docs(API2MODS ~ 'gnome-graphene/doc/'),
      );
    }

    when Cairo {
      $work-data = %(
        :library<cairo-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Cairo/'),
        :raku-package<Gnome::Cairo>,
        :gnome-name($*gnome-class ?? "Cairo$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'cairo-1.0.gir'),
        :name-prefix<cairo>,
        :result-mods(API2MODS ~ 'gnome-cairo/lib/Gnome/Cairo/'),
        :result-tests(API2MODS ~ 'gnome-cairo/t/'),
        :result-docs(API2MODS ~ 'gnome-cairo/doc/'),
      );
    }

    when Atk {
      $work-data = %(
        :library<atk-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Atk/'),
        :raku-package<Gnome::Atk>,
        :gnome-name($*gnome-class ?? "Atk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Atk-1.0.gir'),
        :name-prefix<atk>,
        :result-mods(API2MODS ~ 'gnome-atk/lib/Gnome/Atk/'),
        :result-tests(API2MODS ~ 'gnome-atk/t/'),
        :result-docs(API2MODS ~ 'gnome-atk/doc/'),
      );
    }

    when Pango {
      $work-data = %(
        :library<pango-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Pango/'),
        :raku-package<Gnome::Pango>,
        :gnome-name($*gnome-class ?? "Pango$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Pango-1.0.gir'),
        :name-prefix<pango>,
        :result-mods(API2MODS ~ 'gnome-pango/lib/Gnome/Pango/'),
        :result-tests(API2MODS ~ 'gnome-pango/t/'),
        :result-docs(API2MODS ~ 'gnome-pango/doc/'),
      );
    }

#`{{
    when PangoCairo {
      $work-data = %(
        :library<pango-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'PangoCairo/'),
        :raku-package<Gnome::PangoCairo>,
        :gnome-name($*gnome-class ?? "PangoCairo$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'PangoCairo-1.0.gir'),
        :name-prefix(''),
        :result-mods(API2MODS ~ 'gnome-gtk3/lib/Gnome/Gtk3/'),
        :result-tests(API2MODS ~ 'gnome-gtk3/t/'),
        :result-docs(API2MODS ~ 'gnome-gtk3/doc/'),
      );
    }

    when GIRepo {
      $work-data = %(
        :library('libgirepository-1.0.so'),
        :gir-module-path(SKIMTOOLDATA ~ 'GIRepository/'),
        :raku-package<Gnome::GIRepository>,
        :gnome-name($*gnome-class ?? "GI$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'GIRepository-2.0.gir'),
        :name-prefix(''),
        :result-mods(API2MODS ~ 'gnome-gtk3/lib/Gnome/Gtk3/'),
        :result-tests(API2MODS ~ 'gnome-gtk3/t/'),
        :result-docs(API2MODS ~ 'gnome-gtk3/doc/'),
      );
    }
}}

    default {
#      $work-data = %();
      die 'No SkimSource defined for ' ~ $_ // '-';
    }
  }

  $work-data<raku-name> =
    $*gnome-class ?? "$*gnome-class" !! '' unless ?$work-data<raku-name>;

  $work-data<result-code-sections> = $work-data<result-docs> ~ 'code-sections/';

  mkdir $work-data<result-mods>, 0o700 unless $work-data<result-mods>.IO.e;
  mkdir $work-data<result-tests>, 0o700 unless $work-data<result-tests>.IO.e;
#  mkdir $work-data<result-docs>, 0o700 unless $work-data<result-docs>.IO.e;
  mkdir $work-data<result-code-sections>, 0o700
    unless $work-data<result-code-sections>.IO.e;

  $work-data
}

#-------------------------------------------------------------------------------
method drop-prefix (
  Str $prefixed-name is copy = '', Bool :$function = False,
  Bool :$constant = False
  --> Str
) {
  return '' unless ?$prefixed-name;

  # Drop type file prefix when only type specs are procesed
  $prefixed-name ~~ s/^ 'T-' //;
#note "$?LINE $prefixed-name";

  # Remove package prefix if there is any attached to the gnome class
  my Str $package-prefix;
  if $*gnome-package.Str ~~ any(<GObject Glib Gio>) {
    $package-prefix = 'G';
  }

  elsif $*gnome-package.Str ~~ any(<Gtk3 Gtk4 Gdk3 Gdk4 Gsk4>) {
    $package-prefix = S/ \d+ $// with $*gnome-package.Str;
  }

  elsif $*gnome-package.Str eq 'Pango' {
    $package-prefix = $*gnome-package.Str;
  }

  elsif $*gnome-package.Str ~~ 'Cairo' {
    $package-prefix = 'Cairo';
  }

  if $function {
    $package-prefix .= lc;
    $package-prefix ~= '_';
  }

  elsif $constant {
    $package-prefix ~= '_';
  }

  $prefixed-name ~~ s/^ $package-prefix //;

  $prefixed-name
}


#-------------------------------------------------------------------------------
method display-hash ( $info, :label($label-list) ) {
  my Str $label = $label-list ~~ List ?? $label-list.join(' ') !! $label-list;
  display-hash-init( $info, :$label);
}

#-------------------------------------------------------------------------------
sub display-hash-init ( $info, Str :$label ) {

  my Int $indent-level = 0;
  say '';

  if $info ~~ Array {
    display-hash-show( $indent-level, %($info.kv));
  }

  elsif ?$label {
    display-hash-show( $indent-level, %($label => $info));
  }

  else {
    display-hash-show( $indent-level, %(:gen-item($info)));
  }
}

#-------------------------------------------------------------------------------
sub display-hash-show ( Int $indent-level is copy, Hash $info ) {

  for $info.keys.sort -> $k {
#    say '' if $indent-level == 0;
    if $info{$k} ~~ Hash {
      say '  ' x $indent-level, $k, ':';
      $indent-level++;
      display-hash-show( $indent-level, $info{$k});
      $indent-level--;
    }

    elsif $info{$k} ~~ Array {
      display-hash-show( $indent-level, %($info.kv));
    }

    else {
      say '  ' x $indent-level, $k, ': ', $info{$k}.gist;
    }
  }
}

