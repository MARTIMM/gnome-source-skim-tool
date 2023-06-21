
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Class:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!grd .= new;
  $!sas .= new;

  # load data for this module
  note "Load module data from $*work-data<gir-class-file>";
  $!xpath .= new(:file($*work-data<gir-class-file>));

  $!mod .= new(:$!xpath);
}

#-------------------------------------------------------------------------------
method generate-raku-module-code ( ) {

  my XML::Element $element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$element;

  my Str $code = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:
    use v6;
    RAKUMOD

  note "Set class unit" if $*verbose;
  $code ~= $!mod.set-unit($element);

  note "Generate enumerations and bitmasks";
  $code ~= $!mod.generate-enumerations-code;
  $code ~= $!mod.generate-bitfield-code;

  # Make a BUILD submethod
  note "Generate BUILD" if $*verbose;
  $code ~= $!mod.make-build-submethod( $element, $!xpath);

  $code ~= $!mod.generate-callables( $element, $!xpath);


  note "Set modules to import";
  my $import = '';
  for @$*external-modules -> $m {
    if $m ~~ m/ [ NativeCall || 'Gnome::N::' ] / {
       $import ~= "use $m;\n";
    }

    else {

#NOTE temporary use existing modules
#      $import ~= "use $m\:api\('gir'\);\n";
      $import ~= "use $m;\n";
    }
  }

  $code ~~ s/__MODULE__IMPORTS__/$import/;


  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($code);
}

#-------------------------------------------------------------------------------
method generate-raku-module-doc ( ) {

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
method generate-raku-module-test ( ) {

  my XML::Element $element = $!xpath.find('//class');
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  my Str $test-variable = '$' ~ $*gnome-class.lc;
  my $module-test-doc = qq:to/EOTEST/;
    use v6;
    use NativeCall;
    use Test;

    use $*work-data<raku-class-name>:api('gir');

    use Gnome::N::GlibToRakuTypes;
    use Gnome::N::N-GObject;
    #use Gnome::N::X;
    #Gnome::N::debug(:on);

    {HLSEPARATOR}
    my $*work-data<raku-class-name> $test-variable;
    
    {HLSEPARATOR}
    subtest 'ISA test', \{
      $test-variable .= new;
      isa-ok $test-variable, $*work-data<raku-class-name>, '.new\()';
    \}

    {HLSEPARATOR}
    # set environment variable 'raku-test-all' if rest must be tested too.
    unless \%*ENV<raku_test_all>:exists \{
      done-testing;
      exit;
    \}

    EOTEST

    # check if class is inheritable
    if $h<inheritable> {
      $module-test-doc ~= qq:to/EOTEST/;
      {HLSEPARATOR}
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

    $module-test-doc ~= qq:to/EOTEST/;

    {HLSEPARATOR}
    done-testing;

    =finish


    {HLSEPARATOR}
    subtest 'Manipulations', \{
    \}

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

  note "Save module test";
  $*work-data<raku-module-test-file>.IO.spurt($module-test-doc);
}
