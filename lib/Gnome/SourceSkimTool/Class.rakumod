
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Class:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;

  # load data for this module
  note "Load module data from $*work-data<gir-class-file>" if $*verbose;
  $!xpath .= new(:file($*work-data<gir-class-file>));

  $!mod .= new;
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6;
    RAKUMOD

  my $callables = $!mod.generate-callables( $element, $!xpath);
  note "Set class unit" if $*verbose;
  $code ~= $!mod.set-unit( $element, :callables(?$callables));

  if ?$callables {
    # Make a BUILD submethod
    note "Generate BUILD" if $*verbose;
    $code ~= $!mod.make-build-submethod( $element, $!xpath);
    $code ~= $callables;
  }

  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = "$*work-data<result-path>$*gnome-class.rakumod";
  note "Save class module in ", $fname.IO.basename;
  $fname.IO.spurt($code);
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $doc = qq:to/RAKUMOD/;
    #TL:1:pod doc of $*work-data<raku-class-name>:
    use v6;

    {$!grd.pod-header('Class Description')}
    RAKUMOD

  note "Document module" if $*verbose;
  $doc ~= $!grd.get-description( $element, $!xpath);

  note "Document enumerations and bitmasks";
  #$doc ~= $!mod.generate-enumerations-doc;

  note "Document BUILD submethod" if $*verbose;
  my Hash $hcs = $!mod.get-constructors( $element, $!xpath);
  $doc ~= $!grd.make-build-doc( $element, $hcs);

  note "Document methods" if $*verbose;
  $doc ~= $!grd.document-methods( $element, $!xpath);

  note "Document signals" if $*verbose;
  my Hash $sig-info = $!grd.document-signals( $element, $!xpath);
  $doc ~= $sig-info<doc>;

  note "Generate module properties doc" if $*verbose;  
  $doc ~= $!grd.document-properties( $element, $!xpath);

  note "Save pod doc";
  $*work-data<raku-module-doc-file>.IO.spurt($doc);
}

#-------------------------------------------------------------------------------
method generate-test ( ) {

  my XML::Element $element = $!xpath.find('//class');
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!mod.search-name($ctype);

  my Str $test-variable = '$' ~ $*gnome-class.lc;

#NOTE needed? use NativeCall;
  $!mod.add-import($*work-data<raku-class-name>);
  my $code = qq:to/EOTEST/;
    use v6;

    {$!grd.pod-header('Module Imports')}
    #TL:1:$*work-data<raku-class-name>
    __MODULE__IMPORTS__

    {$!grd.pod-header('Test init')}
    #Gnome::N::debug(:on);
    my $*work-data<raku-class-name> $test-variable;
    EOTEST

  $code ~= qq:to/EOTEST/;
    {$!grd.pod-header('Class init tests')}
    subtest 'ISA test', \{
    EOTEST

  my Hash $hcs = $!mod.get-constructors( $element, $!xpath, :user-side);
note "$?LINE $hcs.gist()";
#  # Use of .reverse() to get the set*() functions before the get*() functions
#  for $hcs.keys.sort.reverse -> $function-name {
  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    my Bool $simple-func-new = !$curr-function<parameters>;
    my $option-name = $hcs{$function-name}<option-name>;
    if !$simple-func-new {
      my Str $par-list = '';
      my Bool $first = True;
      for @($curr-function<parameters>) -> $parameter {
        if $first {
          $par-list ~= ", :$curr-function<option-name>\(…\)";
          $first = False;
        }

        else {
          $par-list ~= ", :$parameter<name>\(…\)";
        }
      }
    
      # Remove first comma and first space
      $par-list ~~ s/^ . //;

      $code ~= qq:to/EOTEST/;
          #TB:1:new\($par-list\)
          #$test-variable .= new\($par-list\);
          #ok $test-variable.is-valid, '.new\($par-list\)';

        EOTEST
    }

    else {
      $code ~= qq:to/EOTEST/;
          #TB:1:new\(\)
          $test-variable .= new;
          ok $test-variable.is-valid, '.new\(\)';

        EOTEST
    }
  }

  $code ~= "};\n\n";

  $code ~= qq:to/EOTEST/;
    {HLSEPARATOR}
    {HLSEPARATOR}
    {HLSEPARATOR}
    # set environment variable 'raku-test-all' if rest must be tested too.
    unless \%*ENV<raku_test_all>:exists \{
      done-testing;
      exit;
    \}

    EOTEST

  # check if class is inheritable
  if $h<inheritable> {
    $code ~= qq:to/EOTEST/;
    {$!grd.pod-header('Inheritance test')}
    #TB:1:Inheriting
    subtest 'Inherit $*work-data<raku-class-name>', \{
      class MyClass is $*work-data<raku-class-name> \{
        method new \( |c ) \{
          self.bless\( :$*work-data<gnome-name>, |c);
        }

        submethod BUILD \( *\%options ) \{

        }
      }

      my MyClass $test-variable .= new;
      isa-ok $test-variable, $*work-data<raku-class-name>, 'MyClass.new\()';
    }
    EOTEST
  }

  $code ~= qq:to/EOTEST/;

    {HLSEPARATOR}
    done-testing;

    =finish
    EOTEST


  # Set up tests for the methods
  $code ~= qq:to/EOTEST/;
    {HLSEPARATOR}
    subtest 'Method tests', \{
      with $test-variable \{
    __DECL_VARS__
    EOTEST

  #| variables used in tests
  my Hash $decl-vars = %();

  my Str $symbol-prefix = $*work-data<sub-prefix>;
  $hcs = $!mod.get-methods( $element, $!xpath, :user-side);
note "$?LINE $hcs.gist()";
  # Use of .reverse() to get the set*() functions before the get*() functions
  for $hcs.keys.sort.reverse -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    # get method name, drop the prefix
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $symbol-prefix //;
    $hash-fname ~~ s:g/ '_' /-/;

    my Bool $first-param = True;

    #| parameters used in call
    my Str $par-list = '';

    #| assignments before call
    my Str $assign-list = '';

    for @($curr-function<parameters>) -> $parameter {
      # Skip first argument, is solved by class
      if $first-param {
        $first-param = False;
        next;
      }

      $decl-vars{$parameter<name>} = $parameter<raku-type>;
      $assign-list ~= "  \$$parameter<name> = ";
      my Str $rtype = $parameter<raku-type>;
      $rtype ~~ s/'()'//;
      with $rtype {
        when 'Int' { $assign-list ~= "-42;\n"; }
        when 'UInt' { $assign-list ~= "42;\n"; }
        when 'Str' { $assign-list ~= "'text';\n"; }
        when 'Num' { $assign-list ~= "42.42;\n"; }
        when 'Bool' { $assign-list ~= "True;\n"; }
        when 'N-GObject' { $assign-list ~= "…;  # a native object\n"; }
        when /^ GEnum / { $assign-list ~= "…;  # a $rtype enum\n"; }
        when /^ GEnum / { $assign-list ~= "…;  # a $rtype mask\n"; }
#        when '' { $assign-list ~= ;\n"; }
        default {
          note "Test variable \$$parameter<name> has type $rtype";
          $assign-list ~= "'…';\n";
        }
      }
      $par-list ~= ", \$$parameter<name>";
    }

    # Remove first comma and first space
    $par-list ~~ s/^ . //;

    # Remove last return
    #$assign-list.chop;

    if $hash-fname ~~ m/^ set / {
      $code ~= qq:to/EOTEST/;
          #TB:0:$hash-fname\(\)
        $assign-list.chop()
          lives-ok \{
            .$hash-fname\($par-list\);
          \}, '.$hash-fname\(\)';
      EOTEST
      
      # Also test set-*() when there is one
      my Str $fn = $function-name;
      $fn ~~ s/^ set /get/;
      if $hcs{$fn}:exists {
        $hash-fname ~~ s/^ set /get/;
        $code ~= qq:to/EOTEST/;
            #TB:0:$hash-fname\(\)
            is .$hash-fname\(\), '…', '.$hash-fname\(\)';

        EOTEST
      }
    }

    elsif $hash-fname ~~ m/^ get / {
      # Only test get-*() when they are not tested above
      my Str $fn = $function-name;
      $fn ~~ s/^ get /set/;
      if $hcs{$fn}:!exists {
        $code ~= qq:to/EOTEST/;
            #TB:0:$hash-fname\(\)
            is .$hash-fname\($par-list\), '…', '.$hash-fname\(\)';

        EOTEST
      }
    }

    else {
      $code ~= qq:to/EOTEST/;
          #TB:0:$hash-fname\(\)
          ok .$hash-fname\($par-list\), …, '.$hash-fname\(\)';

      EOTEST
    }
  }

  $code ~= "  \}\n\};\n\n";

  # Write out the gathered variables and make declarations
  my Str $dstr = '';
  for $decl-vars.kv -> $name, $type is copy {
    if $type ~~ /^ GEnum / {
      $type ~~ s/^ <-[:]>+ ':' //;
    }

    elsif $type ~~ /^ GFlag/ {
      $type = 'UInt';
    }

    $type ~~ s/ '()' // unless $type ~~ m/ 'N-GObject' /;
    $dstr ~= "    my $type \$$name;\n";
  }

  $code ~~ s/'__DECL_VARS__'/$dstr/;

  $code ~= qq:to/EOTEST/;
    {HLSEPARATOR}
    subtest 'Signals …', \{
      use Gnome::Gtk3::Main;
      use Gnome::N::GlibToRakuTypes;

      my Gnome::Gtk3::Main \$main .= new;

      class SignalHandlers \{
        has Bool \$!signal-processed = False;

        method … \(
          'any-args',
          $*work-data<raku-class-name>\(\) :\$_native-object, gulong :\$_handler-id
          # --> …
        ) \{

          isa-ok \$_native-object, $*work-data<raku-class-name>;
          \$!signal-processed = True;
        }

        method signal-emitter \( $*work-data<raku-class-name> :\$_widget --> Str ) \{

          while \$main.gtk-events-pending\() \{ \$main.iteration-do\(False); }

          \$_widget.emit-by-name\(
            'signal',
          #  'any-args',
          #  :return-type(int32),
          #  :parameters([int32,])
          );
          is \$!signal-processed, True, '\'…\' signal processed';

          while \$main.gtk-events-pending\() \{ \$main.iteration-do\(False); }

          #\$!signal-processed = False;
          #\$_widget.emit-by-name\(
          #  'signal',
          #  'any-args',
          #  :return-type\(int32),
          #  :parameters\(\[int32,])
          #);
          #is \$!signal-processed, True, '\'…\' signal processed';

          while \$main.gtk-events-pending\() \{ \$main.iteration-do\(False); }
          sleep(0.4);
          \$main.gtk-main-quit;

          'done'
        }
      }

      my $*work-data<raku-class-name> $test-variable .= new;

      #my Gnome::Gtk3::Window \$w .= new;
      #\$w.add(\$m);

      my SignalHandlers \$sh .= new;
      $test-variable.register-signal\( \$sh, 'method', 'signal');

      my Promise \$p = \$i.start-thread\(
        \$sh, 'signal-emitter',
        # :!new-context,
        # :start-time\(now + 1)
      );

      is \$main.gtk-main-level, 0, "loop level 0";
      \$main.gtk-main;
      #is \$main.gtk-main-level, 0, "loop level is 0 again";

      is \$p.result, 'done', 'emitter finished';
    }

    EOTEST

  $code = $!mod.substitute-MODULE-IMPORTS($code);

  my Str $fname = $*work-data<result-path>;
  $fname ~~ s@ '/lib/' @/t/@;
  mkdir $fname, 0o750 unless $fname.IO ~~ :e;
  $fname ~= $*gnome-class ~ '.rakutest';
  note "Save tests in ", $fname.IO.basename;
  $fname.IO.spurt($code);
}
