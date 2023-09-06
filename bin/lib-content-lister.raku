#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::ConstEnumType;
use YAMLish;

#-------------------------------------------------------------------------------
my Hash $list = %();

my Str $api1 = $*HOME ~ '/Languages/Raku/Projects';
my Str $api2 = [~] $api1, '/gnome-source-skim-tool/gnome-api2/';

my ExternalModuleType $mod-type;

#`{{
# Old packages
$mod-type = EMTNotInApi2;
list-dir("$api1/gnome-gtk3/lib");
list-dir("$api1/gnome-gdk3/lib");
list-dir("$api1/gnome-glib/lib");
list-dir("$api1/gnome-gobject/lib");
list-dir("$api1/gnome-gio/lib");
list-dir("$api1/gnome-native/lib");
list-dir("$api1/gnome-cairo/lib");
list-dir("$api1/gnome-pango/lib");
#list-dir("$api1/gnome-/lib");
}}

# New packages
$mod-type = EMTInApi2;
list-dir("$api2/gnome-gtk3/lib");
list-dir("$api2/gnome-gdk3/lib");
list-dir("$api2/gnome-glib/lib");
list-dir("$api2/gnome-gobject/lib");
list-dir("$api2/gnome-gio/lib");
list-dir("$api2/gnome-native/lib");
list-dir("$api2/gnome-cairo/lib");
list-dir("$api2/gnome-pango/lib");

#list-dir('xt/NewRakuModules/lib/Gnome");
#list-dir('xt/Gir/lib/Gnome");

lib-content-list-file.IO.spurt(save-yaml($list));


#-------------------------------------------------------------------------------
sub list-dir ( Str $cdir ) {
  # Skip all hidden directories like .precomp
  return if $cdir ~~ m/^ '.' /;
  return unless $cdir.IO.d;

  for dir($cdir) -> $f {
    # Recurse into directory
    if $f ~~ :d {
      list-dir($f.Str);
    }

    else {
      my Str $m = $f.Str;

      # Skip all but module files
      next unless $m ~~ m/ \. rakumod $/;

      # Remove large part of path, then drop the extension, then make it a class
      $m ~~ s/^ .*? '/lib/' //;
      $m ~~ s/ \. rakumod $//;
      $m ~~ s:g/ '/' /::/;

      $list{$m} = $mod-type;
    }
  }
}

