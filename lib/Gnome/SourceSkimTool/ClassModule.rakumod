
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::GenerateDoc;
use Gnome::SourceSkimTool::Module;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::ClassModule:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::GenerateDoc $!grd;
has Gnome::SourceSkimTool::Module $!mod;

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
method generate-raku-module ( ) {

  my XML::Element $class-element = $!xpath.find('//class');
  die "//class not found in $*work-data<gir-class-file> for $*work-data<raku-class-name>" unless ?$class-element;

  my Str ( $doc, $code);
  my Str $module-code = '';
  my Str $module-doc = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:
    use v6;

    {$!grd.pod-header('Class Description')}
    RAKUMOD

  note "Generate module description" if $*verbose;  
  $module-doc ~= $!grd.get-description( $class-element, $!xpath);

  note "Generate module signals" if $*verbose;  
  my Hash $sig-info = $!mod.generate-signals($class-element);

  note "Set class unit" if $*verbose;
  $module-code ~= $!mod.set-unit($class-element);

  # Make a BUILD submethod
  note "Generate BUILD submethod" if $*verbose;  
  ( $doc, $code) = $!mod.generate-build( $class-element, $sig-info);
  $module-doc ~= $doc;
  $module-code ~= $code;

  note "Generate module methods" if $*verbose;  
  ( $doc, $code) = $!mod.generate-methods($class-element);

  # if there are methods, add the fallback routine and methods
  my Str $deprecatable-method = '';
  if ?$doc {
    $deprecatable-method ~= self!add-deprecatable-method($class-element);
    $module-code ~= $code;
    $module-doc ~= $doc;
  }

  note "Generate module functions" if $*verbose;  
  ( $doc, $code) = $!mod.generate-functions($class-element);
  if ?$code {
    $module-doc ~= $doc;
    $module-code ~= $code;
  }

  # Finish 'my Hash $methods' started in $!mod.generate-build()
  $module-code ~= "\);\n";

  $module-code ~= $deprecatable-method;

  # Add the signal doc here
  $module-doc ~= $sig-info<doc>;

  note "Generate module properties" if $*verbose;  
  $module-doc ~= $!mod.generate-properties($class-element);

  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($module-code);
  note "Save pod doc";
  $*work-data<raku-module-doc-file>.IO.spurt($module-doc);
}
#`{{
#-------------------------------------------------------------------------------
method !make-init-method (
  XML::Element $class-element, Hash $sig-info --> Str
) {
#  my Str $ctype = $class-element.attribs<c:type>;
#  my Hash $h = $!sas.search-name($ctype);

  my Str $code = '';

  # Check if signal admin is needed
  if ?$sig-info<doc> {
#:w3<move-cursor>, :w0<copy-clipboard activate-current-link>,
#:w1<populate-popup activate-link>,
    my Hash $signal-levels = %();
    for $sig-info<signals>.keys -> $signal-name {
      my Str $level = $sig-info<signals>{$signal-name}<parameters>.elems.Str;
      $signal-levels{$level} = [] unless $signal-levels{$level}:exists;
      $signal-levels{$level}.push: $signal-name;
    }

    my Str $sig-list = '';
    for ^10 -> Str() $level {
      if ?$signal-levels{$level} {
        $sig-list ~=
           [~] '    :w', $level, '<', $signal-levels{$level}.join(' '), ">,\n";
      }
    }

    my Str $role-ini-method-name =
      "_add_$*work-data<sub-prefix>signal_types";
    $code ~= qq:to/EOBUILD/;
      #TM:1:$role-ini-method-name:
      method $role-ini-method-name ( Str \$class-name ) \{
        self\.add-signal-types\( \$class-name,
      $sig-list  );
      \}

      EOBUILD
  }

  $code
}
}}

#-------------------------------------------------------------------------------
method generate-raku-module-test ( ) {

  my XML::Element $class-element = $!xpath.find('//class');
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  my Str $test-variable = '$' ~ $*gnome-class.lc;
  my $module-test-doc = qq:to/EOTEST/;
    use v6;
    use NativeCall;
    use Test;

    use $*work-data<raku-class-name>;

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

#-------------------------------------------------------------------------------
method !add-deprecatable-method ( XML::Element $class-element --> Str ) {

  my Hash $meta-data = from-json('META6.json'.IO.slurp);
  my Str $version-now = $meta-data<version>;
  my @v = $version-now.split('.');
  @v[1] += 2;
  @v[2] = 0;
  my Str $version-dep = @v.join('.');


  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  my Array $roles = $h<implement-roles> // [];
  my $role-fallbacks = '';
  for @$roles -> $role {
    my Hash $role-h = $!sas.search-name($role);

    $role-fallbacks ~=
      "  \$s = self._$role-h<symbol-prefix>interface\(\$native-sub)\n" ~
      "    if !\$s and self.^can\('_$role-h<symbol-prefix>interface');\n";
  }
  $role-fallbacks ~= "\n" if ?$role-fallbacks;

  my Str $doc = '';

  my Str $pfix = $*work-data<sub-prefix>;
  my @pfix-parts = $pfix.split('_');

  my Str $pfix-dash = $*work-data<sub-prefix>;
  $pfix-dash ~~ s:g/ '_' /-/;
  $pfix-dash.chop(1);

  my Str $package = $*gnome-package.Str.lc;
  $package ~~ s/ \d //;

  my Str ( $mname, $set-class-name);
  $mname = '_fallback';
  $set-class-name = [~] '  if ?$s {', "\n",
    '    self._set-class-name-of-sub(\'', $*work-data<gnome-name>, "');\n",
    "  }\n  else \{\n",
    '    $s = callsame;', "\n",
    "  }\n";

  $doc ~= q:to/EODEPR/;

    #`{{
      Older modules might still have it and must remove the method after
      deprecation date. New modules must not implement this.

    EODEPR

  $doc ~= "{HLSEPARATOR}\n";
  $doc ~= "method $mname " ~ '( Str $native-sub --> Callable ) {' ~ "\n";
  $doc ~= "  my Str \$pfix = '$*work-data<sub-prefix>';\n";

  $doc ~= q:to/EODEPR/;
      my @pfix-parts = $pfix.split('_');
      my Int $cfix = @pfix-parts.elems + 2;
      my Str $new-patt = $native-sub.subst( '-', '_', :g);

      my Callable $s;

      loop ( my Int $dash-count = 2; $dash-count < $cfix; $dash-count++ ) {
        my Str $tv = @pfix-parts[0 .. * - $dash-count].join('_');
        my Str $match = ?$tv ?? "{$tv}_$new-patt" !! "$tv$new-patt";
        try { $s = &::($match); }
        if ?$s {
          $match ~~ s/ $pfix //;
          $match ~~ s:g/ '_' /-/;
    EODEPR

  $doc ~= [~] '      Gnome::N::deprecate( "$native-sub", $match, ', "'",
              $version-now, "', '", $version-dep, "');\n";

  $doc ~= q:to/EODEPR/;

          last;
        }
      }

    EODEPR

  $doc ~= $role-fallbacks;
  $doc ~= $set-class-name;

  $doc ~= q:to/EODEPR/;

      $s
    }

    }}

    EODEPR

  $doc
}

