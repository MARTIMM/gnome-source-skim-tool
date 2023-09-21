
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
  Str $test-variable, Str $init-test-type, Hash $hcs, Str :$test-class --> Str
) {

  my Str $code = qq:to/EOTEST/;
    {$!grd.pod-header('Test preparation')}
    #Gnome::N::debug(:on);
    my { ?$test-class ?? $test-class !! $*work-data<raku-class-name> } $test-variable;

    {$!grd.pod-header($init-test-type)}
    subtest 'ISA test', \{
    __DECL_VARS__

    #`\{\{
    EOTEST

  #| variables used in tests
  my Hash $decl-vars = %();

#  my Hash $hcs = $!mod.get-methods( $element, $xpath, :user-side);
  my Str $symbol-prefix = $*work-data<sub-prefix>;
#note "$?LINE $hcs.gist()";

  # Use of .reverse() to get the set*() functions before the get*() functions
  for $hcs.keys.sort -> $function-name {
    $code ~= self.make-function-test(
      $hcs, $function-name, $test-variable, $decl-vars, :!ismethod
    );

#`{{
  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    my Bool $simple-func-new = !$curr-function<parameters>;
    my $option-name = $curr-function<option-name>;
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
}}

  }

  $code ~= "\}\}\n\};\n\n";

  # Write out the gathered variables and make declarations
  my Str $dstr = '';
  for $decl-vars.kv -> $name, $type is copy {
    if $type ~~ /^ GEnum / {
      $type ~~ s/^ <-[:]>+ ':' //;
    }

    elsif $type ~~ /^ GFlag/ {
      $type = 'UInt';
    }

    $dstr ~= "    my $type \$$name;\n";
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
  my Str $symbol-prefix = $*work-data<sub-prefix>;
  my Str $hash-fname = $function-name;
  $hash-fname ~~ s/^ $symbol-prefix //;
  $hash-fname ~~ s:g/ '_' /-/;
  my Bool $isnew = ($hash-fname ~~ m/^ new /).Bool;

  my Bool $first-param = True;
  my Str $test-type = '';
  my Str $code = '';

  # Parameters used in call
  my Str $par-list = '';

  # Assignments before call
  my Str $assign-list = '';

  for @parameters -> $parameter {
    # If this is a method, the first parameters is the instance which
    # is provided by this object
    if $ismethod and $first-param {
      $first-param = False;
      next;
    }

    # Assume a compare test
    $test-type = 'is';
    $decl-vars{$parameter<name>} = $parameter<raku-type>; # side effect
    $assign-list ~= "  " unless $isnew; # no extra indent for new tests
    $assign-list ~= "  \$$parameter<name> = ";

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
      when /^ GEnum / { $assign-list ~= "…;  # a $rtype enum\n"; }
      when /^ GEnum / { $assign-list ~= "…;  # a $rtype mask\n"; }
      default {
        note "Test variable \$$parameter<name> has type $rtype";
        $assign-list ~= "'…';\n";
      }
    }
    $par-list ~= ", \$$parameter<name>";
  }

  # Remove first comma
  $par-list ~~ s/^ . //;

  if $isnew {
    $code ~= qq:to/EOTEST/;
      #TB:0:$hash-fname\(\)
    $assign-list.chop()
      $test-variable .= $hash-fname\($par-list\);
      ok .is-valid, '.$hash-fname\($par-list\)';

    EOTEST
  }

  elsif $hash-fname ~~ m/^ set / {
    $code ~= qq:to/EOTEST/;
        #TB:0:$hash-fname\(\)
    $assign-list.chop()
        .$hash-fname\($par-list\);
    EOTEST

    # Also test set-*() when there is one. Need to keep an eye on the parameter
    # list. It could be more than one. If so the '$test-type' test will fail
    my Str $fn = $function-name;
    $fn ~~ s/^ set /get/;
    if $hcs{$fn}:exists {
      my Str $get-hash-fname = $hash-fname;
      $get-hash-fname ~~ s/^ set /get/;
      $code ~= qq:to/EOTEST/;
          #TB:0:$get-hash-fname\(\)
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
    # Only test get-*() when they are not tested above
    my Str $fn = $function-name;
    $fn ~~ s/^ get /set/;
    if $hcs{$fn}:!exists {
      $code ~= qq:to/EOTEST/;
          #TB:0:$hash-fname\(\)
          $test-type .$hash-fname\($par-list\), '…', '.$hash-fname\(\)';

      EOTEST
    }
  }

  else {
    $code ~= qq:to/EOTEST/;
        #TB:0:$hash-fname\(\)
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
    subtest 'Method tests', \{
      with $test-variable \{
    __DECL_VARS__

    #`\{\{
    EOTEST

  #| variables used in tests
  my Hash $decl-vars = %();

#  my Hash $hcs = $!mod.get-methods( $element, $xpath, :user-side);
  my Str $symbol-prefix = $*work-data<sub-prefix>;
#note "$?LINE $hcs.gist()";

  # Use of .reverse() to get the set*() functions before the get*() functions
  for $hcs.keys.sort.reverse -> $function-name {
    $code ~= self.make-function-test(
      $hcs, $function-name, $test-variable, $decl-vars, :$ismethod
    );
#`{{
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
    my Str $test-type;

    for @($curr-function<parameters>) -> $parameter {
      # Skip first argument, is solved by class
      if $first-param {
        $first-param = False;
        next;
      }

      $test-type = 'is';
      $decl-vars{$parameter<name>} = $parameter<raku-type>;
      $assign-list ~= "    \$$parameter<name> = ";
      my Str $rtype = $parameter<raku-type>;
      $rtype ~~ s/'()'//;
      with $rtype {
        when 'Int' { $assign-list ~= "-42;\n"; }
        when 'UInt' { $assign-list ~= "42;\n"; }
        when 'Str' { $assign-list ~= "'text';\n"; }
        when 'Num' { $assign-list ~= "42.42;\n"; $test-type ~= '-approx'; }
        when 'Bool' { $assign-list ~= "True;\n"; }
        when 'N-GObject' { $assign-list ~= "…;  # a native object\n"; }
        when /^ GEnum / { $assign-list ~= "…;  # a $rtype enum\n"; }
        when /^ GEnum / { $assign-list ~= "…;  # a $rtype mask\n"; }
        default {
          note "Test variable \$$parameter<name> has type $rtype";
          $assign-list ~= "'…';\n";
        }
      }
      $par-list ~= ", \$$parameter<name>";
    }

    # Remove first comma and first space
    $par-list ~~ s/^ . //;

    if $hash-fname ~~ m/^ set / {
      $code ~= qq:to/EOTEST/;
          #TB:0:$hash-fname\(\)
      $assign-list.chop()
          lives-ok \{ .$hash-fname\($par-list\); \}, '.$hash-fname\(\)';
      EOTEST

      # Also test set-*() when there is one
      my Str $fn = $function-name;
      $fn ~~ s/^ set /get/;
      if $hcs{$fn}:exists {
        $hash-fname ~~ s/^ set /get/;
        $code ~= qq:to/EOTEST/;
            #TB:0:$hash-fname\(\)
            $test-type .$hash-fname\(\), '…', '.$hash-fname\(\)';

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
            $test-type .$hash-fname\($par-list\), '…', '.$hash-fname\(\)';

        EOTEST
      }
    }

    else {
      $code ~= qq:to/EOTEST/;
          #TB:0:$hash-fname\(\)
          ok .$hash-fname\($par-list\), '.$hash-fname\(\)';

      EOTEST
    }
}}

  }

  $code ~= "\}\}\n  \}\n\};\n\n";

  # Write out the gathered variables and make declarations
  my Str $dstr = '';
  my Str $temp-inhibit = '';
  for $decl-vars.kv -> $name, $type is copy {
    if $type ~~ /^ GEnum / {
      $type ~~ s/^ <-[:]>+ ':' //;
    }

    elsif $type ~~ /^ GFlag/ {
      $type = 'UInt';
    }

    #TODOinhibit callback signatures
    elsif $type ~~ /^ ':('/ {
      $temp-inhibit = '#';
    }

    $dstr ~= "$temp-inhibit    my $type \$$name;\n";
    $temp-inhibit = '';
  }

  $code ~~ s/'__DECL_VARS__'/$dstr/;

  $code
}

#`{{
#-------------------------------------------------------------------------------
method generate-function-tests ( Str $class-name, Hash $hcs --> Str ) {

  return '' unless ?$hcs;

  my Str $symbol-prefix = $*work-data<sub-prefix>;

  # Get all functions from the Hash
  my Str $code = qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR( 'Standalone Functions', 2);}
    subtest 'functions', \{
      my $class-name \$cname .= new;

    EOSUB

  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

     # Get method name, drop the prefix and substitute '_'
    my Str $hash-fname = $function-name;
    $hash-fname ~~ s/^ $symbol-prefix //;
    $hash-fname ~~ s:g/ '_' /-/;

    # Get parameter lists
    my Str (
      $par-list #, $call-list, #$own, $raku-list, $returns-doc, $items-doc, 
    ) =  '';
    my @rv-list = ();

    for @($curr-function<parameters>) -> $parameter {

#      self!get-types(
#        $parameter, #$raku-list, 
#        $call-list, #$items-doc,
#        @rv-list #, $returns-doc
#      );

      # Get a list of types for the arguments
      $par-list ~= ", $parameter<raku-type>";
    }

    # Remove first comma and space when there is only one parameter
    $par-list ~~ s/^ . //;
    $par-list ~~ s/^ . // unless $par-list ~~ m/ \, /;
    $par-list = ?$par-list
              ?? [~] ' :parameters([', $par-list, ']),'
              !! '';


    # Return type
    # Enumerations and bitfields are returned as GEnum:Name and GFlag:Name
    my Str $returns;
    my $xtype = $curr-function<return-raku-type>;
    my ( $rnt0, $rnt1) = $xtype.split(':');
    if ?$rnt1 {
      $returns = " :returns\($rnt0\), :type-name\($rnt1\),";
    }

    elsif ?$rnt0 and $xtype ne 'void' {
      $returns = " :returns\($rnt0\),";
    }

    else {
      $returns = '';
    }

    if ?$returns {
      $code ~= Q:qq:to/EOSUB/;
          #TF:0:$hash-fname
          #my \$return-value = \$cname.$hash-fname\($par-list\);
          #is \$return-value, …, 'function .$hash-fname\(\)-> \$return-value';

        EOSUB
    }

    else {
      $code ~= Q:qq:to/EOSUB/;
          #TF:0:$hash-fname
          lives-ok \{
            #\$cname.$hash-fname\($par-list\);
          \}, 'function .$hash-fname\(\)';

        EOSUB
    }

#note "$?LINE $hash-fname, {$returns//'-'}, {$par-list//'-'}";
#TM:0:$hash-fname
#    $code ~= [~] '  ', $hash-fname, ' => %( :type(Function),',
#                 $returns, $par-list, "),\n";

  }

  $code ~= "};\n\n";
  $code
}
}}

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
    my Str $prefix = $*work-data<name-prefix>;
    $name ~~ s:i/^ $prefix <[-_]>? //;

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