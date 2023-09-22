
=begin pod

=head1 Generate Raku files using a filename.

=end pod

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Prepare;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenerateCode:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Doc $!grd;

has Str $!filename;
has Hash $!filedata;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {
  $!mod .= new;

  self!get-data-from-filename;
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  # Info of types found
  note "\nTypes found in file $!filename";
  for $!filedata.kv -> $t, $h {
    note "  $t: $h.keys()";
    print "\n";
  }

  my Str ( $c, $filename, $class-name, $function-hash);
  my Bool $has-functions = False;

  for $!filedata.keys {
    # -> $type-name
#note "$?LINE $_";

    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    when 'class' {
      for $!filedata<class>.keys -> $class-name {
        $*gnome-class = $!filedata<class>{$class-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        say "\nGenerate Raku class ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Class');
        my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
        $raku-module.generate-code;
      }
    }

    when 'interface' {
     for $!filedata<interface>.keys -> $interface-name {
        $*gnome-class = $!filedata<interface>{$interface-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        say "\nGenerate Raku role ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Interface');
        my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;
        $raku-module.generate-code;
      }
    }

    when 'record' {
      for $!filedata<record>.keys -> $record-name {
        $*gnome-class = $record-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        # Generate a structure into a 'package-path/N-*.rakumod' file
        $!mod.generate-structure(
          |$!mod.init-xpath(
            'record',
            "$*work-data<gir-module-path>R-$*gnome-class.gir"
#            'gir-record-file'
          )
        );

        say "\nGenerate Raku record ", $*work-data<raku-class-name>;

        # Generate class methods etc into a 'raku-package/*.rakumod' file
        require ::('Gnome::SourceSkimTool::Record');
        my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
        $raku-module.generate-code;
      }
    }

    when 'union' {
      for $!filedata<union>.keys -> $union-name {
        $*gnome-class = $union-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        # Generate a union into a 'package-path/N-*.rakumod' file
        $!mod.generate-union(
          |$!mod.init-xpath(
            'union',
            "$*work-data<gir-module-path>U-$*gnome-class.gir"
#            'gir-union-file'
          )
        );

        say "\nGenerate Raku union ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Union');
        my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
        $raku-module.generate-code;
      }
    }
  }

#  my Bool $first = True;
  my Gnome::SourceSkimTool::Prepare $t-prep; # .= new;
  for $!filedata.keys -> $gir-type {
    next if $gir-type ~~ any(<class interface record union>);
    next if $gir-type ~~ any(<callback alias function-macro>);

    # Test if gir-type is selected Skip a key if not mentioned on the
    # commandline or just do it when there is no preference
    next if ?@*gir-type-select and ($gir-type ~~ none(|@*gir-type-select));

    my $data = $!filedata{$gir-type}.values[0];
#note "$?LINE $gir-type, ", $data.gist;

    once $t-prep .= new;
    my Str $type-name = $data<type-name>;
    my Str $prefix = $*work-data<name-prefix>;
    $type-name ~~ s:i/^ 'T-' $prefix /T-/;
    $filename = [~] $*work-data<result-mods>, $type-name, '.rakumod';
    $class-name = $data<class-name>;
    $class-name ~~ s:i/ '::T-' $prefix /::T-/;
    $!mod.add-import($class-name);
#note "$?LINE $gir-type, $filename, $class-name";
#note "$?LINE $*work-data<sub-prefix>";

    given $gir-type {
      when 'constant' {
        my @constants = ();
        for $!filedata<constant>.kv -> $k, $v {
          my Str $name = $t-prep.drop-prefix( $k, :constant);
          @constants.push: ( $name, $v<constant-type>, $v<constant-value>);
  #        $filename = $v<type-name> unless ?$filename;
  #        $class-name = $v<class-name> unless ?$class-name;
        }

        $c ~= $!mod.generate-constants(@constants);
      }

      # Only for documentation
      when 'docsection' { }

      when 'enumeration' {
        my Array $enum-names = [];
        for $!filedata<enumeration>.kv -> $k, $v {
          $enum-names.push: $k;
  #        $filename = $v<type-name> unless ?$filename;
  #        $class-name = $v<class-name> unless ?$class-name;
        }

        $c ~= $!mod.generate-enumerations-code($enum-names);
      }

      when 'bitfield' {
        my Array $bitfield-names = [];
        for $!filedata<bitfield>.kv -> $k, $v {
          $bitfield-names.push: $k;
  #        $filename = $v<type-name> unless ?$filename;
  #        $class-name = $v<class-name> unless ?$class-name;
        }

        $c ~= $!mod.generate-bitfield-code($bitfield-names);
      }

      when 'callback' {
        
      }

      when 'function' {
        $has-functions = True;
        my Array $function-names = [];
        for $!filedata<function>.kv -> $k, $v {
          $function-names.push: $v<function-name>;
  #        $filename = $v<type-name> unless ?$filename;
  #        $class-name = $v<class-name> unless ?$class-name;
        }

#        my Str $package-name = (S/ \d+ $// with $*gnome-package.Str).lc;
#        $*work-data<sub-prefix> = $package-name ~~ any(<glib gio>)
#                                  ?? 'g_' !! $package-name ~ '_';
#note "$?LINE f $package-name $*work-data<sub-prefix>";

        my Hash $hms = $!mod.get-standalone-functions($function-names);
        $function-hash = $!mod.generate-functions($hms);
      }

      when 'alias' {
        
      }
    }
  }

#TL:1:$*work-data<raku-class-name>:
#note "$?LINE $class-name, $filename";

  if ?$class-name and ?$filename {
#    mkdir $filename.IO.dirname, 0o750 unless $filename.IO.dirname.IO ~~ :e;

    my Str $code = qq:to/RAKUMOD/;
      # Command to generate: $*command-line
      use v6;
      RAKUMOD

    $code ~= $!mod.set-unit-for-file( $class-name, $has-functions);
    $code ~= $c ~ "\n" if ?$c;

    if $has-functions {
      $code ~= qq:to/RAKUMOD/;

        {$!grd.pod-header('BUILD variables')}
        # Define helper
        has Gnome::N::GnomeRoutineCaller \$!routine-caller;

        {$!grd.pod-header('BUILD submethod')}
        submethod BUILD ( ) \{
          # Initialize helper
          \$!routine-caller .= new\( :library\($*work-data<library>\), :sub-prefix\("$*work-data<name-prefix>_"\)\);
        }

        # Next two methods need checks for proper referencing or cleanup 
        method native-object-ref \( \$n-native-object ) \{
          \$n-native-object
        \}

        method native-object-unref \( \$n-native-object ) \{
        #  self._fallback-v2\( 'free', my Bool \$x);
        \}

        my Hash \$methods = \%\(
          $function-hash
        );

        RAKUMOD

      $!mod.add-import('NativeCall');
      $!mod.add-import('Gnome::N::NativeLib');

      $code ~= q:to/RAKUMOD/;
        # This method is recognized in class Gnome::N::TopLevelClassSupport.
        method _fallback-v2 ( Str $name, Bool $_fallback-v2-ok is rw, *@arguments ) {
          if $methods{$name}:exists {
            my $native-object = self.get-native-object-no-reffing;
            $_fallback-v2-ok = True;
            return $!routine-caller.call-native-sub(
              $name, @arguments, $methods, :$native-object
            );
          }

          else {
            callsame;
          }
        }
        RAKUMOD
    }

    $code = $!mod.substitute-MODULE-IMPORTS( $code, $class-name);

#    $filename = $*work-data<result-mods> ~ $filename ~ '.rakumod';
    $!mod.save-file( $filename, $code, "types module");
  }
}

#-------------------------------------------------------------------------------
# Fill the Hash $!filedata with data from a repo-object-map.yaml where the
# 'source-filename' field of every object must match $filename. The data is
# reordered to have its type as its toplevel key.
method !get-data-from-filename ( ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  $!mod.check-search-list;
  $!mod.check-map($package);
  my Hash $h := $*object-maps{$package};
  $!filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<source-filename>:exists
                and $v<source-filename> eq $!filename;

    # Reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}

