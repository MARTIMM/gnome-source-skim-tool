
=begin pod

=head1 Generate Raku files using a filename.

=end pod

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

    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    when 'class' {
      for $!filedata<class>.keys -> $class-name {
        $*gnome-class = $!filedata<class>{$class-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
$prepare.display-hash( $*work-data, :label('class work data'));

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
$prepare.display-hash( $*work-data, :label<interface work data>);

        say "\nGenerate Tests for Raku role ", $*work-data<raku-class-name>;

#        require ::('Gnome::SourceSkimTool::Interface');
#        my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;
#        $raku-module.generate-test;
      }
    }

    when 'record' {
      for $!filedata<record>.keys -> $record-name {
        $*gnome-class = $record-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
$prepare.display-hash( $*work-data, :label<record work data>);

#        $!mod.generate-structure(
#          |$!mod.init-xpath( 'record', 'gir-record-file')
#        );

        say "\nGenerate Tests for Raku record from ", $*work-data<raku-class-name>;

#        require ::('Gnome::SourceSkimTool::Record');
#        my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
#        $raku-module.generate-test;
      }
    }

    when 'union' {
      for $!filedata<union>.keys -> $union-name {
        $*gnome-class = $union-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
$prepare.display-hash( $*work-data, :label<union work data>);

#        $!mod.generate-union(
#          |$!mod.init-xpath( 'union', 'gir-union-file')
#        );

        say "\nGenerate Raku union from ", $*work-data<raku-class-name>;

#        require ::('Gnome::SourceSkimTool::Union');
#        my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
#        $raku-module.generate-test;
      }
    }
  }

  my Gnome::SourceSkimTool::Prepare $t-prep .= new;
  for $!filedata.keys {
     # -> $type-name

    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    # Only for documentation
    when 'docsection' { }

    when 'constant' {
      my @constants = ();
      for $!filedata<constant>.kv -> $k, $v {
        my Str $name = $t-prep.drop-prefix( $k, :constant);
        @constants.push: ( $name, $v<constant-type>, $v<constant-value>);
        $filename = $v<module-filename> unless ?$filename;
        unless ?$class-name {
          $class-name = $v<class-name>;
          $!mod.add-import($class-name);
        }
      }

      say "\nGenerate Tests for constants";

      $c ~= $!tst.generate-constant-tests(@constants);
    }

    when 'enumeration' {
      my Array $enum-names = [];
      for $!filedata<enumeration>.kv -> $k, $v {
        $enum-names.push: $k;
        $filename = $v<module-filename> unless ?$filename;
        unless ?$class-name {
          $class-name = $v<class-name>;
          $!mod.add-import($class-name);
        }
      }

      say "\nGenerate Tests for enumerations";
      $c ~= $!tst.generate-enumeration-tests($enum-names);
    }

    when 'bitfield' {
      my Array $bitfield-names = [];
      for $!filedata<bitfield>.kv -> $k, $v {
        $bitfield-names.push: $t-prep.drop-prefix($k);
        $filename = $v<module-filename> unless ?$filename;
        unless ?$class-name {
          $class-name = $v<class-name>;
          $!mod.add-import($class-name);
        }
      }

      say "\nGenerate Tests for bitfields";
      $c ~= $!tst.generate-bitfield-tests($bitfield-names);
    }
 
    when 'function' {
      $has-functions = True;
      my Array $function-names = [];
      for $!filedata<function>.kv -> $k, $v {
#        my Str $name = $t-prep.drop-prefix( $k, :function);
        $function-names.push: $v<function-name>;
        $filename = $v<module-filename> unless ?$filename;
        unless ?$class-name {
          $class-name = $v<class-name>;
          $!mod.add-import($class-name);
        }
      }

      say "\nGenerate Tests for functions";
 
      my Str $package-name = S/ \d+ $// with $*gnome-package.Str;
      $*work-data<sub-prefix> = $package-name.lc ~ '_';

      my Hash $hms = $!mod.get-standalone-functions($function-names);
      $c ~= $!tst.generate-function-tests( $class-name, $hms);
    }
  }

  if ?$c and ?$class-name and ?$filename {
    $filename ~~ s@ '/lib/' @/t/@;
    $filename ~~ s/ rakumod /rakutest/;
#note "$?LINE $filename";

    mkdir( $filename.IO.dirname, 0o750) unless $filename.IO.dirname.IO ~~ :e;
    my Str $code = qq:to/RAKUMOD/;
      { $!tst.set-unit-for-file($class-name); }

      $c

      {HLSEPARATOR}
      done-testing;
      =finish

      RAKUMOD

#`{{
    if $has-functions {
      $code ~= qq:to/RAKUMOD/;

      {$!grd.pod-header('BUILD variables')}
      # Define helper
      has Gnome::N::GnomeRoutineCaller \$!routine-caller;

      {$!grd.pod-header('BUILD submethod')}
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

    note "Save types tests in ", $filename.IO.basename;
    $filename.IO.spurt($code);

#note "\n$?LINE\n$code";
  }
}

#`{{
  my Gnome::SourceSkimTool::Prepare $t-prep .= new;
  for $!filedata.keys {
    # -> $type-name

    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    # Only for documentation
    when 'docsection' { }

    when 'constant' {
      my @constants = ();
      for $!filedata<constant>.kv -> $k, $v {
        my Str $name = $t-prep.drop-prefix( $k, :constant);
        @constants.push: ( $name, $v<constant-type>, $v<constant-value>);
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      $c ~= $!mod.generate-constants(@constants);
    }

    when 'enumeration' {
      my Array $enum-names = [];
      for $!filedata<enumeration>.kv -> $k, $v {
        $enum-names.push: $k;
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      $c ~= $!mod.generate-enumerations-code($enum-names);
    }

    when 'bitfield' {
      my Array $bitfield-names = [];
      for $!filedata<bitfield>.kv -> $k, $v {
        $bitfield-names.push: $k;
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
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
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      my Str $package-name = S/ \d+ $// with $*gnome-package.Str;
      $*work-data<sub-prefix> = $package-name.lc ~ '_';

      my Hash $hms = $!mod.get-standalone-functions($function-names);
      $function-hash = $!mod.generate-functions($hms);
    }

    when 'alias' {
      
    }
  }

  if ?$c and ?$class-name and ?$filename {
    my Str $code = qq:to/RAKUMOD/;
      #TL:1:$*work-data<raku-class-name>:
      # Command to generate: $*command-line
      use v6;
      RAKUMOD

    $code ~= $!mod.set-unit-for-file( $class-name, $has-functions);
    $code ~= $c ~ "\n";

    if $has-functions {
      $code ~= qq:to/RAKUMOD/;

      {$!grd.pod-header('BUILD variables')}
      # Define helper
      has Gnome::N::GnomeRoutineCaller \$!routine-caller;

      {$!grd.pod-header('BUILD submethod')}
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

    $code = $!mod.substitute-MODULE-IMPORTS($code);

    note "Save types module in ", $filename.IO.basename;
    $filename.IO.spurt($code);
  }
}
#`}}





#-------------------------------------------------------------------------------
# Fill the Hash $!filedata with data from a repo-object-map.yaml where the
# 'source-filename' field of every object must match $filename. The data is
# reordered to have its type as its toplevel key.
method !get-data-from-filename ( ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  my Hash $h := $*object-maps{$package};
  $!filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<source-filename>:exists
                and $v<source-filename> eq $!filename;

    # Reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}



=finish
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

    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    when 'class' {
      for $!filedata<class>.keys -> $class-name {
        $*gnome-class = $!filedata<class>{$class-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        say "\nGenerate Raku class ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Class');
        my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
        $raku-module.generate-code if $*generate-code;
        $raku-module.generate-test if $*generate-test;
        $raku-module.generate-doc if $*generate-doc;
      }
    }

    when 'interface' {
     for $!filedata<interface>.keys -> $interface-name {
        $*gnome-class = $!filedata<interface>{$interface-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        say "\nGenerate Raku role ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Interface');
        my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;
        $raku-module.generate-code if $*generate-code;
        $raku-module.generate-test if $*generate-test;
        $raku-module.generate-doc if $*generate-doc;  
      }
    }

    when 'record' {
      for $!filedata<record>.keys -> $record-name {
        $*gnome-class = $record-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        $!mod.generate-structure(
          |$!mod.init-xpath( 'record', 'gir-record-file')
        );

        say "\nGenerate Raku record from ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Record');
        my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
        $raku-module.generate-code if $*generate-code;
        $raku-module.generate-test if $*generate-test;
        $raku-module.generate-doc if $*generate-doc;
      }
    }

    when 'union' {
      for $!filedata<union>.keys -> $union-name {
        $*gnome-class = $union-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        $!mod.generate-union(
          |$!mod.init-xpath( 'union', 'gir-union-file')
        );

        say "\nGenerate Raku union from ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Union');
        my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
        $raku-module.generate-code if $*generate-code;
        $raku-module.generate-test if $*generate-test;
        $raku-module.generate-doc if $*generate-doc;
      }
    }
  }


  my Gnome::SourceSkimTool::Prepare $t-prep .= new;
  for $!filedata.keys {
    # -> $type-name

    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    # Only for documentation
    when 'docsection' { }

    when 'constant' {
      my @constants = ();
      for $!filedata<constant>.kv -> $k, $v {
        my Str $name = $t-prep.drop-prefix( $k, :constant);
        @constants.push: ( $name, $v<constant-type>, $v<constant-value>);
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      $c ~= $!mod.generate-constants(@constants);
    }

    when 'enumeration' {
      my Array $enum-names = [];
      for $!filedata<enumeration>.kv -> $k, $v {
        $enum-names.push: $k;
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      $c ~= $!mod.generate-enumerations-code($enum-names);
    }

    when 'bitfield' {
      my Array $bitfield-names = [];
      for $!filedata<bitfield>.kv -> $k, $v {
        $bitfield-names.push: $k;
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
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
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      my Str $package-name = S/ \d+ $// with $*gnome-package.Str;
      $*work-data<sub-prefix> = $package-name.lc ~ '_';

      my Hash $hms = $!mod.get-standalone-functions($function-names);
      $function-hash = $!mod.generate-functions($hms);
    }

    when 'alias' {
      
    }
  }

#TL:1:$*work-data<raku-class-name>:
  if ?$c and ?$class-name and ?$filename {
    my Str $code = qq:to/RAKUMOD/;
      # Command to generate: $*command-line
      use v6;
      RAKUMOD

    $code ~= $!mod.set-unit-for-file( $class-name, $has-functions);
    $code ~= $c ~ "\n";

    if $has-functions {
      $code ~= qq:to/RAKUMOD/;

      {$!grd.pod-header('BUILD variables')}
      # Define helper
      has Gnome::N::GnomeRoutineCaller \$!routine-caller;

      {$!grd.pod-header('BUILD submethod')}
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

    $code = $!mod.substitute-MODULE-IMPORTS($code);

    note "Save types module in ", $filename.IO.basename;
    $filename.IO.spurt($code);
  }
}

#-------------------------------------------------------------------------------
# Fill the Hash $!filedata with data from a repo-object-map.yaml where the
# 'source-filename' field of every object must match $filename. The data is
# reordered to have its type as its toplevel key.
method !get-data-from-filename ( ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  my Hash $h := $*object-maps{$package};
  $!filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<source-filename>:exists
                and $v<source-filename> eq $!filename;

    # Reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}

