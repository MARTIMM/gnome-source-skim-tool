
use v6.d;

use YAMLish;
use Gnome::SourceSkimTool::ConstEnumType;


#-------------------------------------------------------------------------------
=begin code

loop over objects
  when class                - "gir-type": "class"
    save $class-name        - "class-name": "Gnome::Gtk4::ConstraintLayout"
    when there are roles
      for each role
        save $role-name
        write
          'Interface $role-name <Interface>'
          'class $role-name <<(R,#80ffff)>>'
          '$class-name ..|> $role-name'

    repeat
      get $parent-name      - "parent-gnome-name": "GtkLayoutManager"
      write '$parent-name <|--- $class-name'

      when $parent-name is GInitiallyUnowned
        write classes above GInitiallyUnowned

      end repeat when parent is "GInitiallyUnowned"

      find parent hash entry, go to start repeat

=end code


#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Plantuml;

has Hash $!object-map;
has Hash $!work-data;

#-------------------------------------------------------------------------------
submethod BUILD ( SkimSource :package($source) ) {
  # Set $!work-data
  self.prepare-work-data($source);

  # Set $!object-map
  self!load-map($!work-data<gir-module-path>);
}

#-------------------------------------------------------------------------------
method generate-plantuml-files ( ) {

  my Str $plantuml;
  for $!object-map.keys -> $g-object {

#note "$?LINE $g-object";
#next unless $g-object ~~ m/ ShortcutController /;

    $plantuml = '';
    if $!object-map{$g-object}<gir-type> eq 'class' {
      $plantuml = self!plantuml-prefix;

      my Str $class-name = $!object-map{$g-object}<class-name>;
      $plantuml ~= self!implement-roles( $class-name, $g-object);

      my Str $parent-name;
      my Str $parent-gname;
      my Str $pg-object = $g-object;
      repeat until $parent-gname ~~ / GInitiallyUnowned | GObject / {
        $parent-name = $!object-map{$pg-object}<parent-raku-name> // Str;
        my Str $raku-package = $!work-data<raku-package>;
#note "$?LINE $pg-object, $parent-name";

        # Some parent names are empty im the repo-object-map.
        # Assuming the Gnome::N::TopLevelClassSupport
        if !$parent-name {
          #TODO might be linked to Object
          $plantuml ~= "Gnome::N::TopLevelClassSupport <|-- $class-name\n";
          last;
        }

        # When the parent point to a module outside the current distro,
        # assume that it is an object inheriting from Gnome::GObject::Object
        # which is often the case when outside Gtk*
        elsif $parent-name !~~ m/^ $raku-package / {
          if $parent-name ~~ m/ '::' Object $/ {
            $plantuml ~= Q:qq:to/EOPUML/;
              $!object-map{$pg-object}<parent-raku-name> <|-- $class-name
              EOPUML
          }

          else {
            $plantuml ~= Q:qq:to/EOPUML/;
              $!object-map{$pg-object}<parent-raku-name> <|-- $class-name
              Gnome::GObject::Object <|-- $parent-name
              EOPUML
          }

          last;
        }

        else {
#note "$?LINE $!object-map{$pg-object}.gist()";
          $parent-gname = $!object-map{$pg-object}<parent-gnome-name>;

          $plantuml ~= "$parent-name <|--- $class-name\n";

          $class-name = $parent-name;
          $pg-object = $parent-gname;

          $plantuml ~= self!implement-roles( $class-name, $pg-object);
        }
      }

      $plantuml ~= self!plantuml-postfix($parent-gname);
#note "$?LINE $plantuml";

      say "Generate uml file for $!object-map{$g-object}<class-name>"
        if $*verbose;
      self!generate-png( $!object-map{$g-object}<class-name>, $plantuml);
    }
  }
}

#-------------------------------------------------------------------------------
method !generate-png ( Str $class-name, Str $plantuml ) {

  my Str $png-file = $class-name;
  $png-file ~~ s/^ Gnome '::' <-[:]>* '::' //;
  $png-file = $!work-data<result-umlpng> ~ $png-file ~ '.png';


  my Str $temp-puml-png = "$*TMPDIR/plantuml-text.png";
  my Str $temp-puml-file = "$*TMPDIR/plantuml-text.puml";
  $temp-puml-file.IO.spurt($plantuml);

#note "$?LINE '/usr/bin/java -jar ./bin/plantuml-1.2025.2.jar -o $!work-data<result-umlpng> $temp-puml-file'";
  shell "/usr/bin/java -jar ./bin/plantuml-1.2025.2.jar $temp-puml-file";

  $temp-puml-png.IO.move($png-file);
}

#-------------------------------------------------------------------------------
method !load-map (
  $object-map-path, Str :$repo-file = 'repo-object-map.yaml'
) {
  my $fname = $object-map-path ~ $repo-file;
  if $fname.IO.r {
    $!object-map = load-yaml($fname.IO.slurp)
  }

  else {
    $!object-map = %()
  }
}

#-------------------------------------------------------------------------------
method !implement-roles ( Str $class-name, Str $g-object --> Str ) {
  my Str $plantuml = '';

  if $!object-map{$g-object}<implement-roles>:exists {
    for @($!object-map{$g-object}<implement-roles>) -> $role {
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
method !plantuml-prefix ( --> Str ) {
  q:to/EOPUML/;
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
    EOPUML
}

#-------------------------------------------------------------------------------
method !plantuml-postfix ( Str $gname --> Str ) {
  my Str $plantuml = '';

  given $gname {
    when 'GInitiallyUnowned' {
      $plantuml ~= q:to/EOPUML/;

        Gnome::GObject::Object <|-- Gnome::GObject::InitiallyUnowned
        EOPUML
    }

    when 'GObject' {
    }
  }

  $plantuml ~= q:to/EOPUML/;
    Gnome::N::TopLevelClassSupport <|-- Gnome::GObject::Object
    Gnome::N::GObjectSupport <|. Gnome::GObject::Object

    @enduml
    EOPUML

  $plantuml
}

#-------------------------------------------------------------------------------
submethod prepare-work-data ( SkimSource $source ) {

#note "$?LINE $*gnome-package.Str(), @*map-search-list.gist()";

  with $source {
    when Gtk3 {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk3/'),
      );
    }

    when Gdk3 {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Gdk3/'),
      );
    }

    when GdkPixbuf {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'GdkPixbuf/'),
      );
    }

    when Gtk4 {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Gtk4/'),
        :result-umlpng(API2MODS ~ 'gnome-gtk4/doc/plantuml/'),
        :raku-package<Gnome::Gtk4>,
      );
    }

    when Gdk4 {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Gdk4/'),
      );
    }

    when Gsk4 {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Gsk4/'),
      );
    }

    when Glib {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Glib/'),
      );
    }

    when Gio {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Gio/'),
        :result-umlpng(API2MODS ~ 'gnome-gio/doc/plantuml/'),
        :raku-package<Gnome::Gio>,
      );
    }

    when GObject {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'GObject/'),
      );
    }

    when Graphene {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Graphene/'),
      );
    }
#`{{
    when Atk {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Atk/'),
      );
    }
  }}

    when Pango {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'Pango/'),
      );
    }

    when PangoCairo {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'PangoCairo/'),
      );
    }

#`{{
    when GIRepo {
      $!work-data = %(
        :gir-module-path(SKIMTOOLDATA ~ 'GIRepository/'),
      );
    }
}}

    default {
#      $!work-data = %();
      die 'No SkimSource defined for ' ~ $_ // '-';
    }
  }

  note "$?LINE $!work-data<result-umlpng>";

  mkdir $!work-data<result-umlpng>, 0o700 unless $!work-data<result-umlpng>.IO.e;

#`{{
  $!work-data<raku-name> =
    $*gnome-class ?? "$*gnome-class" !! '' unless ?$!work-data<raku-name>;

  $!work-data<result-code-sections> = $!work-data<result-docs> ~ 'code-sections/';

  mkdir $!work-data<result-mods>, 0o700 unless $!work-data<result-mods>.IO.e;
  mkdir $!work-data<result-tests>, 0o700 unless $!work-data<result-tests>.IO.e;
#  mkdir $!work-data<result-docs>, 0o700 unless $!work-data<result-docs>.IO.e;
  mkdir $!work-data<result-code-sections>, 0o700
    unless $!work-data<result-code-sections>.IO.e;
}}

}