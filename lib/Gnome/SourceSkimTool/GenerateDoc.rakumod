

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SearchAndSubstitute;

use XML;
use XML::XPath;

#-------------------------------------------------------------------------------
unit class  Gnome::SourceSkimTool::GenerateDoc:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
 
  $!sas .= new;
}


#-------------------------------------------------------------------------------
method pod-header ( Str $text --> Str ) {

  qq:to/RAKUMOD/;
    {HLSEPARATOR}
    {SEPARATOR($text);}
    {HLSEPARATOR}
    RAKUMOD
}

#-------------------------------------------------------------------------------
method get-description ( XML::Element $element, XML::XPath $xpath --> Str ) {
  my Str $doc = "=head1 Description\n";

  #$doc ~= self!set-example-image;

  #$doc ~= $!xpath.find( 'doc/text()', :start($element)).Str;
  my Str $widget-picture = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);
  $widget-picture = "\n!\[\]\(images/{$*gnome-class.lc}.png\)\n\n" if $h<inheritable>;

  $doc ~= $!sas.modify-text(
    $xpath.find( 'doc/text()', :start($element)).Str
  );

  #??$doc ~= self!set-declaration;
  $doc ~= self!set-uml;
  $doc ~= self!set-inherit-example($element);
  $doc ~= self!set-example;

  qq:to/RAKUMOD/;
    =begin pod
    =head1 $*work-data<raku-class-name>

    $widget-picture$doc
    =end pod
    RAKUMOD
}

#-------------------------------------------------------------------------------
method !set-uml ( --> Str ) {
  # Using a markdown link not a Raku pod link
  my Str $doc = q:to/EOEX/;


    =begin comment
    =head2 Uml Diagram
    ![](plantuml/Label.svg)
    =end comment
    EOEX
  $doc
}
#-------------------------------------------------------------------------------
method !set-inherit-example ( XML::Element $element --> Str ) {

  my Str $doc = '';
  my Str $ctype = $element.attribs<c:type>;
  my Hash $h = $!sas.search-name($ctype);

  if $h<inheritable> {
    # Code like {'...'} is inserted here and there to prevent interpretation
    $doc = qq:to/EOINHERIT/;

      =head2 Inheriting this class

      Inheriting is done in a special way in that it needs a call from new\() to get the native object created by the class you are inheriting from.

        use $*work-data<raku-class-name>;

        unit class MyGuiClass;
        also is $*work-data<raku-class-name>;

        submethod new \( \|c ) \{
          # let the {$*work-data<raku-class-name>} class process the options
          self\.bless\( :{$element.attribs<c:type>}, \|c);
        \}

        submethod BUILD \( ... ) \{
          ...
        \}

      EOINHERIT
  }

  $doc
}

#-------------------------------------------------------------------------------
method !set-example ( --> Str ) {
  my Str $doc = q:to/EOEX/;

    =begin comment
    =head2 Example
      … text …
      … example code …
    =end comment
    EOEX
  $doc
}
