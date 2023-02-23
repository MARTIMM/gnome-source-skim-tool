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

enum Phase <OutOfPhase Description Functions FApi FApiDoc Signals Properties>;

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
  }

  Recurse
}

#-------------------------------------------------------------------------------
method refsect1:end ( Array $parent-path, :$id ) {
  given $!phase {
    when Description {
      $!description = self!cleanup($!description);
    }
  }

  $!phase = OutOfPhase;
}

#-------------------------------------------------------------------------------
method refsect2:start ( Array $parent-path, *%attribs --> ActionResult  ) {
  my ActionResult $ar = Recurse;
  $!refsect-level = 2;
note "$?LINE: $!phase, role={%attribs<role>//''}";

  given $!phase {
    when Functions {
      return Truncate if %attribs<role> ne 'function';

      $!function-name = %attribs<id>;
      $!functions{$!function-name} = %();
      $!fh := $!functions{$!function-name};

#NOTE; jot all functions down, when reading api-index-deprecated.xml we add
# these notes too together with signals and properties.
#      if (%attribs<condition>//'') ~~ m/ deprecated / {
#        note "function %attribs<id> is deprecated";
#        $!fh<deprecated> = True;
#        return Truncate;
#      }


      # mark info as init method when 'new' is in the funcion name
      $!fh<init> = $!function-name ~~ m/ <|w> new <|w> /.Bool;
      $!fh<deprecated> = False;
      self!function-scan($parent-path[*-1].nodes);
        
      $ar = Truncate;
#note "$?LINE: $!function-name init: $!fh<init>";
    }

    when Signals {
      return Truncate if %attribs<role> ne 'signal';

      $!signal-name = %attribs<id>;
      $!signals{$!signal-name} = %();
      $!fh := $!signals{$!signal-name};
      $!fh<deprecated> = False;
      self!signal-scan($parent-path[*-1].nodes);
#note 'sig: ', $!fh;
      $ar = Truncate;
    }

    when Properties {
      return Truncate if %attribs<role> ne 'property';

      $!property-name = %attribs<id>;
      $!properties{$!property-name} = %();
      $!fh := $!properties{$!property-name};
      $!fh<deprecated> = False;
      self!property-scan($parent-path[*-1].nodes);
note 'prop: ', $!fh;

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
note "$?LINE: $n.name()";
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
          if $!func-phase ~~ FApi {
            # get the arguments and add a space just after the pointer character
            my $text = self!get-text($n.nodes);
            $text ~~ s:g/ '*' \s* /* /;

            # split on spaces to get an array of the argument declaration
            $!fh<parameters>[$!param-count].push: |($text.split(/\s+/));
          }
        }
        
        when 'para' {
note "$?LINE: $!phase, $!func-phase";
          if $!phase ~~ Signals and $!func-phase ~~ OutOfPhase {
            #$!fh<doc><signal> = '' unless $!fh<doc><signal>:exists;
            my Str $sigdoc = self!get-text($n.nodes);
            if $sigdoc ~~ m/^ Flags ':' / {
              $sigdoc ~~ s/^ Flags ':' \s* //;
              $!fh<flags> = $sigdoc;
            }

            else {
              $!fh<doc><signal> ~=
                ' ' ~ self!scan-for-unresolved-items($sigdoc);
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
# called from <refsect2 id="some property" role="property">
method !property-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
note "$?LINE: $n.name()";
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
note "$?LINE: $!phase, $!func-phase";
          if $!phase ~~ Properties and $!func-phase ~~ OutOfPhase {
            #$!fh<doc><signal> = '' unless $!fh<doc><signal>:exists;
            my Str $propdoc = self!get-text($n.nodes);
            if $propdoc ~~ m/^ Flags ':' / {
              $propdoc ~~ s/^ Flags ':' \s* //;
              $!fh<flags> = $propdoc;
            }

            if $propdoc ~~ m/^ Owner ':' / {
              $propdoc ~~ s/^ Owner ':' \s* //;
              $!fh<owner> = $propdoc;
            }

            if $propdoc ~~ m/^ Default value ':' / {
              $propdoc ~~ s/^ Default value ':' \s* //;
              $!fh<default> = $propdoc;
            }

            if $propdoc ~~ m/^ Allowed value ':' / {
              $propdoc ~~ s/^ Allowed value ':' \s* //;
              $!fh<allowed> = $propdoc;
            }

            # skip since
            if $propdoc ~~ m/^ Since ':' / { }

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
method !scan-for-unresolved-items ( Str $text is copy --> Str ) {

  # signals
  if $text ~~ m/  '::' \w+ / {
    $text ~~ s:g/ \w* '::' (\w+) /I<$0>/;
#    $text ~~ s:g/ <|w> '::' (\w+) /I<$0>/;
note $?LINE ~ 'text has :: -> ', $text;
  }

  # properties
  if $text ~~ m/ ':' \w+ / {
    $text ~~ s:g/ \w* ':' (\w+) /I<$0>/;
#    $text ~~ s:g/ <|w> ':' (\w+) /I<$0>/;
note $?LINE ~ 'text has :';
  }

  # css
  if $text ~~ m/ \s '.' / {
    $text ~~ s:g/ \s '.' (<[-\w]>+) / C<.$0>/;
#note $?LINE ~ 'text has .';
  }

  # functions
  if $text ~~ m/ '()' \s / {
note $?LINE ~ 'text has ()';
  }

  # classes
#  else {
    with $*use-doc-source {
      # <!after '::'> is needed to keep previously converted text correct
      when Gtk3 { $text ~~ s:g/ <!after '::'> Gtk (\w+) /B<Gnome::Gtk3::$0>/; }
      when Gdk3 { $text ~~ s:g/ <!after '::'> Gdk (\w+) /B<Gnome::Gdk3::$0>/; }
      when Gtk4 { $text ~~ s:g/ <!after '::'> Gtk (\w+) /B<Gnome::Gtk4::$0>/; }
      when Gdk4 { $text ~~ s:g/ <!after '::'> Gdk (\w+) /B<Gnome::Gdk4::$0>/; }
  #    when  { $text ~~ s:g/ <!after '::'> G.. (\w+) /B<Gnome::G..::$0>/; }
    }
#  }


  $text ~~ s:g:i/ true /True/;
  $text ~~ s:g:i/ false /False/;

  $text
}