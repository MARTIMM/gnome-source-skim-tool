#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::ConstEnumType;
use YAMLish;

#-------------------------------------------------------------------------------
my Hash $list = %();

# Old packages
my ExternalModuleType $mod-type = EMTNotInApi2;
list-dir('/home/marcel/Languages/Raku/Projects/gnome-gtk3/lib');
list-dir('/home/marcel/Languages/Raku/Projects/gnome-gdk3/lib');
list-dir('/home/marcel/Languages/Raku/Projects/gnome-glib/lib');
list-dir('/home/marcel/Languages/Raku/Projects/gnome-gobject/lib');
list-dir('/home/marcel/Languages/Raku/Projects/gnome-gio/lib');
list-dir('/home/marcel/Languages/Raku/Projects/gnome-native/lib');
list-dir('/home/marcel/Languages/Raku/Projects/gnome-cairo/lib');
list-dir('/home/marcel/Languages/Raku/Projects/gnome-pango/lib');
#list-dir('/home/marcel/Languages/Raku/Projects/gnome-/lib');

# New packages
$mod-type = EMTInApi2;
list-dir('xt/NewRakuModules/lib/Gnome');
list-dir('xt/Gir/lib/Gnome');


lib-content-list-file.IO.spurt(save-yaml($list));


#-------------------------------------------------------------------------------
sub list-dir ( Str $cdir ) {
  return if $cdir ~~ m/ '.precomp' /;

  for dir($cdir) -> $f {
    if $f ~~ :d {
      list-dir($f.Str);
    }

    else {
      my Str $m = $f.Str;
      next if $m ~~ m/ [ '.directory' || 'code-workspace' ] /;

      $m ~~ s/^ .*? '/lib/' //;
      $m ~~ s/ \. rakumod $//;
      $m ~~ s:g/ '/' /::/;

      $list{$m} = $mod-type;
    }
  }
}

