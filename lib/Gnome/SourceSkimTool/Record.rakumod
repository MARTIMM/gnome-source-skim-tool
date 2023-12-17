
use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Test;
use Gnome::SourceSkimTool::Resolve;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Record:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Test $!tst;
has Gnome::SourceSkimTool::Resolve $!solve;

has XML::XPath $!xpath;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $!mod .= new;
  $!solve .= new;

  # load data for this module
  my Str $file = "$*work-data<gir-module-path>R-$*gnome-class.gir";
  note "Load module data from $file" if $*verbose;
  $!xpath .= new(:$file);
}

#-------------------------------------------------------------------------------
# In a <record> there might be constructors, methods, functions or fields
method generate-code ( ) {

  my Hash $h = $!solve.search-name($*work-data<gnome-name>);
  my Str $class-name = $!solve.set-object-name($h);

  my XML::Element $element = $!xpath.find('//namespace/record');
  die "//record elements not found in gir-record-file for $class-name" unless ?$element;

  my Str $callable-code = $!mod.generate-callables( $element, $!xpath);
  if ?$callable-code {

    my Str $code = qq:to/RAKUMOD/;
      $*command-line
      use v6.d;
      RAKUMOD

  #  my Str $module-doc = qq:to/RAKUMOD/;
  #    #TL:1:$*work-data<raku-class-name>:
  #    use v6.d;
  #
  #    {pod-header('Record Description')}
  #    RAKUMOD

  #  note "Generate module description" if $*verbose;  
  #  $module-doc ~= $!grd.get-description( $element, $!xpath) if $*generate-doc;

    note "Set class unit" if $*verbose;
    $code ~= $!mod.set-unit($element);

    # Generate a structure into a 'package-path/N-*.rakumod' file
    say "\nGenerate record structure: ", $*work-data<raku-class-name>
      if $*verbose;
    $code ~= $!mod.generate-structure(
      |$!mod.init-xpath(
        'record', "$*work-data<gir-module-path>R-$*gnome-class.gir"
      )
    );

    # Make a BUILD submethod
    note "Generate BUILD submethod" if $*verbose;  
  #  ( $doc, $code) = $!mod.generate-build( $element, %());
  #  $module-doc ~= $doc;
  #  $module-code ~= $code;
    $code ~= $!mod.make-build-submethod( $element, $!xpath);

    $code ~= $callable-code;

  #`{{
    note "Generate module methods" if $*verbose;  
    ( $doc, $code) = $!mod.generate-methods($element);

    # if there are methods, add the fallback routine and methods
    if ?$doc {
  #    $module-code ~= self!add-deprecatable-method($element);
      $module-code ~= $code;
      $module-doc ~= $doc;
    }

    note "Generate module functions" if $*verbose;  
    $module-code ~= $!mod.generate-functions-code($element)
      if $*generate-code;
  #  if ?$code {
  #    $module-doc ~= $doc;
  #    $module-code ~= $code;
  #  }


    # Finish 'my Hash $methods' started in $!mod.generate-build()
    # and add necessary _fallback-v2() method. It is recognized in
    # class Gnome::N::TopLevelClassSupport.
    $module-code ~= q:to/RAKUMOD/;
      );

      #-------------------------------------------------------------------------------
      method _fallback-v2 (
        Str $n, Bool $_fallback-v2-ok is rw, *@arguments
      ) {
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
  }}

    $code = $!mod.substitute-MODULE-IMPORTS( $code, $class-name);

    my Str $fname = $!solve.set-object-name( $h, :name-type(FilenameCodeType));
    $!mod.save-file( $fname, $code, "record module");
  }
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

  $!grd .= new;

  my XML::Element $element = $!xpath.find('//namespace/record');
  die "//record not found in gir-record-file for $*work-data<raku-class-name>" unless ?$element;

#  note "Document init" if $*verbose;
#  my Str $doc = $!grd.start-document;


  note "Document module description" if $*verbose;
  my Str $doc ~= $!grd.get-description( $element, $!xpath);

  note "Document structure" if $*verbose;
  $doc ~= $!grd.document-structure( $element, $!xpath);

  note "Document BUILD submethod" if $*verbose;
  $doc ~= $!grd.document-build($element);

 
  note "Document constructors" if $*verbose;
  $doc ~= $!grd.document-constructors( $element, $!xpath);
 
  note "Document methods" if $*verbose;
  $doc ~= $!grd.document-native-subs( $element, $!xpath, :routine-type<method>);

  note "Document functions" if $*verbose;
  $doc ~= $!grd.document-native-subs(
    $element, $!xpath, :routine-type<function>
  );

  my Hash $h0 = $!solve.search-name($*work-data<gnome-name>);
  my Str $fname = $!solve.set-object-name( $h0, :name-type(FilenameDocType));
  $!mod.save-file( $fname, $doc, "record documentation");
}

#-------------------------------------------------------------------------------
method generate-test ( ) {

#  my Str $ctype = $*work-data<gnome-name>;
  my Str $prefix = $*work-data<name-prefix>;
#  $ctype ~~ s:i/^ $prefix //;
#  my Str $fname = "$*work-data<result-tests>/$ctype.rakutest";

  $!tst .= new;

  my XML::Element $element = $!xpath.find('//namespace/record');

  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!solve.search-name($ctype);

  # Get name of test variable holding this record object
  my Str $test-variable = $h<gnome-name>.lc;
  $test-variable ~~ s:i/^ $prefix //;
  $test-variable = '$' ~ $test-variable;

  # Import the record structure
#  my Str $raku-class-struct = $h<class-name>;
  my Str $raku-class-struct =
    $!solve.set-object-name( $h, :name-type(ClassnameType));
  $!mod.add-import($raku-class-struct);

  # Import the module to be tested. Drop the 'N- <prefix>' to get the
  # class name of the tested module.
  my Str $raku-class = $raku-class-struct;
#  $raku-class ~~ s:i/ '::N-' $prefix /::/;
#  $!mod.add-import($raku-class);

  # Set up start of test code
  my Str $code = $!tst.prepare-test($raku-class);

  # Get constructors if there are any and make tests for them
#  my Hash $hcs = $!mod.get-constructors( $element, $!xpath, :user-side);
  my Hash $hcs = $!mod.get-native-subs(
    $element, $!xpath, :user-side, :routine-type<constructor>
  );
  $code ~= $!tst.generate-init-tests(
    $test-variable, 'Class init tests', $hcs, :test-class($raku-class)
  );

  $code ~= $!tst.generate-test-separator;

  # Get methods if there are any and make tests for them
#  $hcs = $!mod.get-methods( $element, $!xpath, :user-side);
  $hcs = $!mod.get-native-subs(
    $element, $!xpath, :user-side, :routine-type<method>
  );
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable);

  # Get functions if there are any and make tests for them.
  # Likely the only type of subs in a record module
#  $hcs = $!mod.get-functions( $element, $!xpath, :user-side);
  $hcs = $!mod.get-native-subs(
    $element, $!xpath, :user-side, :routine-type<function>
  );
  $code ~= $!tst.generate-method-tests( $hcs, $test-variable, :!ismethod);

  # End the tests and subsitute all necessary modules to import
  $code ~= $!tst.generate-test-end;
  $code = $!mod.substitute-MODULE-IMPORTS($code);

#  my Hash $h0 = $!solve.search-name($*work-data<gnome-name>);
  my Str $fname = $!solve.set-object-name( $h, :name-type(FilenameTestType));
  $!mod.save-file( $fname, $code, "record tests");
}
