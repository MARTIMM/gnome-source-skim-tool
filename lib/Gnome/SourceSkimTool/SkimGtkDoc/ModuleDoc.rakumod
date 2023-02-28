=begin pod

=head1 Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc

=head2 Description

=end pod

use Gnome::SourceSkimTool::ConstEnumType;

use XML::Actions;
use XML;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc:auth<github:MARTIMM>;
also is XML::Actions::Work;

enum Phase <
  OutOfPhase Description Functions FApi FApiDoc Signals Properties Types
>;

has Phase $!phase = OutOfPhase;
has Phase $!func-phase = OutOfPhase;

has Str $.description;

has Hash $.functions;
has Str $!function-name;
has Int $!param-count;
has Str $!parameter-name;

has Hash $.signals;
has Str $!signal-name;

has Hash $.properties;
has Str $!property-name;

has Hash $.types;
has Str $!type-name;
has Str $!enum_member_name;

has Hash $!fh;


has Str $!section-prefix-name;
has Int $!refsect-level;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  # Devise the section name using the provided subroutine prefix.
  # Something like 'gtk_button' or 'gio_file'. The examples must
  # become 'GtkButton' or 'GFile'.
  my Str $sp = $*sub-prefix;
  $sp .= tc;
  $sp ~~ s:g/ '_'(\w) /$0.tc()/;

#`{{
  # (from above comment … become 'gtk3-GtkButton' or 'gio-GFile'.
NOTE; previously needed to search for e.g. 'gtk3-GtkButton.description' but
compilation is maybe changed and now it's simpler 'GtkButton.description'. 
There is also more information. Might be that the run must be done in the
directory which is done now by ::Prepare.

  with $*use-doc-source {
    when Gtk3 {
      $!section-prefix-name = 'gtk3';
    }
    
    when Gdk3 {
      $!section-prefix-name = 'gdk3';
    }
    
    when Gtk4 {
      $!section-prefix-name = 'gtk4';
    }
    
    when Gdk4 {
      $!section-prefix-name = 'gdk4';
    }

#      when  {  }
  }

  $!section-prefix-name ~= "-$sp";
#note "$?LINE: $!section-prefix-name";
}}

  $!section-prefix-name = $sp;

  $!description = '';
  $!functions = %();
}

#-------------------------------------------------------------------------------
method refsect1:start ( Array $parent-path, :$id --> ActionResult ) {
  return Truncate unless ?$id;

  note "refsect1: $!section-prefix-name, $id" if $*verbose;

  given $id {
    when "$!section-prefix-name\.description" {
      $!phase = Description;
      $!description = '';
      $!refsect-level = 1;
        #self!cleanup(self!convert-to-pod($parent-path[*-1].nodes));
    }

    when "$!section-prefix-name\.functions_details" {
      $!phase = Functions;
    }

    when "$!section-prefix-name\.signal-details" {
      $!phase = Signals;
    }

    when "$!section-prefix-name\.property-details" {
      $!phase = Properties;
    }
 
    when "$!section-prefix-name\.other_details" {
      $!phase = Types;
    }
 }

  Recurse
}

#-------------------------------------------------------------------------------
method refsect1:end ( Array $parent-path, :$id ) {
  given $!phase {
    when Description {
      $!description = self!cleanup( $!description, :trim);
    }
  }

  $!phase = OutOfPhase;
}

#-------------------------------------------------------------------------------
method refsect2:start ( Array $parent-path, *%attribs --> ActionResult  ) {
  my ActionResult $ar = Recurse;
  $!refsect-level = 2;
#note "$?LINE: $!phase, role={%attribs<role>//''}";

  given $!phase {
    when Functions {
      return Truncate if %attribs<role> ne 'function';

      $!function-name = %attribs<id>;
      $!functions{$!function-name} = %();
      $!fh := $!functions{$!function-name};

      # mark info as init method when 'new' is in the funcion name
      $!fh<init> = $!function-name ~~ m/ <|w> new <|w> /.Bool;
      self!function-scan($parent-path[*-1].nodes);
        
      $ar = Truncate;
#note "$?LINE: $!function-name init: $!fh<init>";
    }

    when Signals {
      return Truncate if %attribs<role> ne 'signal';

      $!signal-name = %attribs<id>;
      $!signals{$!signal-name} = %();
      $!fh := $!signals{$!signal-name};
      self!signal-scan($parent-path[*-1].nodes);
      $!fh<doc><signal> = self!cleanup( $!fh<doc><signal>, :trim);
#note 'sig: ', $!fh;
      $ar = Truncate;
    }

    when Properties {
      return Truncate if %attribs<role> ne 'property';

      $!property-name = %attribs<id>;
      $!properties{$!property-name} = %();
      $!fh := $!properties{$!property-name};
      self!property-scan($parent-path[*-1].nodes);
#note 'prop: ', $!fh;
      $!fh<doc><property> = self!cleanup( $!fh<doc><property>, :trim);

      $ar = Truncate;
    }

    when Types {
      # skip structure info
      return Truncate if %attribs<role> eq 'struct';

      $!type-name = %attribs<id>;

      $!types{$!type-name} = %();
      $!fh := $!types{$!type-name};
      self!type-scan($parent-path[*-1].nodes);
#note 'type: ', $!fh;
      $!fh<type> = self!cleanup( $!fh<type>, :trim);

      $ar = Truncate;
    }
  }

  $ar
}

#-------------------------------------------------------------------------------
method refsect2:end ( Array $parent-path, :$id ) {
  $!refsect-level = 1;
}

#-------------------------------------------------------------------------------
method refsect3:start ( Array $parent-path, :$id ) {
  $!refsect-level = 3;
}

#-------------------------------------------------------------------------------
method refsect3:end ( Array $parent-path, :$id ) {
  $!refsect-level = 2;
}

#-------------------------------------------------------------------------------
method title:start ( Array $parent-path --> ActionResult ) {
  my ActionResult $ar = Recurse;

  given $!phase {
    when Description {
      $!description ~= "\n\n=head$!refsect-level ";
      $!description ~= self!get-text($parent-path[*-1].nodes);
      $!description ~= "\n\n";
#note $!description;

      $ar = Truncate;
    }
  }

  $ar
}

#-------------------------------------------------------------------------------
method type:start ( Array $parent-path, :$role --> ActionResult ) {
  my ActionResult $ar = Recurse;

  given $!phase {
    when Description {
      my Str $name = ($parent-path[*-1].nodes)[0].Str;
        #self!convert-to-pod($e.nodes);
      $!description ~= self!scan-for-unresolved-items($name);
      $ar = Truncate;
    }
  }

  $ar
}

#-------------------------------------------------------------------------------
method xml:text ( Array $parent-path, Str $txt ) {
  given $!phase {
    when Description {
      $!description ~= self!scan-for-unresolved-items($txt);
    }
  }
}

#-------------------------------------------------------------------------------
# called from <refsect2 id="some function" role="function">
method !function-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
#note $n.name;
      given $n.name {
        when 'primary' {
          $!fh<native-name> = self!get-text($n.nodes);
#            self!scan-for-unresolved-items(self!get-text($n.nodes));
        }

        when 'programlisting' {
          $!func-phase = FApi;
          $!fh<doc> = %();
          self!function-scan($n.nodes);
          $!func-phase = OutOfPhase;
        }

        when 'returnvalue' {
          if $!func-phase ~~ FApi {
            $!fh<returnvalue> = self!get-text($n.nodes);
          }
        }

        when 'parameter' {
          if $!func-phase ~~ FApi {
            # get the arguments and add a space just after the pointer character
            my $text = self!get-text($n.nodes);
            $text ~~ s:g/ '*' \s* /* /;

            # split on spaces to get an array of the argument declaration
            $!fh<parameters>[$!param-count].push: |($text.split(/\s+/));
          }
        }
        
        when 'para' {
          if $!phase ~~ Functions and $!func-phase ~~ OutOfPhase {
            $!fh<doc><function> =
              self!scan-for-unresolved-items(self!get-text($n.nodes));
          }
        }

        when 'refsect3' {
          $!refsect-level = 3;

          my %attribs = $n.attribs;
          if %attribs<id> eq "$!function-name\.returns" {
            # can be changed here w're out of programlisting
            $!func-phase = FApiDoc;
            my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
            $rv ~~ s/Returns//;
            $!fh<doc><returnvalue> = self!cleanup( $rv, :trim);
            $!func-phase = OutOfPhase;
          }

          elsif %attribs<id> eq "$!function-name\.parameters" {
            $!func-phase = FApiDoc;
            self!function-scan($n.nodes);
            $!func-phase = OutOfPhase;
          }

          $!refsect-level = 2;
        }

        when 'entry' {
          if $!func-phase ~~ FApiDoc {
            $!fh<doc><params> = %() unless $!fh<doc><params>:exists;
            my %attribs = $n.attribs;
            if %attribs<role> eq 'parameter_name' {
              $!parameter-name = self!get-text($n.nodes);
            }

            elsif %attribs<role> eq 'parameter_description' {
              my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
              $!fh<doc><params>{$!parameter-name} = $rv;
            }
          }
        }

        default {
          self!function-scan($n.nodes);
        }
      }
    }

    elsif $n ~~ XML::Text {
#note $n.Str;
      # Punctuation in argument list;
      #  '(' start list ≡ init,
      #  ',' next argument
      #  ');' end list
      if $!func-phase ~~ FApi {
        my Str $txt = $n.Str;
        if $txt ~~ m/ '(' / {
          $!fh<parameters> = [];
          $!param-count = 0;
          $!fh<parameters>[$!param-count] = [];
        }

        elsif $txt ~~ m/ ',' / {
          $!param-count++;
          $!fh<parameters>[$!param-count] = [];
        }

#        elsif $txt ~~ m/ ');' / {
#        }
      }
    }
  }
}

#-------------------------------------------------------------------------------
# called from <refsect2 id="some signal" role="signal">
method !signal-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
#note "$?LINE: $n.name()";
      given $n.name {
        when 'primary' {
          my Str $text = self!get-text($n.nodes);
          my Str $section-prefix-name = $!section-prefix-name;
          $text ~~ s/ $section-prefix-name '::' //;
          $!fh<native-name> = $text;
        }

        when 'programlisting' {
          $!func-phase = FApi;
          $!fh<doc> = %();
          self!signal-scan($n.nodes);
          $!func-phase = OutOfPhase;
        }

        when 'returnvalue' {
          if $!func-phase ~~ FApi {
            $!fh<returnvalue> = self!get-text($n.nodes);
          }
        }

        when 'type' {
#note "$?LINE: $n.name(), $!phase, $!func-phase, $n.parent().name()";
          if $!func-phase ~~ FApi {
            # get the arguments and add a space just after the pointer character
            my Str $text = self!get-text($n.nodes);
            $text ~~ s:g/ '*' \s* /* /;

            # split on spaces to get an array of the argument declaration
            $!fh<parameters>[$!param-count].push: |($text.split(/\s+/));
          }

          elsif $!func-phase ~~ OutOfPhase {
#note "$?LINE: $n.name(), $!phase, $!func-phase, $n.parent.name()";
            my XML::Node $parent = $n.parent;
            if $parent.name eq 'link' {
              my Str $linkend = $parent.attribs<linkend>;
              my Str $text = self!scan-for-unresolved-items($linkend);
              $!fh<parameters>[$!param-count].push: |($text.split(/\s+/));
            }
          }
        }

        when 'para' {
#note "$?LINE: $n.name(), $!phase, $!func-phase, $n.parent.name()";
          if $!phase ~~ Signals and $!func-phase ~~ OutOfPhase {
            my Str $sigdoc = self!get-text( $n.nodes, :link, :literal);
            if $sigdoc ~~ m/^ Flags ':' / {
              # get only text
              $sigdoc = self!get-text($n.nodes);
              $sigdoc ~~ s/^ Flags ':' \s* //;
              $!fh<flags> = $sigdoc;
            }

            # skip since
            elsif $sigdoc ~~ m/^ Since ':' / { }

            else {
#note "$?LINE: $sigdoc";
              $!fh<doc><signal> ~= ' ' ~ $sigdoc;
            }
          }
        }

        when 'refsect3' {
          $!refsect-level = 3;

          my %attribs = $n.attribs;
          if %attribs<id> eq "$!signal-name\.returns" {
            # can be changed here w're out of programlisting
            $!func-phase = FApiDoc;
            my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
            $rv ~~ s/Returns//;
            $!fh<doc><returnvalue> = self!cleanup( $rv, :trim);
            $!func-phase = OutOfPhase;
          }

          elsif %attribs<id> eq "$!signal-name\.parameters" {
            $!func-phase = FApiDoc;
            self!signal-scan($n.nodes);
            $!func-phase = OutOfPhase;
          }

          $!refsect-level = 2;
        }

        when 'entry' {
          if $!func-phase ~~ FApiDoc {
            $!fh<doc><params> = %() unless $!fh<doc><params>:exists;
            my %attribs = $n.attribs;
            if %attribs<role> eq 'parameter_name' {
              $!parameter-name = self!get-text($n.nodes);
            }

            elsif %attribs<role> eq 'parameter_description' {
              my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
              $!fh<doc><params>{$!parameter-name} = $rv;
            }
          }
        }

        default {
          self!signal-scan($n.nodes);
        }
      }
    }

    elsif $n ~~ XML::Text {
#note "$?LINE: $!phase, $!func-phase, {$!param-count//'-'}, '$n.Str()'";

      # Punctuation in argument list;
      #  '(' start list ≡ init,
      #  ',' next argument
      #  ');' end list
      if $!func-phase ~~ FApi {
        my Str $text = $n.Str;
        $text ~~ s/^ \s+ //;
        $text ~~ s/ \s+ $//;
        if $text ~~ m/ '(' / {
          $!fh<parameters> = [];
          $!param-count = 0;
          $!fh<parameters>[$!param-count] = [];
        }

        elsif $text ~~ m/ ',' / {
          # nasty commas next to text
          if $text ~~ m/^ $<t> = (.+?) ',' $/ {
            # text in front of a comma
            $text = $<t>.Str;
            $text ~~ s:g/ '*' \s* /* /;
            $!fh<parameters>[$!param-count][*-1] ~= ' ' ~ $text;
#note "---> $!fh<parameters>[$!param-count].elems(), $!fh<parameters>[$!param-count][*-1]";
          }

          $!param-count++;
          $!fh<parameters>[$!param-count] = [];

          if $text ~~ m/^ ',' $<t> = (.+?) $/ {
            # text after comma
            $text = $<t>.Str;
            $text ~~ s:g/ '*' \s* /* /;
            $!fh<parameters>[$!param-count][*-1] ~= ' ' ~ $text;
#note "---> $!fh<parameters>[$!param-count].elems(), $!fh<parameters>[$!param-count][*-1]";
          }
        }

#        elsif $text ~~ m/ ');' / {
#        }

        else {
          $!fh<parameters>[$!param-count][*-1] ~= $text;
#note "---> $!fh<parameters>[$!param-count].elems(), $!fh<parameters>[$!param-count][*-1]";
        }
      }
    }
  }
}

#-------------------------------------------------------------------------------
# called from <refsect2 id="some property" role="property">
method !property-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
#note "$?LINE: $n.name()";
      given $n.name {
        when 'primary' {
          my Str $text = self!get-text($n.nodes);
          my Str $section-prefix-name = $!section-prefix-name;
          $text ~~ s/ $section-prefix-name ':' //;
          $!fh<native-name> = $text;
        }

        when 'programlisting' {
          $!func-phase = FApi;
          $!fh<doc> = %();
          self!property-scan($n.nodes);
          $!func-phase = OutOfPhase;
        }
#`{{
        when 'returnvalue' {
          if $!func-phase ~~ FApi {
            $!fh<returnvalue> = self!get-text($n.nodes);
          }
        }
}}
        when 'type' {
          if $!func-phase ~~ FApi {
            $!fh<type> = self!get-text($n.nodes);
          }
        }
        
        when 'para' {
#note "$?LINE: $!phase, $!func-phase";
          if $!phase ~~ Properties and $!func-phase ~~ OutOfPhase {
            #$!fh<doc><signal> = '' unless $!fh<doc><signal>:exists;
            my Str $propdoc = self!get-text($n.nodes);
            if $propdoc ~~ m/^ Flags ':' / {
              $propdoc ~~ s/^ Flags ':' \s* //;
              $!fh<flags> = $propdoc;
            }

            elsif $propdoc ~~ m/^ Owner ':' / {
              $propdoc ~~ s/^ Owner ':' \s* //;
              $!fh<owner> = $propdoc;
            }

            elsif $propdoc ~~ m/^ Default \s+ value ':' / {
              $propdoc ~~ s/^ Default \s+ value ':' \s* //;
              $!fh<default> = $propdoc;
            }

            elsif $propdoc ~~ m/^ Allowed \s+ values ':' / {
              $propdoc ~~ s/^ Allowed \s+ values ':' \s* //;
              $!fh<allowed> = $propdoc;
            }

            # skip since
            elsif $propdoc ~~ m/^ Since ':' / { }

            else {
              $!fh<doc><property> ~=
                ' ' ~ self!scan-for-unresolved-items($propdoc);
            }
          }
        }

#`{{

        when 'refsect3' {
          $!refsect-level = 3;

          my %attribs = $n.attribs;
          if %attribs<id> eq "$!signal-name\.returns" {
            # can be changed here w're out of programlisting
            $!func-phase = FApiDoc;
            my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
            $rv ~~ s/Returns//;
            $!fh<doc><returnvalue> = self!cleanup( $rv, :trim);
            $!func-phase = OutOfPhase;
          }

          elsif %attribs<id> eq "$!signal-name\.parameters" {
            $!func-phase = FApiDoc;
            self!property-scan($n.nodes);
            $!func-phase = OutOfPhase;
          }

          $!refsect-level = 2;
        }
}}

        when 'entry' {
          if $!func-phase ~~ FApiDoc {
            $!fh<doc><params> = %() unless $!fh<doc><params>:exists;
            my %attribs = $n.attribs;
            if %attribs<role> eq 'parameter_name' {
              $!parameter-name = self!get-text($n.nodes);
            }

            elsif %attribs<role> eq 'parameter_description' {
              my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
              $!fh<doc><params>{$!parameter-name} = $rv;
            }
          }
        }

        default {
          self!property-scan($n.nodes);
        }
      }
    }

    elsif $n ~~ XML::Text {
#note $n.Str;
#`{{
      # Punctuation in argument list;
      #  '(' start list ≡ init,
      #  ',' next argument
      #  ');' end list
      if $!func-phase ~~ FApi {
        my Str $txt = $n.Str;
        if $txt ~~ m/ '(' / {
          $!fh<parameters> = [];
          $!param-count = 0;
          $!fh<parameters>[$!param-count] = [];
        }

        elsif $txt ~~ m/ ',' / {
          $!param-count++;
          $!fh<parameters>[$!param-count] = [];
        }

#        elsif $txt ~~ m/ ');' / {
#        }
      }
}}
    }
  }
}

#-------------------------------------------------------------------------------
# called from
#   <refsect2 id="some type" role="enum">
method !type-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
#note "$?LINE: $n.name()";
      given $n.name {
        when 'primary' {
          my Str $text = self!get-text($n.nodes);
#          my Str $section-prefix-name = $!section-prefix-name;
#          $text ~~ s/ $section-prefix-name ':' //;
          $!fh<native-name> = $text;
        }
#`{{
        when 'programlisting' {
          $!func-phase = FApi;
          $!fh<doc> = %();
          self!type-scan($n.nodes);
          $!func-phase = OutOfPhase;
        }
}}
#`{{
        when 'returnvalue' {
          if $!func-phase ~~ FApi {
            $!fh<returnvalue> = self!get-text($n.nodes);
          }
        }
}}
#        when 'type' {
#          if $!func-phase ~~ FApi {
#            $!fh<type> = self!get-text($n.nodes);
#          }
#        }
        
        when 'para' {
#note "$?LINE: $!phase, $!func-phase";
          if $!phase ~~ Types and $!func-phase ~~ OutOfPhase {
            my Str $typedoc = self!get-text($n.nodes);
#`{{
            if $typedoc ~~ m/^ Flags ':' / {
              $typedoc ~~ s/^ Flags ':' \s* //;
              $!fh<flags> = $typedoc;
            }

            elsif $typedoc ~~ m/^ Owner ':' / {
              $typedoc ~~ s/^ Owner ':' \s* //;
              $!fh<owner> = $typedoc;
            }

            elsif $typedoc ~~ m/^ Default \s+ value ':' / {
              $typedoc ~~ s/^ Default \s+ value ':' \s* //;
              $!fh<default> = $typedoc;
            }

            elsif $typedoc ~~ m/^ Allowed \s+ values ':' / {
              $typedoc ~~ s/^ Allowed \s+ values ':' \s* //;
              $!fh<allowed> = $typedoc;
            }
}}
            # skip since
            if $typedoc ~~ m/^ Since ':' / { }

            else {
              $!fh<type> ~= ' ' ~ self!scan-for-unresolved-items($typedoc);
            }
          }
        }

        when 'refsect3' {
          $!refsect-level = 3;

          my %attribs = $n.attribs;
#note "$?LINE: $!type-name, %attribs.gist()";
#`{{
            if %attribs<id> eq "$!type-name\.returns" {
            # can be changed here w're out of programlisting
            $!func-phase = FApiDoc;
            my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
            $rv ~~ s/Returns//;
            $!fh<doc><returnvalue> = self!cleanup( $rv, :trim);
            $!func-phase = OutOfPhase;
          }
}}
          if %attribs<id> eq "$!type-name\.members" {
            $!func-phase = FApiDoc;
            $!fh<doc> = [];
            $!fh<values> = [];
            $!fh<names> = [];
            self!type-scan($n.nodes);
            $!func-phase = OutOfPhase;
          }

          $!refsect-level = 2;
        }

        when 'entry' {
#note "$?LINE: $!func-phase, $!type-name, $n.attribs.gist()";
          if $!func-phase ~~ FApiDoc {
            my %attribs = $n.attribs;
            if %attribs<role> eq 'enum_member_name' {
              $!enum_member_name = self!get-text($n.nodes);
              $!fh<names>.push: $!enum_member_name;
            }

            elsif %attribs<role> eq 'enum_member_description' {
              my $rv = self!scan-for-unresolved-items(self!get-text($n.nodes));
              $!fh<doc>.push: $rv;
            }
          }
        }

        default {
          self!type-scan($n.nodes);
        }
      }
    }

    elsif $n ~~ XML::Text {
#note $n.Str;
#`{{
      # Punctuation in argument list;
      #  '(' start list ≡ init,
      #  ',' next argument
      #  ');' end list
      if $!func-phase ~~ FApi {
        my Str $txt = $n.Str;
        if $txt ~~ m/ '(' / {
          $!fh<parameters> = [];
          $!param-count = 0;
          $!fh<parameters>[$!param-count] = [];
        }

        elsif $txt ~~ m/ ',' / {
          $!param-count++;
          $!fh<parameters>[$!param-count] = [];
        }

#        elsif $txt ~~ m/ ');' / {
#        }
      }
}}
    }
  }
}

#-------------------------------------------------------------------------------
method !get-text (
  @nodes, :@skip, Bool :$link = False, Bool :$literal = False --> Str
) {
  my $text = '';

  for @nodes -> $n {
    if $n ~~ XML::Text {
      $text ~= $n.Str;
    }

    elsif $n ~~ XML::Element {
      if $link and $n.name eq 'link' {
        $text ~= self!linked-items($n.attribs<linkend>);
      }

      elsif $literal and $n.name eq 'literal' {
        $text ~= self!scan-for-unresolved-items(self!get-text($n.nodes));
      }

      # skip any nodes mentioned in the skip list
      elsif $n.name !~~ any(@skip) {
        $text ~= self!get-text($n.nodes);
      }
    }
  }

#note "$?LINE: $text";

  $text
}

#-------------------------------------------------------------------------------
method !linked-items ( Str $text is copy --> Str ) {
note "$?LINE: $!section-prefix-name, $text";

  my Str $section-prefix-name = $!section-prefix-name;
  if $text ~~ m/ $section-prefix-name / {
    $text ~~ s/ $section-prefix-name '-' //;
  }

  else {
    my Str ( $class, $rest) = $text.split( '-', 2);
    with $*use-doc-source {
      when Gtk3 { $class ~~ s:g/ Gtk (\w+) /Gnome::Gtk3::$0/; }
      when Gdk3 { $class ~~ s:g/ Gdk (\w+) /Gnome::Gdk3::$0/; }
      when Gtk4 { $class ~~ s:g/ Gtk (\w+) /Gnome::Gtk4::$0/; }
      when Gdk4 { $class ~~ s:g/ Gdk (\w+) /Gnome::Gdk4::$0/; }
  #    when  { $text ~~ s:g/ <!after '::'> G.. (\w+) /B<Gnome::G..::$0>/; }
    }

    $text = "$rest defined in B<$class>";
  }

#note "$?LINE: $text";
  " I<$text> "
}

#-------------------------------------------------------------------------------
method !cleanup ( Str $text is copy, Bool :$trim = False --> Str ) {
#  $text = self!scan-for-unresolved-items($text);

  $text ~~ s:g/ ' '+ / /;
  $text ~~ s:g/ <|w> \n <|w> / /;
  $text ~~ s:g/ \n ** 3..* /\n\n/;

  if $trim {
    $text ~~ s/^ \s+ //;
    $text ~~ s/ \s+ $//;
  }

  $text
}

#-------------------------------------------------------------------------------
# :link is from linkend attribute when True in a link element
method !scan-for-unresolved-items ( Str $text is copy --> Str ) {
note "text is empty: $!phase, $!func-phase, ", callframe(3).gist if !$text;

  my Str $section-prefix-name = $!section-prefix-name;

  # signals
  if $text ~~ m/ <|w> $section-prefix-name '::' \w+ / {
#print "$?LINE: text has :: '$text'";
    $text ~~ s:g/ <|w> $section-prefix-name '::' (\w+) /I<$0>/;
#note " -> $text";
  }

  elsif $text ~~ m/ <|w> \w+ '::' \w+ / {
#print "$?LINE: text has :: '$text'";
    $text ~~ s:g/ <|w> (\w+) '::' (\w+) / I<$1 defined in $0>/;
#note " -> $text";
  }

  elsif $text ~~ m/ <|w> '::' \w+ / {
#print "$?LINE: text has :: '$text'";
    $text ~~ s:g/ <|w> '::' (\w+) / I<$0>/;
#note " -> $text";
  }


  # properties
  if $text ~~ m/ <|w> $section-prefix-name ':' \w+ / {
#print "$?LINE: text has : '$text'";
    $text ~~ s:g/ <|w> $section-prefix-name ':' (\w+) /I<$1 defined in $0>/;
#note " -> $text";
  }

  elsif $text ~~ m/ <|w> \w+ ':' \w+ / {
#print "$?LINE: text has : '$text'";
    $text ~~ s:g/ <|w> (\w+) ':' (\w+) / I<$0>/;
#note " -> $text";
  }

  elsif $text ~~ m/ <|w> ':' \w+ / {
#print "$?LINE: text has : '$text'";
    $text ~~ s:g/ <|w> ':' (\w+) / I<$0>/;
#note " -> $text";
  }


  # css
  if $text ~~ m/ \s '.' / {
    $text ~~ s:g/ \s '.' (<[-\w]>+) / C<.$0>/;
#note "$?LINE: text has . -> $text";
  }


  # functions
  if $text ~~ m/ '()' \s / {
#note "$?LINE: text has () -> $text";
  }

  # classes
  with $*use-doc-source {
    # <!after '::'> is needed to keep previously converted text correct
    when Gtk3 { $text ~~ s:g/ <!after '::'> Gtk (\w+) /B<Gnome::Gtk3::$0>/; }
    when Gdk3 { $text ~~ s:g/ <!after '::'> Gdk (\w+) /B<Gnome::Gdk3::$0>/; }
    when Gtk4 { $text ~~ s:g/ <!after '::'> Gtk (\w+) /B<Gnome::Gtk4::$0>/; }
    when Gdk4 { $text ~~ s:g/ <!after '::'> Gdk (\w+) /B<Gnome::Gdk4::$0>/; }
#    when  { $text ~~ s:g/ <!after '::'> G.. (\w+) /B<Gnome::G..::$0>/; }
  }

  # some xml remnants
  $text ~~ s:g/ '&lt;' /</;
  $text ~~ s:g/ '&gt;' />/;
  $text ~~ s:g/ [ '&#160;' || '&nbsp;' ] / /;

  # variable changes
  $text ~~ s:g:i/ true /True/;
  $text ~~ s:g:i/ false /False/;

  $text
}
