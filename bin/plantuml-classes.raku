#!/usr/bin/env -S raku -Ilib

use v6.d;

use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::Prepare;
#use Gnome::SourceSkimTool::SkimGirSource;
use Gnome::SourceSkimTool::Plantuml;


#-------------------------------------------------------------------------------
my SkimSource $gnome-package;
#my Str $*gnome-class;
#my Hash $*work-data;
my Bool $*verbose;

#-------------------------------------------------------------------------------
sub MAIN ( *@gnome-packages, Bool :$v = False ) {

  $*verbose = $v;

  for @gnome-packages -> $gpackage {
    try {
      $gnome-package = SkimSource(SkimSource.enums{$gpackage});
      CATCH {
        default {
          USAGE;
          exit(1);
        }
      }
    }

    say "\nGenerate the plantuml files for package $gnome-package" if $*verbose;
#    my Gnome::SourceSkimTool::Prepare $prepare .= new;
#    my Gnome::SourceSkimTool::SkimGirSource $skim-doc .= new;
#    $skim-doc.load-gir-file;
#    $skim-doc.get-classes-from-gir;

    my Gnome::SourceSkimTool::Plantuml $plantuml .=
       new(:package($gnome-package));
    $plantuml.generate-plantuml-files();
  }
}

#-------------------------------------------------------------------------------
sub USAGE ( ) {

}




















=finish
use YAMLish;







my Str $plantuml;
my Hash $object-map = load-map('./data/SkimToolData/Gtk4/');
for $object-map.keys -> $g-object {
  $plantuml = '';

  if $object-map{$g-object}<gir-type> eq 'class' {
    $plantuml = q:to/EOPFIX/;
      ```plantuml
      @startuml
      'scale 0.8

      skinparam packageStyle rectangle
      skinparam stereotypeCBackgroundColor #80ffff
      set namespaceSeparator ::
      hide members

      class Mu < raku >

      class Gnome::N::TopLevelClassSupport < Catch all class >
      Mu <|-- Gnome::N::TopLevelClassSupport

      Interface Gnome::N::GObjectSupport < Interface >
      class Gnome::N::GObjectSupport <<(R,#80ffff)>>
      EOPFIX

    my Str $class-name = $object-map{$g-object}<class-name>;
    $plantuml ~= implement-roles( $object-map, $class-name, $g-object);

#`{{
    if $object-map{$g-object}<roles>.elems {
      for @($object-map{$g-object}<roles>) -> $role {
        my Str $role-name = $role;
        $plantuml ~= Q:qq:to/EOPUML/;

          Interface $role-name \<Interface>
          class "$role-name" <<(R,#80ffff)>>
          $class-name ..|> "$role-name"
          EOPUML
      }
    }
}}

    printf "\n";
    my Str $parent-name;
    my Str $parent-gname;
    my Str $pg-object = $g-object;
    repeat until $parent-gname ~~ / GInitiallyUnowned | GObject / {
#note "$?LINE $object-map{$pg-object}.gist()";
      $parent-gname = $object-map{$pg-object}<parent-gnome-name>;
      $parent-name = $object-map{$pg-object}<parent-raku-name>;

      $plantuml ~= "$parent-name <|-- $class-name\n";

      $class-name = $parent-name;
      $pg-object = $parent-gname;

      $plantuml ~= implement-roles( $object-map, $class-name, $pg-object);
    }

    given $parent-gname {
      when 'GInitiallyUnowned' {
        $plantuml ~= q:to/EOPFIX/;

          Gnome::GObject::Object <|-- Gnome::GObject::InitiallyUnowned
          EOPFIX
      }

      when 'GObject' {
      }
    }

    $plantuml ~= q:to/EOPFIX/;
      Gnome::N::TopLevelClassSupport <|-- Gnome::GObject::Object
      Gnome::N::GObjectSupport <|. Gnome::GObject::Object
      
      @enduml
      ```
      EOPFIX


note $plantuml;
last
  }
}

#-------------------------------------------------------------------------------
sub implement-roles (
  Hash $object-map, Str $class-name, Str $g-object --> Str
) {
  my Str $plantuml = '';

  if $object-map{$g-object}<implement-roles>:exists {
    for @($object-map{$g-object}<implement-roles>) -> $role {
      my Str $role-name = $role;
      $plantuml ~= Q:qq:to/EOPUML/;

        Interface $role-name < Interface >
        class "$role-name" <<(R,#80ffff)>>
        $class-name ..|> "$role-name"
        EOPUML
    }
  }
  
  $plantuml
}

#-------------------------------------------------------------------------------
sub load-map (
  $object-map-path, Str :$repo-file = 'repo-object-map.yaml' --> Hash
) {
  my $fname = $object-map-path ~ $repo-file;
  if $fname.IO.r {
    load-yaml($fname.IO.slurp)
  }

  else {
    %()
  }
}



=finish


"GtkShortcutsGroup": 
  "class-name": "Gnome::Gtk4::ShortcutsGroup"
  "gir-type": "class"
  "gnome-name": "GtkShortcutsGroup"
  "parent-gnome-name": "GtkBox"
  "parent-raku-name": "Gnome::Gtk4::Box"
  "roles": 
    - "Gnome::Gtk4::R-Accessible"
    - "Gnome::Gtk4::R-Buildable"
    - "Gnome::Gtk4::R-ConstraintTarget"
    - "Gnome::Gtk4::R-Orientable"
  "source-filename": "shortcutsgroup"
  "symbol-prefix": "gtk_shortcuts_group_"
  "type-letter": ""
  "type-name": "ShortcutsGroup"


```plantuml
@startuml
'scale 0.8

skinparam packageStyle rectangle
skinparam stereotypeCBackgroundColor #80ffff
set namespaceSeparator ::
hide members

class Gnome::Gtk4::ShortcutsGroup
class Gnome::Gtk4::Box


Interface Gnome::Gtk4::R-Accessible <Interface>
class Gnome::Gtk4::R-Accessible <<(R,#80ffff)>>

Interface Gnome::Gtk4::R-Buildable <Interface>
class Gnome::Gtk4::R-Buildable <<(R,#80ffff)>>

Interface Gnome::Gtk4::R-ConstraintTarget <Interface>
class Gnome::Gtk4::R-ConstraintTarget <<(R,#80ffff)>>

Interface Gnome::Gtk4::R-Orientable <Interface>
class Gnome::Gtk4::R-Orientable <<(R,#80ffff)>>


Gnome::Gtk4::ShortcutsGroup ..|> "Gnome::Gtk4::R-Accessible"
Gnome::Gtk4::ShortcutsGroup ..|> "Gnome::Gtk4::R-Buildable"
Gnome::Gtk4::ShortcutsGroup ..|> "Gnome::Gtk4::R-ConstraintTarget"
Gnome::Gtk4::ShortcutsGroup ..|> "Gnome::Gtk4::R-Orientable"

Gnome::Gtk4::Box <|--- Gnome::Gtk4::ShortcutsGroup

@enduml
```
