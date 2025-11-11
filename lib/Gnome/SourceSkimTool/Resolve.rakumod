use v6;

use Gnome::SourceSkimTool::ConstEnumType;
use YAMLish;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Resolve:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
#submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method set-object-name (
  Hash $object-map-entry, ObjectNameType :$name-type = ClassnameType,
  --> Str
) {
  my Str $object-name;
  my Str $type-letter = $object-map-entry<type-letter> // '';
  $object-map-entry<package-name> //= $*work-data<raku-package>;
  $object-map-entry<type-name> //= $*work-data<raku-name>;

  if ?$type-letter and $type-letter eq 'T' {
     $object-name = 'T-' ~ $object-map-entry<source-filename>;
  }

  elsif ?$type-letter {
    $object-name = "$type-letter\-$object-map-entry<type-name>";
  }

  else {
    $object-name = $object-map-entry<type-name>;
  }

  given $name-type {
    when ClassnameType {
#say Backtrace.new.nice if $object-map-entry<package-name>:!exists;
      $object-name = $object-map-entry<package-name> ~ '::' ~ $object-name;
    }

    when TestVariableType {
      $object-name = "\$$object-name".lc;
    }

    when any(
      FilenameType, FilenameCodeType, FilenameDocType,
      FilenameTestType, FilenameGirType
    ) {
      when FilenameCodeType {
        $object-name = [~] $*work-data<result-mods>, $object-name, '.rakumod';
      }

      when FilenameDocType {
        $object-name = [~] $*work-data<result-docs>, $object-name, '.rakudoc';
      }

      when FilenameTestType {
        $object-name = [~] $*work-data<result-tests>, $object-name, '.rakutest';
      }

      when FilenameGirType {
        # Recalculate typeletter and add other ones, they have been made
        # different in the gir data environment
        given $type-letter {
          when 'T' {
            if $object-map-entry<gir-type> eq 'record' {
              $object-name = "R-$object-map-entry<type-name>";
            }
            else {
              $object-name = "U-$object-map-entry<type-name>";
            }
          }

          when 'N' {
            if $object-map-entry<gir-type> eq 'record' {
              $object-name = "R-$object-map-entry<type-name>";
            }
            else {
              $object-name = "U-$object-map-entry<type-name>";
            }
          }

          when 'R' { $object-name = "I-$object-map-entry<type-name>"; }
          default { $object-name = "C-$object-map-entry<type-name>"; }
        }

        $object-name = [~] $*work-data<gir-module-path>, $object-name, '.gir';
      }
    }
  }

  $object-name
}

#-------------------------------------------------------------------------------
# Fill the Hash $!filedata with data from a repo-object-map.yaml where the
# 'source-filename' field of every object must match $filename. The data is
# reordered to have its type as its toplevel key.
method get-data-from-filename ( Str $filename --> Hash ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  self!check-search-list;
  self!check-map($package);
  my Hash $h := $*object-maps{$package};
  my Hash $filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<source-filename>:exists
                and $v<source-filename> eq $filename;

    # Reorder on type
    $filedata{$v<gir-type>}{$k} = $v;
  }

  $filedata
}

#-------------------------------------------------------------------------------
method search-name ( Str $name is copy --> Hash ) {

#note "$?LINE search-name $name";# if $name ~~ m/GDestroyNotify | destroy/;

  self!check-search-list;

  my Str $raku-package = $*work-data<raku-package>;
  if $name ~~ m/ '::' / {
    $name ~~ s/^ $raku-package '::' //;
    $name ~~ s/^ [<[NTR]> '-']? //;
  }

  my Hash $h = %();
  for @*map-search-list -> $map-name {
#note "\n$?LINE $map-name";
    self!check-map($map-name);

#note "$?LINE: Search for $name in map $map-name";
#note "$?LINE: search $name, $map-name" if $name ~~ m:i/ pixbuf /;

    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists
            and ( $*object-maps{$map-name}{$name}:exists 
                  or $*object-maps{$map-name}{$map-name ~ $name}:exists
                );

    # Get the Hash from the object maps
    $h = $*object-maps{$map-name}{$name}
         // $*object-maps{$map-name}{$map-name ~ $name};
    if $map-name ~~ m/G [d || s || t] k $/ {
      if $raku-package ~~ /$<v>=[\d+] $/ {
        $h<package-name> = "Gnome\:\:$map-name" ~ $/<v>.Str;
      }
    }

    else {
      $h<package-name> = "Gnome\:\:$map-name";
    }

#note "$?LINE $map-name, $name, $raku-package, $h<package-name>";

    # Add package name to this hash
#    $h<raku-package> = $*other-work-data{$map-name}<raku-package>;
    last;
  }

#note "$?LINE $h.gist()";
#say Backtrace.new.nice if $name eq 'Enums';

  $h
}

#-------------------------------------------------------------------------------
method !check-search-list ( ) {
  unless ?@*map-search-list {
    given $*gnome-package.Str {
      when m/^ [ Gtk | Gdk ] 3 / {
        @*map-search-list = <
          Gtk Gdk GdkPixbuf Pango Gio GObject Glib
        >
      }

      when m/^ [ Gtk | Gdk | Gsk ] 4 / {
        @*map-search-list = <
          Gtk Gdk Gsk Graphene GdkPixbuf Pango Gio GObject Glib
        >
      }

      when m/^ [Gsk4 | Graphene] / {
        @*map-search-list = <Gdk GObject Glib Graphene>
      }

      when 'Gio' {
        @*map-search-list = <Gio GObject Glib>
      }

      when 'GdkPixbuf' {
        @*map-search-list = <Gdk GdkPixbuf Gio GObject Glib>
      }

      when m/ Pango / {
        @*map-search-list = <Pango GObject Glib>
      }

      when 'GObject' {
        @*map-search-list = <GObject Glib>
      }

      when 'Glib' {
        @*map-search-list = ('Glib',)
      }
     }
  }
}

#-------------------------------------------------------------------------------
method !check-map ( Str $map ) {
  unless $*object-maps{$map}:exists {
    my Str $package = $*gnome-package.Str;
    my Str $module-path;

    if $package ~~ m/ '3' $/ and $map ~~ any(<Gtk Gdk>) {
      $module-path = SKIMTOOLDATA ~ $map ~ '3/';
    }

    elsif $package ~~ m/ '4' $/ and $map ~~ any(<Gtk Gdk Gsk>) {
      $module-path = SKIMTOOLDATA ~ $map ~ '4/';
    }

    else {
      $module-path = SKIMTOOLDATA ~ $map ~ '/';
    }

    $*object-maps{$map} = self!load-map( $map, $module-path);
  }
}

#-------------------------------------------------------------------------------
method !load-map ( Str $map, Str $object-map-path --> Hash ) {

  my $fname = $object-map-path ~ 'repo-object-map.yaml';
  if $fname.IO.r {
    note "Load object map for $map" if $*verbose;
    load-yaml($fname.IO.slurp);
  }

  else {
    note "File object map '$fname' not found";
    %()
  }
}




=finish
#-------------------------------------------------------------------------------
# Search for names of specific type in object maps 
method search-entries ( Str $entry-name, Str $value --> Hash ) {

  self.check-search-list;

  my Hash $h = %();
  for @*map-search-list -> $map-name {
    self.check-map($map-name);

#    note "Search for entries in map $map-name where field $entry-name ≡? $value"
#      if $*verbose;
    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists;

    for $*object-maps{$map-name}.kv -> $name, $value-hash {
      next unless $value-hash{$entry-name}:exists;

      next unless $value-hash{$entry-name} eq $value;
      $h{$name} = $value-hash;

      # Add package name to this hash
#      $h{$name}<raku-package> = $*other-work-data{$map-name}<raku-package>;
    }

    last if ?$h;
  }

#say "$?LINE: search entries for $entry-name -> $h.gist()";

  $h
}
