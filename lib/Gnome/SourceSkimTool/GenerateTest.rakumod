
=begin pod

=head1 Generate Raku files using a filename.

=end pod
use v6.d;

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Test;
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::Code;

#use XML;
#use XML::XPath;
#use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenerateTest:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Test $!tst;
has Gnome::SourceSkimTool::Code $!mod;

#has XML::XPath $!xpath;

has Str $!filename;
has Hash $!filedata;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {
  $!mod .= new;
  $!tst .= new;

  self!get-data-from-filename;
}

#-------------------------------------------------------------------------------
method generate-test ( ) {

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

    # Skip a key if not mentioned on the commandline or
    # just do it when there is no preverence
    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    # First check for classes, interfaces, records or unions
    when 'class' {
      for $!filedata<class>.keys -> $class-name {
        $*gnome-class = $!filedata<class>{$class-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
#$prepare.display-hash( $*work-data, :label('class work data'));

        say "\nGenerate Tests for Raku class ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Class');
        my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
        $raku-module.generate-test;
      }
    }

    when 'interface' {
     for $!filedata<interface>.keys -> $interface-name {
        $*gnome-class = $!filedata<interface>{$interface-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
#$prepare.display-hash( $*work-data, :label<interface work data>);

        say "\nGenerate Tests for Raku role ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Interface');
        my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;
        $raku-module.generate-test;
      }
    }

    when 'record' {
      for $!filedata<record>.keys -> $record-name {
        $*gnome-class = $record-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
#$prepare.display-hash( $*work-data, :label<record work data>);
#`{{TODO
        # Generate a structure tests for 'package-path/N-*.rakumod' file
        $!tst.generate-structure-tests(
          |$!mod.init-xpath(
            'record',
            "$*work-data<gir-module-path>R-$*gnome-class.gir"
          )
        );
}}
        say "\nGenerate Raku record tests ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Record');
        my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
        $raku-module.generate-test;
      }
    }

    when 'union' {
      for $!filedata<union>.keys -> $union-name {
        $*gnome-class = $union-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
#$prepare.display-hash( $*work-data, :label<union work data>);

#`{{TODO
        # Generate a union into a 'package-path/N-*.rakumod' file
        $!mod.generate-union-tests(
          |$!mod.init-xpath(
            'union',
            "$*work-data<gir-module-path>U-$*gnome-class.gir"
#            'gir-union-file'
          )
        );
}}
        say "\nGenerate Raku union tests ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Union');
        my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
        $raku-module.generate-test;
      }
    }
  }

  # Other types than handled above are gathered into one test file
  my Gnome::SourceSkimTool::Prepare $t-prep;  # .= new;
  for $!filedata.keys -> $gir-type {

    next if $gir-type ~~ any(<class interface record union>);
    next if $gir-type ~~ any(<callback alias function-macro docsection>);

    # Test if gir-type is selected Skip a key if not mentioned on the
    # commandline or just do it when there is no preference
    next if ?@*gir-type-select and ($gir-type ~~ none(|@*gir-type-select));

    once $t-prep .= new;

    my Hash $data = $!filedata{$gir-type}.values[0];
note "$?LINE $gir-type, $*work-data<raku-package>, ", $data.gist;

    next unless ?$data<type-name>;
    $data<package-name> = $*work-data<raku-package>;

    my Str $type-name = $data<type-name>;
#    my Str $prefix = $*work-data<name-prefix>;
#    $type-name ~~ s:i/^ 'T-' $prefix /T-/;
#    $filename = [~] $*work-data<result-tests>, $type-name, '.rakutest';
#    $class-name = $data<class-name>;
#    $class-name ~~ s:i/ '::T-' $prefix /::T-/;
    $filename = $!mod.set-object-name( $data, :name-type(FilenameTestType));
    $class-name = $!mod.set-object-name($data);
    $!mod.add-import($class-name);
#note "$?LINE $gir-type, $filename, $class-name";

    given $gir-type {
      when 'callback' {

      }

      when 'constant' {
        my @constants = ();
        for $!filedata<constant>.kv -> $k, $v {
          my Str $name = $k; #$t-prep.drop-prefix( $k, :constant);
          @constants.push: ( $name, $v<constant-type>, $v<constant-value>);
  #        $filename = $v<type-name> unless ?$filename;
  #        unless ?$class-name {
  #          $class-name = $v<class-name>;
  #        }
        }

        say "\nGenerate Tests for constants";

        $c ~= $!tst.generate-constant-tests(@constants);
      }

      # Only for documentation
      when 'docsection' { }

      when 'enumeration' {
        my Array $enum-names = [];
        for $!filedata<enumeration>.kv -> $k, $v {
          $enum-names.push: $k;
  #        $filename = $v<type-name> unless ?$filename;
  #        unless ?$class-name {
  #          $class-name = $v<class-name>;
  #          $!mod.add-import($class-name);
  #        }
        }

        say "\nGenerate Tests for enumerations";
        $c ~= $!tst.generate-enumeration-tests($enum-names);
      }

      when 'bitfield' {
        my Array $bitfield-names = [];
        for $!filedata<bitfield>.kv -> $k, $v {
          $bitfield-names.push: $k; #$t-prep.drop-prefix($k);
  #        $filename = $v<type-name> unless ?$filename;
  #        unless ?$class-name {
  #          $class-name = $v<class-name>;
  #          $!mod.add-import($class-name);
  #        }
        }

        say "\nGenerate Tests for bitfields";
        $c ~= $!tst.generate-bitfield-tests($bitfield-names);
      }
  
      when 'function' {
        $has-functions = True;
        my Str $test-variable;
        my Array $function-names = [];
        for $!filedata<function>.kv -> $k, $v {
  #        my Str $name = $t-prep.drop-prefix( $k, :function);
          $function-names.push: $v<function-name>;
  #        unless ?$class-name {
  #          $filename = $v<type-name> unless ?$filename;
            $test-variable = '$' ~ $v<source-filename>;
  #          $class-name = $v<class-name>;
  #          $!mod.add-import($class-name);
  #        }
        }

        say "\nGenerate Tests for functions";
  
        my Str $package-name = S/ \d+ $// with $*gnome-package.Str;
        $*work-data<sub-prefix> = $package-name.lc ~ '_';

        my Hash $hms = $!mod.get-standalone-functions($function-names);
#note "$?LINE $class-name $test-variable";
        $c ~= "\nmy $class-name $test-variable .= new;\n";
        $c ~= $!tst.generate-method-tests( $hms, $test-variable, :!ismethod);
  #      $c ~= $!tst.generate-function-tests( $class-name, $hms);
      }

      when 'alias' {

      }
    }
  }

#note "$?LINE $c, $class-name, $filename";
  if ?$c and ?$class-name and ?$filename {
#    $filename ~~ s@ '/lib/' @/t/@;
#    $filename = $*work-data<result-tests> ~ $filename ~ '.rakutest';
#note "$?LINE $filename";

#    mkdir( $filename.IO.dirname, 0o750) unless $filename.IO.dirname.IO ~~ :e;
    my Str $code = qq:to/RAKUMOD/;
      { $!tst.prepare-test($class-name); }

      $c

      {HLSEPARATOR}
      done-testing;
      =finish

      RAKUMOD

#`{{
    if $has-functions {
      $code ~= qq:to/RAKUMOD/;

      {pod-header('BUILD variables')}
      # Define helper
      has Gnome::N::GnomeRoutineCaller \$!routine-caller;

      {pod-header('BUILD submethod')}
      submethod BUILD ( ) \{
        # Initialize helper
        \$!routine-caller .= new\( :library\($*work-data<library>\), :sub-prefix\<$*work-data<sub-prefix>\>);
      }

      my Hash \$methods = \%\(
        $function-hash
      );

      RAKUMOD

      $code ~= q:to/RAKUMOD/;
        # This method is recognized in class Gnome::N::TopLevelClassSupport.
        method _fallback-v2 ( Str $n, Bool $_fallback-v2-ok is rw, *@arguments ) {
          my Str $name = S:g/ '-' /_/ with $n;
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
}}

    $code = $!mod.substitute-MODULE-IMPORTS($code);

    $!mod.save-file( $filename, $code, "types tests");
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
