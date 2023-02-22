=begin pod

=head1 Gnome::SourceSkimTool::SkimGtkDoc::PropDoc

=head2 Description

=end pod

use Gnome::SourceSkimTool::ConstEnumType;

use XML::Actions;
use XML;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc::PropDoc:auth<github:MARTIMM>;
also is XML::Actions::Work;

has Hash $!properties;
has Str $!prop-name;
has Str $!section-prefix-name;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  # Devise the section name using the provided subroutine prefix.
  # Something like 'gtk_button' or 'gio_file'. The examples must
  # become 'GtkButton' or 'GFile'.
  my Str $sp = $*sub-prefix;
  $sp .= tc;
  $sp ~~ s:g/ '_'(\w) /$0.tc()/;

  $!section-prefix-name = $sp;
  
note $!section-prefix-name;

  $!properties = %();
  $!prop-name = '';
}

#-------------------------------------------------------------------------------
#method ARG:start ( Array $parent-path --> ActionResult ) {
#}

#-------------------------------------------------------------------------------
method ARG:end ( ) {
  $!prop-name = '';
}

#-------------------------------------------------------------------------------
method NAME:start ( Array $parent-path --> ActionResult ) {
  my ActionResult $ar = Truncate;

  $!prop-name = self!get-text($parent-path[*-1].nodes);
  my $section-prefix-name = $!section-prefix-name;
  if $!prop-name ~~ m/ $section-prefix-name '::' / {
    $!prop-name ~~ s/ $section-prefix-name '::' //;
    $!properties{$!prop-name} = %();
    note "Property $!prop-name" if $*verbose;
    $ar = Recurse;
  }

  $ar
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
