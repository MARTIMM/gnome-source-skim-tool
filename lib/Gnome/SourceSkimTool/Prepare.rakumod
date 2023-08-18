
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc;


#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Prepare:auth<github:MARTIMM>;

has Int $!indent-level;

#-------------------------------------------------------------------------------
submethod BUILD ( Bool $gir = False ) {
  my Bool $load-maps = True;

  if $*generate-code {
    $*external-modules = %(
      :NativeCall(EMTRakudo), 'Gnome::N::NativeLib' => EMTNotInApi2,
      'Gnome::N::N-GObject' => EMTNotInApi2,
      'Gnome::N::GlibToRakuTypes' => EMTNotInApi2,
    );
  }

  elsif $*generate-test {
    $*external-modules = %(
      :Test(EMTRakudo),
      'Gnome::N::NativeLib' => EMTNotInApi2,
      'Gnome::N::N-GObject' => EMTNotInApi2,
      'Gnome::N::GlibToRakuTypes' => EMTNotInApi2,
      'Gnome::N::X' => EMTNotInApi2,
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
  $*gnome-class = self.drop-prefix($*gnome-class);
  $*work-data = self.prepare-work-data($*gnome-package);

#note "$?LINE $*gnome-package $*gnome-class";

  mkdir $*work-data<gir-module-path>, 0o700
    unless $*work-data<gir-module-path>.IO ~~ :e;

  # Add/modify some more global work data
  if ?$*gnome-class {

#TODO needed??
    $*work-data<raku-class-name> =
      $*work-data<raku-package> ~ "::$*gnome-class";

    my Str $c = $*gnome-class;
    $c ~~ s/^ (.) /$0.lc()/;
    $c ~~ s:g/ (<[A..Z]>) /_$0.lc()/;
    $*work-data<sub-prefix> = [~] $*work-data<name-prefix>, '_', $c, '_';

#TODO direct from $*gnome-class? Gir filenames must be changed!
# type prefix: none for class, R- for interfaces, N- for records and unions
    $*work-data<gir-class-file> =
      "$*work-data<gir-module-path>C-$*gnome-class.gir";
    $*work-data<gir-record-file> =
      "$*work-data<gir-module-path>R-$*gnome-class.gir";
    $*work-data<gir-union-file> =
      "$*work-data<gir-module-path>U-$*gnome-class.gir";
    $*work-data<gir-interface-file> =
      "$*work-data<gir-module-path>I-$*gnome-class.gir";
#    $*work-data<raku-module-types> = RAKUMODS ~ "T-$*gnome-class.rakumod";
#    $*work-data<raku-module-file> = RAKUMODS ~ "$*gnome-class.rakumod";
#    $*work-data<raku-module-doc-file> = RAKUMODS ~ "$*gnome-class.rakudoc";
#    $*work-data<raku-module-test-file> = RAKUMODS ~ "$*gnome-class.rakutest";
  }

  self.display-hash( $*work-data, :label<work-data>) if $*verbose;

  $*other-work-data = %();
  $*object-maps = %();

  note "Prepare for work" if $*verbose;

  # get workdata for other gnome packages
#  my Gnome::SourceSkimTool::Prepare $p .= new;

  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;

  # Because of the dependency chain it is possible to have less to load when
  # the classes are outside that chain
  # Version 3
  if $*gnome-package.Str ~~ / '3' $/ {
    $*other-work-data<Gtk> = self.prepare-work-data(Gtk3);
    $*other-work-data<Gdk> = self.prepare-work-data(Gdk3);
    $*other-work-data<GdkPixbuf> = self.prepare-work-data(GdkPixbuf);

    # Load map of pixbuf here because it is not in Gtk4
    $*object-maps<GdkPixbuf> =
      $s.load-map($*other-work-data<GdkPixbuf><gir-module-path>)
      unless $gir and !$*object-maps<GdkPixbuf>;
  }

  # Version 4
  elsif $*gnome-package.Str ~~ / '4' $/ {
    $*other-work-data<Gtk> = self.prepare-work-data(Gtk4);
    $*other-work-data<Gdk> = self.prepare-work-data(Gdk4);
    $*other-work-data<Gsk> = self.prepare-work-data(Gsk4);

    # Load map of gsk here because it is not in Gtk3
    $*object-maps<Gsk> = $s.load-map($*other-work-data<Gsk><gir-module-path>)
      unless $gir and !$*object-maps<Gsk>;
  }

  # If it is a high end module, we add these lower packages too.
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $*other-work-data<Atk> = self.prepare-work-data(Atk);
    $*other-work-data<Pango> = self.prepare-work-data(Pango);
    $*other-work-data<Cairo> = self.prepare-work-data(Cairo);

    $*object-maps<Gtk> = $s.load-map($*other-work-data<Gtk><gir-module-path>)
      unless $gir and !$*object-maps<Gtk>;
    $*object-maps<Gdk> = $s.load-map($*other-work-data<Gdk><gir-module-path>)
      unless $gir and !$*object-maps<Gdk>;

    $*object-maps<Atk> = $s.load-map($*other-work-data<Atk><gir-module-path>)
      unless $gir and !$*object-maps<Atk>;
    $*object-maps<Pango> =
      $s.load-map($*other-work-data<Pango><gir-module-path>)
      unless $gir and !$*object-maps<Pango>;
    $*object-maps<Cairo> =
      $s.load-map($*other-work-data<Cairo><gir-module-path>)
      unless $gir and !$*object-maps<Cairo>;
  }

  if $*gnome-package.Str ~~ / Pango || Cairo / {
    $*other-work-data<Pango> = self.prepare-work-data(Pango);
#    $*other-work-data<PangoCairo> = self.prepare-work-data(PangoCairo);
    $*other-work-data<Cairo> = self.prepare-work-data(Cairo);

    $*object-maps<Pango> =
      $s.load-map($*other-work-data<Pango><gir-module-path>);
#    $*object-maps<PangoCairo> =
#      $s.load-map($*other-work-data<PangoCairo><gir-module-path>);
    $*object-maps<Cairo> =
      $s.load-map($*other-work-data<Cairo><gir-module-path>);
  }

  # If it is not a high end module, we only need these
  $*other-work-data<Glib> = self.prepare-work-data(Glib);
  $*other-work-data<Gio> = self.prepare-work-data(Gio);
  $*other-work-data<GObject> = self.prepare-work-data(GObject);

  $*object-maps<Glib> = $s.load-map($*other-work-data<Glib><gir-module-path>)
    unless $gir and !$*object-maps<Glib>;
  $*object-maps<Gio> = $s.load-map($*other-work-data<Gio><gir-module-path>)
    unless $gir and !$*object-maps<Gio>;
  $*object-maps<GObject> =
    $s.load-map($*other-work-data<GObject><gir-module-path>)
    unless $gir and !$*object-maps<GObject>;
}

#-------------------------------------------------------------------------------
submethod prepare-work-data ( SkimSource $source --> Hash ) {

#note "$?LINE $*gnome-package.Str(), @*map-search-list.gist()";

  my Hash $work-data;
  with $source {
    when Gtk3 {
      $work-data = %(
#TODO take gtk3-lib, first update Gnome::N
        :library<gtk-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk3/'),
        :raku-package<Gnome::Gtk3>,
#TODO needed?
        :gnome-name($*gnome-class ?? "Gtk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gtk-3.0.gir'),
        :name-prefix<gtk>,
        :result-path(RAKUMODS ~ 'lib/Gnome/Gtk3/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Gdk3/'),
      );
    }

    when GdkPixbuf {
      $work-data = %(
        :library<gdk-pixbuf-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'GdkPixbuf/'),
        :raku-package<Gnome::Gdk3>,
        :gnome-name($*gnome-class ?? "GdkPixbuf$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'GdkPixbuf-2.0.gir'),
        :name-prefix<gdk_pixbuf>,
        :result-path(RAKUMODS ~ 'lib/Gnome/Gdk3/'),
      );
    }

    when GdkPixdata {
      $work-data = %(
        :library<gdk-pixbuf-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'GdkPixdata/'),
        :raku-package<Gnome::Gdk3>,
        :gnome-name($*gnome-class ?? "GdkPixdata$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'GdkPixdata-2.0.gir'),
        :name-prefix<gdk_pix>,
        :result-path(RAKUMODS ~ 'lib/Gnome/Gdk3/'),
      );
    }

    when Gtk4 {
      $work-data = %(
        :library<gtk4-lib()>,
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk4/'),
        :raku-package<Gnome::Gtk4>,
        :gnome-name($*gnome-class ?? "Gtk$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'Gtk-4.0.gir'),
        :name-prefix<gtk>,
        :result-path(RAKUMODS ~ 'lib/Gnome/Gtk4/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Gdk4/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Gsk4/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Glib/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Gio/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/GObject/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Cairo/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Atk/'),
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
        :result-path(RAKUMODS ~ 'lib/Gnome/Pango/'),
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
      );
    }

    when GIRepo {
      $work-data = %(
        :library<'libgirepository-1.0.so'>,
        :gir-module-path(SKIMTOOLDATA ~ 'GIRepository/'),
        :raku-package<Gnome::GIRepository>,
        :gnome-name($*gnome-class ?? "GI$*gnome-class" !! ''),
        :gir(GIRROOT ~ 'GIRepository-2.0.gir'),
        :name-prefix(''),
      );
    }
}}

    default {
#      $work-data = %();
      die 'No SkimSource defined for ' ~ $_ // '-';
    }
  }

  mkdir $work-data<result-path>, 0o700 unless $work-data<result-path>.IO ~~ :e;

  $work-data
}

#-------------------------------------------------------------------------------
method drop-prefix (
  Str $prefixed-name is copy = '', Bool :$function = False,
  Bool :$constant = False
  --> Str
) {
  return '' unless ?$prefixed-name;

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
multi method display-hash ( $info, Str :$label ) {

  $!indent-level = 0;
  say '';

  if $info ~~ Array {
    self!dhash(%($info.kv));
  }

  elsif ?$label {
    self!dhash(%($label => $info));
  }

  else {
    self!dhash(%(:gen-item($info)));
  }
}

#-------------------------------------------------------------------------------
multi method display-hash ( $info, List :label($label-list) ) {
  my Str $label = $label-list.join(' ');
  self.display-hash( $info, :$label);
}

#-------------------------------------------------------------------------------
method !dhash ( Hash $info ) {

  for $info.keys.sort -> $k {
#    say '' if $!indent-level == 0;
    if $info{$k} ~~ Hash {
      say '  ' x $!indent-level, $k, ':';
      $!indent-level++;
      self!dhash($info{$k});
      $!indent-level--;
    }

    elsif $info{$k} ~~ Array {
      self!dhash(%($info.kv));
    }

    else {
      say '  ' x $!indent-level, $k, ': ', $info{$k}.gist;
    }
  }
}














=finish

use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Prepare:auth<github:MARTIMM>;

has Int $!indent-level;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!indent-level = 0;
  my Str $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my Str $gir-module-path;

  with $*gnome-package {
    when Gtk3 {
      $*work-data = %(
        :library<&gtk-lib>,
        :source-dir([~] $source-root, 'gtk+-', VGtk3, '/gtk'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Gtk3'),
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk3/'),
        :raku-package<Gnome::Gtk3>,
        :sub-prefix<gtk_>,
      );
    }

    when Gdk3 {
      $*work-data = %(
        :library<&gdk-lib>,
        :source-dir([~] $source-root, 'gtk+-', VGtk3, '/gdk'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Gdk3'),
        :gir-module-path(SKIMTOOLDATA ~ 'Gdk3/'),
        :raku-package<Gnome::Gdk3>,
        :sub-prefix<gdk_>,
      );
    }

    when Gtk4 {
      $*work-data = %(
        :library<&gtk4-lib>,
        :source-dir([~] $source-root, 'gtk-', VGtk4, '/gtk'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Gtk4'),
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk4/'),
        :raku-package<Gnome::Gtk4>,
        :sub-prefix<gtk_>,
      );
    }

    when Gdk4 {
      $*work-data = %(
        :library<&gdk4-lib>,
        :source-dir([~] $source-root, 'gtk-', VGtk4, '/gdk'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Gdk4'),
        :gir-module-path(SKIMTOOLDATA ~ 'Gdk4/'),
        :raku-package<Gnome::Gdk4>,
        :sub-prefix<gdk_>,
      );
    }

    when Glib {
      $*work-data = %(
        :library<&glib-lib>,
        :source-dir([~] $source-root, 'glib-', VGlib, '/glib'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Glib'),
        :gir-module-path(SKIMTOOLDATA ~ 'Glib/'),
        :raku-package<Gnome::Glib>,
        :sub-prefix<g_>,
      );
    }

    when Gio {
      $*work-data = %(
        :library<&gio-lib>,
        :source-dir([~] $source-root, 'glib-', VGlib, '/gio'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Gio'),
        :gir-module-path(SKIMTOOLDATA ~ 'Gio/'),
        :raku-package<Gnome::Gio>,
        :sub-prefix<g_>,
      );
    }

    when GObject {
      $*work-data = %(
        :library<&gobject-lib>,
        :source-dir([~] $source-root, 'glib-', VGlib, '/gobject'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/GObject'),
        :gir-module-path(SKIMTOOLDATA ~ 'GObject/'),
        :raku-package<Gnome::GObject>,
        :sub-prefix<g_>,
      );
    }

    when Cairo {
      $*work-data = %(
        :library<&cairo-lib>,
        :source-dir([~] $source-root, 'cairo-', VCairo, '/src'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Cairo'),
        :gir-module-path(SKIMTOOLDATA ~ 'Cairo/'),
        :raku-package<Gnome::Cairo>,
        :sub-prefix<cairo_>,
      );
    }

    when Pango {
      $*work-data = %(
        :library<&pango-lib>,
        :source-dir([~] $source-root, 'pango-', VPango, '/pango'),
        :gtkdoc-dir(SKIMTOOLROOT ~ 'Gtkdoc/Pango'),
        :gir-module-path(SKIMTOOLDATA ~ 'Pango/'),
        :raku-package<Gnome::Pango>,
        :sub-prefix<pango_>,
      );
    }

    default {
      die 'No SkimSource defined';
    }
  }

  # create directory
  $*work-data<gir-module-path> = $*work-data<gir-module-path>;
  mkdir $*work-data<gir-module-path>, 0o700
    if $*work-data<gir-module-path>.IO !~~ :e;

  # Check existence of directories
  mkdir $*work-data<gtkdoc-dir>, 0o700
    if ?$*gnome-package and $*work-data<gtkdoc-dir>.IO !~~ :e;


  $*work-data<new-raku-modules> = 'xt/NewRakuModules/';
  mkdir $*work-data<new-raku-modules>, 0o700
    if ?$*gnome-package and $*work-data<new-raku-modules>.IO !~~ :e;

  # Add/modify some more global work data
  if ?$*gnome-class {
    my Str $gclass = $*gnome-class // '';
    $gclass ~~ s:g/ (\w) (<[A..Z]>) /{$0}_{$1}/;
    $*work-data<sub-prefix> = ?$*gnome-class ?? $gclass.lc() !! '';
    $*work-data<raku-sub-prefix> = $*work-data<sub-prefix>;
    $*work-data<raku-sub-prefix> ~~ s:g/ '_' /-/;

    $*work-data<raku-class-name> = self.raku-class-name;

    # add filename to string
    $*work-data<gir-module-path> ~= "$*gnome-class.yaml";
  }

  self.display-hash( $*work-data, :label<work-data>);
}

#-------------------------------------------------------------------------------
method raku-class-name ( Str :$gnome-name, SkimSource :$package --> Str ) {

  return '' unless ?($gnome-name // $*gnome-class);

  my Str $raku-class-name = $gnome-name // $*gnome-class;

  with $package // $*gnome-package {
    when Gtk3 {
      $raku-class-name ~~ s/^ Gtk //;
      $raku-class-name = 'Gnome::Gtk3::' ~ $raku-class-name;
    }

    when Gdk3 {
      $raku-class-name ~~ s/^ Gdk //;
      $raku-class-name = 'Gnome::Gdk3::' ~ $raku-class-name;
    }

    when Gtk4 {
      $raku-class-name ~~ s/^ Gtk //;
      $raku-class-name = 'Gnome::Gtk4::' ~ $raku-class-name;
    }

    when Gdk4 {
      $raku-class-name ~~ s/^ Gdk //;
      $raku-class-name = 'Gnome::Gdk4::' ~ $raku-class-name;
    }

    when Glib {
      $raku-class-name ~~ s/^ G //;
      $raku-class-name = 'Gnome::Glib::' ~ $raku-class-name;
    }

    when Gio {
      $raku-class-name ~~ s/^ G //;
      $raku-class-name = 'Gnome::Gio::' ~ $raku-class-name;
    }

    when GObject {
      $raku-class-name ~~ s/^ G //;
      $raku-class-name = 'Gnome::GObject::' ~ $raku-class-name;
    }

    when Cairo {
      $raku-class-name ~~ s/^ Cairo //;
      $raku-class-name = 'Gnome::Cairo::' ~ $raku-class-name;
    }

    when Pango {
      $raku-class-name ~~ s/^ Pango //;
      $raku-class-name = 'Gnome::Pango::' ~ $raku-class-name;
    }

    default {
      die 'No SkimSource defined';
    }
  }
}

#-------------------------------------------------------------------------------
method get-gtkdoc-file ( Str $postfix, Bool :$txt = True --> Str ) {
  my Str $gtkdoc-fname = '';

  with $*gnome-package {
    when Gtk3 {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gtk3/gtk3$postfix";
    }
    when Gdk3 {
      $gtkdoc-fname= SKIMTOOLROOT ~ "Gtkdoc/Gdk3/gdk3$postfix";
    }
    when Gtk4 {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gtk4/gtk4$postfix";
    }
    when Gdk4 {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gdk4/gdk4$postfix";
    }
    when Glib {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Glib/glib$postfix";
    }
    when Gio {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gio/gio$postfix";
    }
    when GObject {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/GObject/gobject$postfix";
    }
    when Cairo {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Cairo/cairo$postfix";
    }
    when Pango {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Pango/pango$postfix";
    }
#    when  {
#      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/…/…$postfix";
#    }
  }

  $gtkdoc-fname ~= '.txt' if $txt;

  note "Gtk doc file: $gtkdoc-fname" if $*verbose;

  $gtkdoc-fname
}

#-------------------------------------------------------------------------------
method generate-gtkdoc ( ) {

  my Str $gd = $*work-data<gtkdoc-dir>;   #self.set-gtkdoc-dir;
  my Str $mod-name = $*gnome-package.key.lc;

  my $curr-dir = $*CWD;
  chdir $gd;

  # Generate a few files using gtkdoc-scan. See also gtkdoc.md.
  my Str $out1 = "--output-dir .";
  my Str $src = '--source-dir ' ~ $*work-data<source-dir>; #self.set-source-dir;
  my Str $mod = "--module $mod-name";
  note "\nRun: /usr/bin/gtkdoc-scan $out1 $src $mod" if $*verbose;
  shell "/usr/bin/gtkdoc-scan $out1 $src $mod";

  # The next step is using gtkdoc-scangobj which wil generate a program. There
  # are however errors when looking at the gtk3 sources. We need to filter
  # the types list to get rid of those
  with $*gnome-package {
    when Gtk3 {
      note "Filter types from $gd/{$mod-name}.types" if $*verbose;
      my @list = ();
      # read the types list
      for "$gd/{$mod-name}.types".IO.slurp.lines -> $l {
        # Filter out following functions from types list.
        next if $l ~~ any(<
          gtk_action_muxer_get_type gtk_action_helper_get_type
          gtk_action_observable_get_type gtk_action_observer_get_type
          gtk_application_accels_get_type gtk_application_impl_dbus_get_type
          gtk_application_impl_get_type gtk_application_impl_quartz_get_type
          gtk_application_impl_wayland_get_type
          gtk_application_impl_x11_get_type gtk_box_gadget_get_type
          gtk_builtin_icon_get_type gtk_color_editor_get_type
          gtk_color_picker_kwin_get_type gtk_color_picker_portal_get_type
          gtk_color_picker_shell_get_type gtk_color_plane_get_type
          gtk_color_scale_get_type gtk_color_swatch_get_type
          gtk_css_animated_style_get_type gtk_css_custom_gadget_get_type
          gtk_css_gadget_get_type gtk_css_image_builtin_get_type
          gtk_css_node_get_type gtk_css_path_node_get_type
          gtk_css_static_style_get_type gtk_css_style_get_type
          gtk_css_transient_node_get_type gtk_css_widget_node_get_type
          gtk_emoji_chooser_get_type gtk_emoji_completion_get_type
          gtk_graph_data_get_type gtk_icon_get_type
          gtk_icon_helper_get_type gtk_inspector_action_editor_get_type
          gtk_inspector_actions_get_type gtk_inspector_css_editor_get_type
          gtk_inspector_css_node_tree_get_type
          gtk_inspector_data_list_get_type gtk_inspector_general_get_type
          gtk_inspector_gestures_get_type gtk_inspector_magnifier_get_type
          gtk_inspector_menu_get_type gtk_inspector_misc_info_get_type
          gtk_inspector_object_hierarchy_get_type
          gtk_inspector_object_tree_get_type gtk_inspector_prop_editor_get_type
          gtk_inspector_prop_list_get_type gtk_inspector_resource_list_get_type
          gtk_inspector_selector_get_type gtk_inspector_signals_list_get_type
          gtk_inspector_size_groups_get_type gtk_inspector_statistics_get_type
          gtk_inspector_strv_editor_get_type gtk_inspector_visual_get_type
          gtk_inspector_window_get_type gtk_menu_section_box_get_type
          gtk_menu_tracker_item_get_type gtk_menu_tracker_item_role_get_type
          gtk_model_menu_item_get_type gtk_places_view_get_type
          gtk_places_view_row_get_type gtk_query_get_type
          gtk_search_engine_tracker3_get_type gtk_sidebar_row_get_type
          gtk_stack_combo_get_type gtk_tooltip_window_get_type
          gtk_tree_model_css_node_get_type gtk_win32_embed_widget_get_type
        >);

        @list.push: $l;
      }

      # Write filtered list
      "$gd/{$mod-name}.types".IO.spurt(@list.join("\n"));
    }

    when Gtk4 {
      note "Filter types from $gd/{$mod-name}.types" if $*verbose;
      my @list = ();
      # read the types list
      for "$gd/{$mod-name}.types".IO.slurp.lines -> $l {
        # Filter out following functions from types list.
        next if $l ~~ any(<action_holder_get_type graph_data_get_type
          graph_renderer_get_type gsk_pango_renderer_get_type
          gtk_accessible_range_get_type gtk_accessible_value_get_type
          gtk_action_helper_get_type gtk_action_muxer_get_type
          gtk_action_observable_get_type gtk_action_observer_get_type
          gtk_alert_dialog_get_type gtk_application_accels_get_type
          gtk_application_impl_dbus_get_type gtk_application_impl_get_type
          gtk_application_impl_quartz_get_type
          gtk_application_impl_wayland_get_type
          gtk_application_impl_x11_get_type gtk_at_spi_cache_get_type
          gtk_at_spi_context_get_type gtk_at_spi_root_get_type
          gtk_baseline_overlay_get_type gtk_builtin_icon_get_type
          gtk_button_role_get_type gtk_color_dialog_button_get_type
          gtk_color_dialog_get_type gtk_color_editor_get_type
          gtk_color_picker_get_type gtk_color_picker_kwin_get_type
          gtk_color_picker_portal_get_type gtk_color_picker_shell_get_type
          gtk_color_picker_win32_get_type gtk_color_plane_get_type
          gtk_color_scale_get_type gtk_color_swatch_get_type
          gtk_column_list_item_factory_get_type gtk_column_view_cell_get_type
          gtk_column_view_layout_get_type gtk_column_view_sorter_get_type
          gtk_column_view_title_get_type gtk_constraint_solver_get_type
          gtk_css_animated_style_get_type gtk_css_dynamic_get_type
          gtk_css_image_conic_get_type gtk_css_image_cross_fade_get_type
          gtk_css_image_invalid_get_type gtk_css_image_paintable_get_type
          gtk_css_node_get_type gtk_css_static_style_get_type
          gtk_css_style_get_type gtk_css_transient_node_get_type
          gtk_css_widget_node_get_type gtk_data_viewer_get_type
          gtk_emoji_completion_get_type gtk_file_chooser_cell_get_type
          gtk_file_chooser_error_stack_get_type gtk_file_dialog_get_type
          gtk_file_launcher_get_type gtk_file_system_model_get_type
          gtk_focus_overlay_get_type
          gtk_font_dialog_button_get_type
          gtk_font_dialog_get_type
          gtk_fps_overlay_get_type
          gtk_gizmo_get_type
          gtk_highlight_overlay_get_type
          gtk_icon_helper_get_type
          gtk_im_context_broadway_get_type
          gtk_im_context_ime_get_type
          gtk_im_context_quartz_get_type
          gtk_im_context_wayland_get_type
          gtk_inscription_get_type
          gtk_inspector_a11y_get_type
          gtk_inspector_action_editor_get_type
          gtk_inspector_actions_get_type
          gtk_inspector_clipboard_get_type
          gtk_inspector_controllers_get_type
          gtk_inspector_css_editor_get_type
          gtk_inspector_css_node_tree_get_type
          gtk_inspector_event_recording_get_type
          gtk_inspector_general_get_type
          gtk_inspector_list_data_get_type
          gtk_inspector_logs_get_type
          gtk_inspector_magnifier_get_type
          gtk_inspector_measure_graph_get_type
          gtk_inspector_menu_get_type
          gtk_inspector_misc_info_get_type
          gtk_inspector_object_tree_get_type
          gtk_inspector_overlay_get_type
          gtk_inspector_prop_editor_get_type
          gtk_inspector_prop_list_get_type
          gtk_inspector_recorder_get_type
          gtk_inspector_recorder_row_get_type
          gtk_inspector_recording_get_type
          gtk_inspector_render_recording_get_type
          gtk_inspector_resource_list_get_type
          gtk_inspector_shortcuts_get_type
          gtk_inspector_size_groups_get_type
          gtk_inspector_start_recording_get_type
          gtk_inspector_statistics_get_type
          gtk_inspector_strv_editor_get_type
          gtk_inspector_tree_data_get_type
          gtk_inspector_type_popover_get_type
          gtk_inspector_variant_editor_get_type
          gtk_inspector_visual_get_type
          gtk_inspector_window_get_type
          gtk_joined_menu_get_type
          gtk_layout_overlay_get_type
          gtk_list_item_manager_get_type
          gtk_list_item_widget_get_type
          gtk_list_list_model_get_type
          gtk_magnifier_get_type
          gtk_menu_section_box_get_type
          gtk_menu_tracker_item_get_type
          gtk_menu_tracker_item_role_get_type
          gtk_model_button_get_type
          gtk_no_media_file_get_type
          gtk_paned_handle_get_type
          gtk_places_sidebar_get_type
          gtk_places_view_get_type
          gtk_places_view_row_get_type
          gtk_popover_content_get_type
          gtk_property_lookup_list_model_get_type
          gtk_query_get_type
          gtk_render_node_paintable_get_type
          gtk_scaler_get_type
          gtk_search_engine_tracker3_get_type
          gtk_sidebar_row_get_type
          gtk_test_at_context_get_type
          gtk_text_handle_get_type
          gtk_text_history_get_type
          gtk_text_layout_get_type
          gtk_text_view_child_get_type
          gtk_tooltip_window_get_type
          gtk_tree_popover_get_type
          gtk_updates_overlay_get_type
          gtk_uri_launcher_get_type
          prop_holder_get_type
          resource_holder_get_type

        >);

        @list.push: $l;
      }

      # Write filtered list
      "$gd/{$mod-name}.types".IO.spurt(@list.join("\n"));
    }

    when Gdk3 {
      note "Filter types from $gd/{$mod-name}.types" if $*verbose;
      my @list = ();
      # read the types list
      for "$gd/{$mod-name}.types".IO.slurp.lines -> $l {
        # Filter out following functions from types list.
        next if $l ~~ any(<gdk_broadway_device_get_type gdk_broadway_device_manager_get_type
          gdk_broadway_screen_get_type gdk_device_manager_win32_get_type
          gdk_device_virtual_get_type gdk_device_win32_get_type
          gdk_device_winpointer_get_type gdk_device_wintab_get_type
          gdk_frame_clock_idle_get_type gdk_offscreen_window_get_type
          gdk_quartz_cursor_get_type gdk_quartz_device_core_get_type
          gdk_quartz_device_manager_core_get_type 
          gdk_quartz_display_get_type gdk_quartz_display_manager_get_type
          gdk_quartz_drag_context_get_type gdk_quartz_gl_context_get_type
          gdk_quartz_keymap_get_type gdk_quartz_monitor_get_type
          gdk_quartz_screen_get_type gdk_quartz_visual_get_type
          gdk_quartz_window_get_type gdk_seat_default_get_type
          gdk_wayland_seat_get_type gdk_win32_cursor_get_type
          gdk_win32_display_get_type gdk_win32_display_manager_get_type
          gdk_win32_drag_context_get_type gdk_win32_gl_context_get_type
          gdk_win32_keymap_get_type gdk_win32_monitor_get_type
          gdk_win32_screen_get_type gdk_win32_selection_get_type
          gdk_win32_window_get_type gdk_window_impl_broadway_get_type
          gdk_window_impl_get_type gdk_window_impl_x11_get_type
        >);

        @list.push: $l;
      }

      # Write filtered list
      "$gd/{$mod-name}.types".IO.spurt(@list.join("\n"));
    }

    when Glib {
      # Create a non-generated file
      "$gd/{$mod-name}.types".IO.spurt('');
      
      # Copy some other files. They were created when that environment was 
      # compiled or were available in the archive. These files help to
      # remedy some errors found by the gtkdoc-mkdb program.
      my Str $gldir = [~] SKIMTOOLROOT, 'Gnome/glib-', VGlib,
                          "/docs/reference/glib";
      "$gldir/{$mod-name}-docs.xml".IO.copy("$gd/{$mod-name}-docs.xml");
      "$gldir/{$mod-name}-overrides.txt".IO.copy(
        "$gd/{$mod-name}-overrides.txt"
      );
      "$gldir/{$mod-name}-sections.txt".IO.copy("$gd/{$mod-name}-sections.txt");
    }

    when GObject {
      note "Filter types from $gd/{$mod-name}.types" if $*verbose;
      my @list = ();
      # read the types list
      for "$gd/{$mod-name}.types".IO.slurp.lines -> $l {
        # Filter out following functions from types list.
        next if $l ~~ any(<test_module_get_type>);

        @list.push: $l;
      }

      # Write filtered list
      "$gd/{$mod-name}.types".IO.spurt(@list.join("\n"));
    }
 
    when Gio {
      note "Filter types from $gd/{$mod-name}.types" if $*verbose;
      my @list = ();
      # read the types list
      for "$gd/{$mod-name}.types".IO.slurp.lines -> $l {
        # Filter out following functions from types list.
        next if $l ~~ any(<g_delayed_settings_backend_get_type
          g_inotify_file_monitor_get_type g_keyfile_settings_backend_get_type
          g_memory_monitor_dbus_get_type g_memory_monitor_portal_get_type
          g_memory_settings_backend_get_type g_network_monitor_portal_get_type
          g_nextstep_settings_backend_get_type g_notification_backend_get_type
          g_notification_server_get_type g_null_settings_backend_get_type
          g_osx_app_info_get_type g_power_profile_monitor_dbus_get_type
          g_power_profile_monitor_portal_get_type
          g_proxy_resolver_portal_get_type g_registry_backend_get_type
          g_tls_console_interaction_get_type g_win32_app_info_get_type
          g_win32_file_monitor_get_type g_win32_input_stream_get_type
          g_win32_output_stream_get_type g_win32_registry_key_get_type
          g_win32_registry_subkey_iter_get_type
          g_win32_registry_value_iter_get_type mock_resolver_get_type
          test_io_stream_get_type
        >);

        @list.push: $l;
      }

      # Write filtered list
      "$gd/{$mod-name}.types".IO.spurt(@list.join("\n"));
    }
  }

  my $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my $glib0 = [~] $source-root, 'glib-', VGlib;
  my $gbuild = [~] $glib0, '/build';
  my $glib = [~] $glib0, '/glib';
  my $gobject = [~] $glib0, '/gobject';

  my $other-lib = '';
  with $*gnome-package {
    when Gtk3 { $other-lib = '-lgtk-3'; }
    when Gdk3 { $other-lib = '-lgdk-3'; }
    when Gtk4 { $other-lib = '-lgtk-4'; }
    #when Gdk4 { $other-lib = ''; }

    when Cairo { $other-lib = '-lcairo'; }
    when Pango { $other-lib = '-lpango'; }
  }

  my Str $cf = '-fPIC';
  my Str $lf = '-Wl,--no-undefined -Wl,-z,relro -Wl,--as-needed -Wl,-z,now';

  my $command = "/usr/bin/gtkdoc-scangobj $mod --verbose --cflags '$cf -I$glib -I$gobject -I$glib0 -I$gbuild/glib -I$gbuild' --ldflags '$lf -L$gbuild/object -L$gbuild/glib -L$gbuild/gio -lgobject-2.0 -lglib-2.0 -lgio-2.0 -L/usr/lib64 $other-lib' >compile1.log";

  note "\nRun: $command" if $*verbose;
  shell $command;

  my Str $out2 = "--output-dir $gd/docs";
  note "\nRun: /usr/bin/gtkdoc-mkdb $out2 $src $mod --xml-mode" if $*verbose;
  shell "/usr/bin/gtkdoc-mkdb $out2 $src $mod --xml-mode >compile2.log";
  chdir $curr-dir;
}

#-------------------------------------------------------------------------------
method display-hash ( $info, Str :$label ) {
  return unless $*verbose;

  say '';

  if $info ~~ Array {
    self!dhash(%($info.kv));
  }

  elsif ?$label {
    self!dhash(%($label => $info));
  }

  else {
    self!dhash(%(:gen-item($info)));
  }
}

#-------------------------------------------------------------------------------
method !dhash ( Hash $info ) {
  return unless $*verbose;

  for $info.keys.sort -> $k {
#    say '' if $!indent-level == 0;
    if $info{$k} ~~ Hash {
      say '  ' x $!indent-level, $k, ':';
      $!indent-level++;
      self!dhash($info{$k});
      $!indent-level--;
    }

    elsif $info{$k} ~~ Array {
      self!dhash(%($info.kv));
    }

    else {
      say '  ' x $!indent-level, $k, ': ', $info{$k}.gist;
    }
  }
}







=finish

#`{{
#-------------------------------------------------------------------------------
method set-source-dir ( --> Str ) {
  my Str $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my Str $source-dir = '';

  with $*gnome-package {
    when Gtk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gtk'; }
    when Gdk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gdk'; }
    when Gtk4 { $source-dir = [~] $source-root, 'gtk-', VGtk4, '/gtk'; }
    when Gdk4 { $source-dir = [~] $source-root, 'gtk-', VGtk4, '/gdk'; }
    when Glib { $source-dir = [~] $source-root, 'glib', VGlib, 'glib'; }
    when Gio { $source-dir = [~] $source-root, 'glib', VGlib, 'gio'; }
    when GObject { $source-dir = [~] $source-root, 'glib', VGlib, 'gobject'; }
    when Cairo { $source-dir = [~] $source-root, 'cairo', VCairo, 'src'; }
    when Pango { $source-dir = [~] $source-root, 'pango', VPango, 'pango'; }
    #when  { $source-dir = [~] $source-root, '', , ''; }
  }

  if $*verbose {
    note "Config root: ", SKIMTOOLROOT;
    note "Source directory: $source-dir";
  }

  $source-dir
}

#-------------------------------------------------------------------------------
method set-gtkdoc-dir ( --> Str ) {
  my Str $dir = '';

  with $*gnome-package {
    when Gtk3 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gtk3'; }
    when Gdk3 { $dir= SKIMTOOLROOT ~ 'Gtkdoc/Gdk3'; }
    when Gtk4 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gtk4'; }
    when Gdk4 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gdk4'; }
    when Glib { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Glib'; }
    when Gio { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gio'; }
    when GObject { $dir = SKIMTOOLROOT ~ 'Gtkdoc/GObject'; }
    when Cairo { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Cairo'; }
    when Pango { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Pango'; }
    #when  { $dir = SKIMTOOLROOT ~ 'Gtkdoc/'; }
  }

  mkdir $dir, 0o700 unless $dir.IO.e;

  note "Gtk doc directory: $dir" if $*verbose;

  $dir
}
}}

#`{{
#-------------------------------------------------------------------------------
method get-raku-class-name (
  Str $gnome-class is copy, Str $class-type --> Str
) {
  my Str $class-name = '';

  with $gnome-class {
    when m/^ Gtk / and $*gnome-package ~~ Gtk3 {
      $gnome-class ~~ s/^ Gtk //;
      $class-name = 'Gnome::Gtk3::' ~ $gnome-class;
    }
    when m/^ Gdk / and $*gnome-package ~~ Gdk3 {
      $gnome-class ~~ s/^ Gdk //;
      $class-name = 'Gnome::Gdk3::' ~ $gnome-class;
    }
    when m/^ Gtk / and $*gnome-package ~~ Gtk4 {
      $gnome-class ~~ s/^ Gtk //;
      $class-name = 'Gnome::Gtk4::' ~ $gnome-class;
    }
    when m/^ Gdk / and $*gnome-package ~~ Gdk4 {
      $gnome-class ~~ s/^ Gdk //;
      $class-name = 'Gnome::Gdk4::' ~ $gnome-class;
    }
    when m/^ G <[A..Z>]> / {
      $gnome-class ~~ s/^ G //;

      # role in glib most probably a Gio class
      if $class-type eq 'role' {
        $class-name = 'Gnome::Gio::' ~ $gnome-class;
      }
#TODO what is it when it isn't a role? Gio, GObject or Glib???
# must find out by generating GtkDoc for those libs first
      else {
        $class-name = 'Gnome::Glib::' ~ $gnome-class;
      }
    }
#`{{
    when m/^ G <[A..Z>]> / {
      $gnome-class ~~ s/^ G //;
      $class-name = 'Gnome::Gio::' ~ $gnome-class;
    }
    when m/^ G <[A..Z>]> / {
      $gnome-class ~~ s/^ G //;
      $class-name = 'Gnome::GObject::' ~ $gnome-class;
    }
}}
    when m/^ Cairo / {
      $gnome-class ~~ s/^ Cairo //;
      $class-name = 'Gnome::Cairo::' ~ $gnome-class;
    }
    when m/^ Pango / {
      $gnome-class ~~ s/^ Pango //;
      $class-name = 'Gnome::Pango::' ~ $gnome-class;
    }
#    when m/^ … / and … {
#      $gnome-class ~~ s/^ G //;
#      $class-name = 'Gnome::…::' ~ $gnome-class;
#    }
  }

  note "Gtk raku class name: $class-name" if $*verbose;

  $class-name
}
}}

#`{{
#-------------------------------------------------------------------------------
method set-skim-result-file ( --> Str ) {
  my Str $dir = '';
  my Str $file = $*sub-prefix;
  $file .= tc;
  $file ~~ s:g/ '_' (\w) /$0.tc()/;

  with $*gnome-package {
    when Gtk3 { $dir = SKIMTOOLDATA ~ 'Gtk3/'; }
    when Gdk3 { $dir= SKIMTOOLDATA ~ 'Gdk3/'; }
    when Gtk4 { $dir = SKIMTOOLDATA ~ 'Gtk4/'; }
    when Gdk4 { $dir = SKIMTOOLDATA ~ 'Gdk4/'; }
    when Glib { $dir = SKIMTOOLDATA ~ 'Glib/'; }
    when Gio { $dir = SKIMTOOLDATA ~ 'Gio/'; }
    when GObject { $dir = SKIMTOOLDATA ~ 'GObject/'; }
    when Cairo { $dir = SKIMTOOLDATA ~ 'Cairo/'; }
    when Pango { $dir = SKIMTOOLDATA ~ 'Pango/'; }
#    when  { $dir = SKIMTOOLDATA ~ ''; }
  }

  mkdir $dir, 0o700 unless $dir.IO.e;

  note "Skim result file: $dir$file.yaml" if $*verbose;

  "$dir$file.yaml"
}
}}

sources from https://www.gtk.org/docs/installations/linux/

Make gtk and gdk libs
> ./configure
> make


Make glib, gio and gobject libs
Beyond Linux® From Scratch;
https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html

download glib-2.74.5.tar.xz and glib-2.74.5-skip_warnings-1.patch

> tar xvf glib-2.74.5.tar.xz
> cd glib-2.74.5
> patch -Np1 -i ../glib-2.74.5-skip_warnings-1.patch
> mkdir build
> cd build
> meson --prefix=/usr --buildtype=release -Dman=true ..
> ninja
> setenv LC_ALL C
> ninja test




make docs with GtkDoc tools
in Gnome source code at /home/marcel/Software/Packages/Sources/Gnome do
following command to get glibconfig.h
> autoconf --output=glib/glibconfig.h glib/glibconfig.h.in

V3
in GtkDoc/Gtk3
> gtkdoc-scan --module gtk3 --output-dir . --source-dir ../../Gnome/gtk+-3.24.24/gtk
> gtkdoc-scangobj --module gtk3 --verbose --cflags '\-fPIC -I../../Gnome/glib-2.74.5/glib -I../../Gnome/glib-2.74.5/gobject -I../../Gnome/glib-2.74.5 -I../../Gnome/glib-2.74.5/build/glib -I../../Gnome/glib-2.74.5/build/' --ldflags '\-Wl,--no-undefined -Wl,-z,relro -Wl,--as-needed -Wl,-z,now -L../../Gnome/glib-2.74.5/build/gobject -L../../Gnome/glib-2.74.5/build/glib -L/usr/lib64 -lgobject-2.0 -lglib-2.0 -lgtk-3 -lgobject-2.0 -lglib-2.0 -lgtk-3'

not found refs

gtk_action_muxer_get_type
gtk_action_observable_get_type
gtk_action_observer_get_type
gtk_application_accels_get_type
gtk_application_impl_dbus_get_type
gtk_application_impl_get_type
gtk_application_impl_quartz_get_type
gtk_application_impl_wayland_get_type
gtk_application_impl_x11_get_type
gtk_box_gadget_get_type
gtk_builtin_icon_get_type
gtk_color_editor_get_type
gtk_color_picker_kwin_get_type
gtk_color_picker_portal_get_type
gtk_color_picker_shell_get_type
gtk_color_plane_get_type
gtk_color_scale_get_type
gtk_color_swatch_get_type
gtk_css_animated_style_get_type
gtk_css_custom_gadget_get_type
gtk_css_gadget_get_type
gtk_css_image_builtin_get_type
gtk_css_node_get_type
gtk_css_path_node_get_type
gtk_css_static_style_get_type
gtk_css_style_get_type
gtk_css_transient_node_get_type
gtk_css_widget_node_get_type
gtk_emoji_chooser_get_type
gtk_emoji_completion_get_type
gtk_graph_data_get_type
gtk_icon_get_type
gtk_icon_helper_get_type
gtk_inspector_action_editor_get_type
gtk_inspector_actions_get_type
gtk_inspector_css_editor_get_type
gtk_inspector_css_node_tree_get_type
gtk_inspector_data_list_get_type
gtk_inspector_general_get_type
gtk_inspector_gestures_get_type
gtk_inspector_magnifier_get_type
gtk_inspector_menu_get_type
gtk_inspector_misc_info_get_type
gtk_inspector_object_hierarchy_get_type
gtk_inspector_object_tree_get_type
gtk_inspector_prop_editor_get_type
gtk_inspector_prop_list_get_type
gtk_inspector_resource_list_get_type
gtk_inspector_selector_get_type
gtk_inspector_signals_list_get_type
gtk_inspector_size_groups_get_type
gtk_inspector_statistics_get_type
gtk_inspector_strv_editor_get_type
gtk_inspector_visual_get_type
gtk_inspector_window_get_type
gtk_menu_section_box_get_type
gtk_menu_tracker_item_get_type
gtk_menu_tracker_item_role_get_type
gtk_model_menu_item_get_type
gtk_places_view_get_type
gtk_places_view_row_get_type
gtk_query_get_type
gtk_search_engine_tracker3_get_type
gtk_search_engine_tracker3_get_type
gtk_sidebar_row_get_type
gtk_stack_combo_get_type
gtk_tooltip_window_get_type
gtk_tree_model_css_node_get_type
gtk_win32_embed_widget_get_type


> gtkdoc-mkdb --module gtk3 --source-dir ../../Gnome/gtk+-3.24.24/gtk --output-dir docs --xml-mode

V4
> gtkdoc-scan --output-dir d --source-dir Gnome/gtk-4.9.3/gtk --module gtk4
> gtkdoc-scangobj --module gtk4 --verbose --cflags '\-I../../Gnome/glib-2.74.5/glib -I../../Gnome/glib-2.74.5/gobject'
> gtkdoc-mkdb --module gtk3 --source-dir ../Gnome/gtk+-3.24.24/gtk --output-dir e --xml-mode
