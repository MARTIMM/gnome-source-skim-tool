use v6.d;

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;

use XML;
use XML::XPath;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Test:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;

has Str $!filename;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {

  $!grd .= new;
  $!mod .= new;
}

#-------------------------------------------------------------------------------
# This setup is for more simple structures like records, functions,
# enumerations, etc. There is no need for inheritence, BUILD, signals or
# properties.
method prepare-test ( Str $class-name --> Str ) {

  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line
    use v6.d;

    #TL:1:$class-name:
    {$!grd.pod-header('Module Imports');}
    __MODULE__IMPORTS__
    RAKUMOD

  $!mod.add-import('NativeCall');
  $!mod.add-import('Test');

  $code
}

#-------------------------------------------------------------------------------
method generate-init-tests (
  Str $test-variable, Str $init-test-type, Hash $hcs,
  Str :$test-class, Str :$struct-class
  --> Str
) {
  my Str $test-type =
    $test-class ?? $test-class !! $*work-data<raku-class-name>;
  
  # The record and union classes are whithout a package name and are exported
  $test-type ~~ s/^ .*? 'N-' /N-/ if $test-type ~~ / 'N-' /;

  my Str $code = qq:to/EOTEST/;
    {$!grd.pod-header('Test preparation')}
    #Gnome::N::debug(:on);
    my $test-type $test-variable;

    {$!grd.pod-header($init-test-type)}
    subtest 'ISA test', \{
      given $test-variable \{
    __DECL_VARS__
    #`\{\{
    EOTEST

  # Variables used in tests
  my Hash $decl-vars = %();

#  my Hash $hcs = $!mod.get-methods( $element, $xpath, :user-side);
  my Str $symbol-prefix = $*work-data<sub-prefix>;
#note "$?LINE $hcs.gist()";

  for $hcs.keys.sort -> $function-name {
    $code ~= self.make-function-test(
      $hcs, $function-name, $test-variable, $decl-vars, :!ismethod
    );
  }

  $code ~= "\}\}\n  \}\n\};\n\n";

  # Write out the gathered variables and make declarations
  my Str $dstr = '';
  for $decl-vars.kv -> $name, $type is copy {
    # Skip when both name and type are unknown. It means variable list.
    next if $name ~~ / '…' || '...' / and $type ~~ / '…' || '...' /;

#    $dstr ~= "    my $type \$$name;\n";
    # Generate the variable declarations. Special code for callback routines
    if $type ~~ /^ sub / {
      $dstr ~= "    $type \{\}\n";
    }

    else {
      $dstr ~= "    my $type \$$name;\n";
    }
  }

  $code ~~ s/'__DECL_VARS__'/$dstr/;

  $code
}

#-------------------------------------------------------------------------------
# Create a test for each function. $decl-vars is changed as a side effect.
method make-function-test (
  Hash $hcs, Str $function-name, Str $test-variable, Hash $decl-vars, 
  Bool :$ismethod = True
  --> Str
) {
  my @parameters = @($hcs{$function-name}<parameters>);
#note "$?LINE $function-name, $test-variable, $ismethod";

  # Get method name and drop the prefix
#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $hash-fname = $function-name;
  return '' if $hash-fname ~~ / '_' $/;
#  $hash-fname ~~ s/^ $symbol-prefix //;
#  $hash-fname ~~ s:g/ '_' /-/;

  my Bool $isnew = ($hash-fname ~~ m/^ new /).Bool;

  my Bool $first-param = True;
  my Str $test-type = '';
  my Str $code = '';

  # Parameters used in call
  my Str $par-list = '';

  # Assignments before call
  my Str $assign-list = '';

  for @parameters -> $parameter {
    # Sometimes a var name ends in an '_' char. This becomes a '-' which is
    # not a proper name in raku, so correct it.
    my Str $parameter-name = $parameter<name>;
    $parameter-name ~~ s/ '-' $//;

    # skip when both are unknown. it means variable list
    next if $parameter-name ~~ / '…' / and $parameter<raku-type> ~~ / '…' /;

    # If this is a method, the first parameters is the instance which
    # is provided by this object
    if $ismethod and $first-param {
      $first-param = False;
      next;
    }

    # Assume a compare test
    $test-type = 'is';

    # Store type and name for declarations. Changing $decl-vars
    # is a side effect, var is declared and used elsewhere.
    if $parameter<raku-type> ~~ /^ ':(' / {
      $decl-vars{$parameter-name} = [~]
        'sub ', $parameter-name, ' ', $parameter<raku-type>;
      $decl-vars{$parameter-name} ~~ s/ ':(' /(/;
note "$?LINE $parameter-name, $decl-vars{$parameter-name}";
    }

    elsif $parameter<raku-type> ~~ / ':' / {
      my ( $type, $enum ) = $parameter<raku-type>.split(':');
      $decl-vars{$parameter-name} = $enum;
    }

    else {
      $decl-vars{$parameter-name} = $parameter<raku-type>;
    }

#    $assign-list ~= "  " unless $isnew; # no extra indent for new tests
    $assign-list ~= "    \$$parameter-name = ";

    # Get parameter type
    my Str $rtype = $parameter<raku-type>;
    $rtype ~~ s/'()'//;
    with $rtype {
      when 'Int' { $assign-list ~= "-42;\n"; }
      when 'UInt' { $assign-list ~= "42;\n"; }
      when 'Str' { $assign-list ~= "'text';\n"; }
      when 'Num' { $assign-list ~= "42.42;\n"; $test-type ~= '-approx'; }
      when 'Bool' { $assign-list ~= "True;\n"; }
      when 'N-GObject' { $assign-list ~= "…;  # a native object\n"; }
      when / ':' / {
        my ( $type, $enum ) = .split(':');
        $assign-list ~= "…;  # an enum or flag" if ?$enum;
      }

      default {
#        note "Test variable \$$parameter-name has type $rtype";
        $assign-list ~= "'…';\n";
      }
    }
    $par-list ~= ", \$$parameter-name";
  }

  # Remove first comma
  $par-list ~~ s/^ . //;

  if $isnew {
    if $hash-fname eq 'new' {
      my Str $gnome-name = $*work-data<gnome-name>;
      my Str $prefix = $*work-data<name-prefix>;
      $gnome-name ~~ s:i/^ $prefix //;
      $hash-fname ~= '-' ~ $gnome-name.lc;
    }

    $code ~= qq:to/EOTEST/;
        #TC:0:$hash-fname\(\)
    $assign-list.chop()
        $test-variable .= $hash-fname\($par-list\);
        ok .is-valid, '.$hash-fname\($par-list\)';

    EOTEST
  }

  elsif $hash-fname ~~ m/^ set / {
    $code ~= qq:to/EOTEST/;
        #TM:0:$hash-fname\(\)
    $assign-list.chop()
        .$hash-fname\($par-list\);
    EOTEST

    # Also test get-*() when there is one. Need to keep an eye on the parameter
    # list. It could be more than one. If so the '$test-type' test will fail
    my Str $fn = $function-name;
    $fn ~~ s/^ set /get/;
    if $hcs{$fn}:exists {
      my Str $get-hash-fname = $hash-fname;
      $get-hash-fname ~~ s/^ set /get/;
      $code ~= qq:to/EOTEST/;
          #TM:0:$get-hash-fname\(\)
          $test-type .$get-hash-fname\(\), $par-list, '.$hash-fname\(\) / .$get-hash-fname\(\)';

      EOTEST
    }
    else {
      $code ~= qq:to/EOTEST/;
          ok True, '.$hash-fname\(\)';

      EOTEST
    }
  }

  elsif $hash-fname ~~ m/^ get / {
    # Only test get-*() when they are not tested above with set-*
    my Str $fn = $function-name;
    $fn ~~ s/^ get /set/;
    if $hcs{$fn}:!exists {
      $code ~= qq:to/EOTEST/;
          #TM:0:$hash-fname\(\)
          $test-type .$hash-fname\($par-list\), '…', '.$hash-fname\(\)';

      EOTEST
    }
  }

  else {
    $code ~= qq:to/EOTEST/;
        #TM:0:$hash-fname\(\)
        ok .$hash-fname\($par-list\), '.$hash-fname\(\)';

    EOTEST
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-inheritance-tests (
  XML::Element $element, Str $test-variable --> Str
) {

  my $code = '';
#TODO rethink inheritance --> other tests
return $code;


  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!mod.search-name($ctype);
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

  $code
}

#-------------------------------------------------------------------------------
method generate-method-tests (
  Hash $hcs, Str $test-variable, Bool :$ismethod = True --> Str
) {

  # Set up tests for the methods
  my Str $code = qq:to/EOTEST/;
    {HLSEPARATOR}
    subtest '{$ismethod ?? 'Method tests' !! 'Function tests'}', \{
      with $test-variable \{
    __DECL_VARS__

    #`\{\{
    EOTEST

  # Variables used in tests
  my Hash $decl-vars = %();

  my Str $symbol-prefix = $*work-data<sub-prefix>;

#???  # Use of .reverse() to get the set*() functions before the get*() functions
  for $hcs.keys.sort -> $function-name {
    $code ~= self.make-function-test(
      $hcs, $function-name, $test-variable, $decl-vars, :$ismethod
    );
  }

  $code ~= "\}\}\n  \}\n\};\n\n";

  # Write out the gathered variables and make declarations
  my Str $dstr = '';
  for $decl-vars.kv -> $name, $type is copy {
#note "$?LINE $type $name";
    # Skip when both are unknown. It means variable list.
    next if $name ~~ / '…' / and $type ~~ / '…' /;
#`{{
    if $type ~~ /^ GEnum / {
      $type ~~ s/^ <-[:]>+ ':' //;
    }

    elsif $type ~~ /^ GFlag/ {
      $type = 'UInt';
    }
}}
    # Generate the variable declarations. Special code for callback routines
    if $type ~~ /^ sub / {
      $dstr ~= "    $type \{\}\n";
    }

    else {
      $dstr ~= "    my $type \$$name;\n";
    }
  }

  $code ~~ s/'__DECL_VARS__'/$dstr/;

  $code
}

#-------------------------------------------------------------------------------
method generate-signal-tests ( Str $test-variable --> Str ) {

  my Str $code = qq:to/EOTEST/;
    {HLSEPARATOR}
    subtest 'Signals …', \{
      use Gnome::Gtk3::Main;

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

  $code
}

#-------------------------------------------------------------------------------
method generate-enumeration-tests ( Array:D $enum-names --> Str ) {

  # Return empty string if no enums found.
  return '' unless ?$enum-names;
#note "$?LINE e names: $enum-names.gist()";

  # Open enumerations file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-enumeration.gir';
  my XML::XPath $xpath .= new(:$file);

  my Str $code = qq:to/EOENUM/;
    {HLSEPARATOR}
    {SEPARATOR('Enumerations');}
    EOENUM

  # For each of the found names
  for $enum-names.sort -> $enum-name {
    my Str $name = $enum-name;
    my Str $package = $*gnome-package.Str;
    $package ~~ s/ \d+ $//;
    if $package ~~ / Glib || GObject || Gio / {
      $package = 'G';
    }
    
    else {
      $package ~~ s/ \d+ $//;
    }

    $name ~~ s/^ $package //;

    # Get the XML element of the enum data
    my XML::Element $e = $xpath.find(
      '//enumeration[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOENUM/;
      {HLSEPARATOR}
      #TE:1:$enum-name
      subtest '$enum-name', \{
      EOENUM

    my $member-count = 0;
    my @members = $xpath.find( 'member', :start($e), :to-list);
    for @members -> $m {
      my Str $enum-item = $m.attribs<c:identifier>;
#TE:1:$enum-item
      $code ~= qq:to/EOENUM/;
          is $enum-item.value, $member-count, 'enum $enum-item = $member-count';

        EOENUM
      $member-count++;

#      # Only test a few entries
#      last if $member-count > 3;
    }

    $code ~= "};\n\n";
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-bitfield-tests ( Array:D $bitfield-names --> Str ) {

  # Return empty string if no bitfields found.
  return '' unless ?$bitfield-names;
#note "$?LINE e names: $bitfield-names.gist()";

  # Open bitfields file for xpath
  my Str $file = $*work-data<gir-module-path> ~ 'repo-bitfield.gir';
  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOBFIELD/;
    {HLSEPARATOR}
    {SEPARATOR('Bitfields');}
    EOBFIELD

  # For each of the found names
  for $bitfield-names.sort -> $bitfield-name {
    my Str $name = $bitfield-name;
    my Str $prefix = $*work-data<name-prefix>;
    $name ~~ s:i/^ $prefix //;
    my Str $package = $*gnome-package.Str;
    if $package ~~ / Glib || GObject || Gio / {
      $package = 'G';
    }
    
    else {
      $package ~~ s/ \d+ $//;
    }

    $name ~~ s/^ $package //;

#    my Str $package = $*gnome-package.Str;
#    $package ~~ s/ \d+ $//;
#    $name ~~ s/^ $package //;
#note "$?LINE $bitfield-name, $name";
    # Get the XML element of the bitfield data
    my XML::Element $e = $xpath.find(
      '//bitfield[@name="' ~ $name ~ '"]', :!to-list
    );

    $code ~= qq:to/EOBFIELD/;
      {HLSEPARATOR}
      #TE:1:$bitfield-name
      subtest '$bitfield-name', \{
      EOBFIELD

#   $code ~= "enum $bitfield-name is export \(\n  ";

#    my Str $member-name-list = '';
    my @members = $xpath.find( 'member', :start($e), :to-list);
#    my @l = ();
    for @members -> $m {
#note "$?LINE $m.attribs()<c:identifier>, $m.attribs()<value>";
#      @l.push: [~] ':', $m.attribs<c:identifier>, '(', $m.attribs<value>, ')';
      my Str $bitfield-item = $m.attribs<c:identifier>;
      my Str $bitfield-value = $m.attribs<value>;
#TE:1:$bitfield-item
      $code ~= qq:to/EOBFIELD/;
          is $bitfield-item.value, $bitfield-value, 'bitfield $bitfield-item = $bitfield-value';

        EOBFIELD
    }

#      # Only test a few entries
#      last if $member-count > 3;

#    $code ~= @l.join(', ') ~ "\n\);\n\n";

    $code ~= "};\n\n";
  }

  $code
}

#-------------------------------------------------------------------------------
method generate-constant-tests ( @constants --> Str ) {
  
  # Return empty string if no enums found.
  return '' unless ?@constants;

  # Open constants file for xpath
#  my Str $file = $*work-data<gir-module-path> ~ 'repo-constant.gir';
#  my XML::XPath $xpath .= new(:$file);

#  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $code = qq:to/EOCONST/;
    {$!grd.pod-header('Constants');}
    subtest 'constants', \{
    EOCONST

  # For each of the found names
  for @constants -> $constant is copy {
#note "$?LINE ", $constant.gist;
#    my Str $name = $constant-name;
#    my Str $package = $*gnome-package.Str;
#    $package ~~ s/ \d+ $//;
#    $name ~~ s/^ $package //;
    my Str $name = $constant[0];
#    my Str $prefix = $*work-data<name-prefix>;
#    $name ~~ s:i/^ $prefix <[-_]>? //;

    # Get the XML element of the constant data
#    my XML::Element $e = $xpath.find(
#      '//constant[@name="' ~ $constant[0] ~ '"]', :!to-list
#    );

    my Str $value = $constant[2];
    $value = "'$value'" if $constant[1] ~~ / char /;

#TE:0:$constant[0]
#      {HLSEPARATOR}

#    $code ~= "constant $constant[0] is export = $value;\n";

    $code ~= qq:to/EOCONST/;
      #TE:1:$name
      is $name, $value, "constant $name = $value";

      EOCONST

#    my Str $edoc =
#      ($xpath.find( 'doc/text()', :start($e), :!to-list) // '').Str;
#    my Str $s = self.modify-text($edoc);
#    $doc = self.cleanup($s);

#    my Str $member-name-list = '';
#    my @members = $xpath.find( 'member', :start($e), :to-list);
#    my @l = ();
#    for @members -> $m {
#      @l.push: [~] ':', $m.attribs<c:identifier>, '(', $m.attribs<value>, ')';
#    }

#    $code ~= @l.join(', ') ~ "\n\);\n";

  }
#note "$?LINE $code";
#exit;
  $code ~= "};\n\n";
}

#-------------------------------------------------------------------------------
method generate-test-separator ( --> Str ) {

  qq:to/EOTEST/;
    {HLSEPARATOR}
    {HLSEPARATOR}
    {HLSEPARATOR}
    # set environment variable 'raku-test-all' if rest must be tested too.
    unless \%*ENV<raku_test_all>:exists \{
      done-testing;
      exit;
    \}

    EOTEST
}

#-------------------------------------------------------------------------------
method generate-test-end ( --> Str ) {

  qq:to/EOTEST/;
    {HLSEPARATOR}
    done-testing;

    =finish

    EOTEST
}