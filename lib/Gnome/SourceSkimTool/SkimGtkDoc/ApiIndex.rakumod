=begin pod

=head1 Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex

=head2 Description

=end pod

use Gnome::SourceSkimTool::ConstEnumType;

use XML::Actions;
use XML;
use YAMLish;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex:auth<github:MARTIMM>;
also is XML::Actions::Work;

has Bool $.process-deprecations is rw;
has Hash $.objects;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!objects = %();
  $!process-deprecations = False;
}

#-------------------------------------------------------------------------------
method indexentry:start ( Array $parent-path ) {
  my Str $text = self!get-text($parent-path[*-1].nodes);
  if ?$text and $text !~~ m/ private $/ {

    # drop the comma and remove object from 'object property'. same for signal
    $text ~~ s:g/ ',' //;
    $text ~~ s:i/ object \s+ property /property/;
    $text ~~ s:i/ object \s+ signal /signal/;
    $text ~~ s:i/ standard \s+ enumerations /enumerations/;
    my Str ( $name, $type, $in, $object) = $text.split(/\s+/);

    if $type ne 'macro' {
      # drop the comma from the object
      $!objects{$name} = %(
        :$object, :$type, :deprecated($!process-deprecations),
        :$text
      );
    }
  }
}

#-------------------------------------------------------------------------------
method !get-text ( @nodes --> Str ) {
  my $text = '';

  for @nodes -> $n {
    if $n ~~ XML::Text {
      $text ~= $n.Str;
    }

    elsif $n ~~ XML::Element {
      $text ~= self!get-text($n.nodes);
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method save-objects ( ) {

  my $fname = SKIMTOOLDATA ~ 'objects.yaml';
  $fname.IO.spurt(save-yaml($!objects));
}

#-------------------------------------------------------------------------------
method load-objects ( ) {

  my $fname = SKIMTOOLDATA ~ 'objects.yaml';
  $!objects = load-yaml($fname.IO.slurp);
}
