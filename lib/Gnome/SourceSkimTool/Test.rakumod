
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
method set-unit ( Str $class-name --> Str ) {

  my Str $code = qq:to/RAKUMOD/;
    # Command to generate: $*command-line

    #TL:1:$class-name:
    {$!grd.pod-header('Module Imports');}
    __MODULE__IMPORTS__
    RAKUMOD

  $!mod.add-import('Test');

  $code
}

#-------------------------------------------------------------------------------
method generate-init-tests (
  Str $test-variable, Str $init-test-type, Hash $hcs --> Str
) {

  my Str $code = qq:to/EOTEST/;
    {$!grd.pod-header('Test init')}
    #Gnome::N::debug(:on);
    my $*work-data<raku-class-name> $test-variable;

    {$!grd.pod-header($init-test-type)}
    subtest 'ISA test', \{
    EOTEST
  
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
  $code
}

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
      $code ~= qq:to/EOENUM/;
          #TE:1:$enum-item
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
#    my Str $package = $*gnome-package.Str;
#    $package ~~ s/ \d+ $//;
#    $name ~~ s/^ $package //;
note "$?LINE $bitfield-name, $name";
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
      $code ~= qq:to/EOBFIELD/;
          #TE:1:$bitfield-item
          is $bitfield-item.value, $bitfield-value, 'bitfield $bitfield-item = $bitfield-value';

        EOBFIELD
    }

#      # Only test a few entries
#      last if $member-count > 3;

#    $code ~= @l.join(', ') ~ "\n\);\n\n";

    $code ~= "};\n\n";
  }
#note "$?LINE $code";
#exit;
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
  for @constants -> $constant {
#note "$?LINE ", $constant.gist;
#    my Str $name = $constant-name;
#    my Str $package = $*gnome-package.Str;
#    $package ~~ s/ \d+ $//;
#    $name ~~ s/^ $package //;

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
      #TE:1:$constant[0]
      is $constant[0], $value, "constant $constant[0] = $value";

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

