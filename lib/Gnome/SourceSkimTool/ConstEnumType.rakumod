
#-------------------------------------------------------------------------------
#unit class Gnome::SourceSkimTool::ConstEnumType:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
constant SKIMTOOLROOT is export =
  $*HOME ~ '/.config/io.github.martimm.source-skim-tool/';
mkdir SKIMTOOLROOT, 0o700 unless SKIMTOOLROOT.IO ~~ :e;

constant SKIMTOOLDATA is export = SKIMTOOLROOT ~ 'SkimToolData/';
mkdir SKIMTOOLDATA, 0o700 unless SKIMTOOLDATA.IO ~~ :e;

constant RAKUMODS is export = 'xt/NewRakuModules/';
mkdir RAKUMODS, 0o700 unless RAKUMODS.IO ~~ :e;

#-------------------------------------------------------------------------------
#`{{
  A note from https://discourse.gnome.org/t/gtk4-and-gdk-pixbuf/1015

    GdkPixbuf is deemphasized

    A number of GdkPixbuf-based APIs have been removed. The available replacements are either using GIcon, or the newly introduced GdkTexture or GdkPaintable classes instead.

    If you are dealing with pixbufs, you can use gdk_texture_new_for_pixbuf() to convert them to texture objects where needed.
}}

# SkimSource Gdk3Pixbuf not interesting anymore
enum SkimSource is export <
  Gtk3 Gdk3 Gtk4 Gdk4 Atk Glib Gio GObject Cairo Pango
>;

# GnomeVersions :VGdk3Pixbuf<2.42.8> not interesting anymore
enum GnomeVersions is export (
  :VGtk3<3.24.36>, :VGtk4<4.9.4>, :VAtk<2.26.1>, :VCairo<1.17.6>,
  :VGlib<2.74.5>, :VPango<1.50.7>
);
