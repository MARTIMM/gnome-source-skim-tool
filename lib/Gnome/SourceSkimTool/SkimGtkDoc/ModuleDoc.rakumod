=begin pod

=head1 Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc

=head2 Description

=end pod

use Gnome::SourceSkimTool::ConstEnumType;

use XML::Actions;
use XML;
use YAMLish;

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


#has Str $!section-prefix-name;
has Int $!refsect-level;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  $!description = %();
  $!functions = %();
  $!signals = %();
  $!properties = %();
  $!types = %();
}

#-------------------------------------------------------------------------------
method refsect1:start ( Array $parent-path, :$id --> ActionResult ) {
  return Truncate unless ?$id;

  given $id {
    when "$*gnome-class\.description" {
      $!phase = Description;
      $!description = '';
      $!refsect-level = 1;

      note "\n$*gnome-class description" if $*verbose;
    }

    when "$*gnome-class\.functions_details" {
      $!phase = Functions;

      note "\n$*gnome-class functions" if $*verbose;
    }

    when "$*gnome-class\.signal-details" {
      $!phase = Signals;

      note "\n$*gnome-class signals" if $*verbose;
    }

    when "$*gnome-class\.property-details" {
      $!phase = Properties;

      note "\n$*gnome-class properties" if $*verbose;
    }
 
    when "$*gnome-class\.other_details" {
      $!phase = Types;

      note "\n$*gnome-class other details" if $*verbose;
    }
  }

  Recurse
}

#-------------------------------------------------------------------------------
method refsect1:end ( Array $parent-path, :$id ) {
  given $!phase {
    when Description {
      $!description = self!scan-for-unresolved-items(
        self!cleanup( $!description, :trim)
      );
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
      my Str $rsp = $*work-data<raku-sub-prefix>;
      $!function-name ~~ s/^ $rsp '-' //;
      note "  function $!function-name" if $*verbose;

      $!functions{$!function-name} = %();
      $!fh := $!functions{$!function-name};

      # mark info as init method when 'new' is in the funcion name
      $!fh<init> = $!function-name ~~ m/ <|w> new <|w> /.Bool;
      self!function-scan($parent-path[*-1].nodes);

      $ar = Truncate;
    }

    when Signals {
      return Truncate if %attribs<role> ne 'signal';

      $!signal-name = %attribs<id>;
      $!signal-name ~~ s/^ $*gnome-class '-' //;
      note "  signal $!signal-name" if $*verbose;

      $!signals{$!signal-name} = %();
      $!fh := $!signals{$!signal-name};
      self!signal-scan($parent-path[*-1].nodes);
      $!fh<doc><signal> = self!cleanup( $!fh<doc><signal>, :trim);

      $ar = Truncate;
    }

    when Properties {
      return Truncate if %attribs<role> ne 'property';

      $!property-name = %attribs<id>;
      $!property-name ~~ s/^ $*gnome-class '--' //;
      note "  property $!property-name" if $*verbose;

      $!properties{$!property-name} = %();
      $!fh := $!properties{$!property-name};
      self!property-scan($parent-path[*-1].nodes);
      $!fh<doc><property> = self!cleanup( $!fh<doc><property>, :trim);

      $ar = Truncate;
    }

    when Types {
      # skip structure info
      return Truncate if %attribs<role> eq 'struct';

      $!type-name = %attribs<id>;
      note "  type $!type-name" if $*verbose;

      $!types{$!type-name} = %();
      $!fh := $!types{$!type-name};
      self!type-scan($parent-path[*-1].nodes);
      $!fh<type> = self!cleanup( $!fh<type>, :trim);

      $ar = Truncate;
    }
  }

  $ar
}

#-------------------------------------------------------------------------------
method refsect2:end ( Array $parent-path, :$id ) {
  $!refsect-level = 1;

  given $!phase {
    when Functions {
      $!fh<doc><function> = ?$!fh<doc><function>
        ?? self!scan-for-unresolved-items(
             self!cleanup( $!fh<doc><function>, :trim)
           )
        !! ''
    }
 
    when Signals {
      $!fh<doc><signal> = ?$!fh<doc><signal>
        ?? self!scan-for-unresolved-items(
             self!cleanup( $!fh<doc><signal>, :trim)
           )
        !! ''
    }

    when Properties {
      $!fh<doc><property> = ?$!fh<doc><property>
        ?? self!scan-for-unresolved-items(
             self!cleanup( $!fh<doc><property>, :trim)
           )
        !! ''
    }

    when Types {
      $!fh<type> = ?$!fh<type>
         ?? self!scan-for-unresolved-items(self!cleanup( $!fh<type>, :trim))
         !! '';
    }
  }
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
      $!description ~= $name; #self!scan-for-unresolved-items($name);
      $ar = Truncate;
    }
  }

  $ar
}

#-------------------------------------------------------------------------------
method xml:text ( Array $parent-path, Str $txt ) {
  given $!phase {
    when Description {
      $!description ~= $txt; #self!scan-for-unresolved-items($txt);
    }
  }
}

#-------------------------------------------------------------------------------
# called from <refsect2 id="some function" role="function">
method !function-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
#note "$?LINE: $n.name()";
      given $n.name {
        when 'primary' {
          $!fh<native-name> = self!get-text($n.nodes);
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
          # skip paragraphs with a role. those are e.g. used for 'since' info
          if $!phase ~~ Functions and $!func-phase ~~ OutOfPhase and
             $n.attribs<role>:!exists {

            $!fh<doc><function> = self!get-text($n.nodes);
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
      }
    }
  }
}

#-------------------------------------------------------------------------------
# called from <refsect2 id="some signal" role="signal">
method !signal-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
      given $n.name {
        when 'primary' {
          my Str $text = self!get-text($n.nodes);
          my Str $section-prefix-name = $*work-data<sub-prefix>;
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
            my Str $text = self!get-text($n.nodes);
            $text ~~ s:g/ '*' \s* /* /;

            # split on spaces to get an array of the argument declaration
            $!fh<parameters>[$!param-count].push: |($text.split(/\s+/));
          }

          elsif $!func-phase ~~ OutOfPhase {
            my XML::Node $parent = $n.parent;
            if $parent.name eq 'link' {
              my Str $linkend = $parent.attribs<linkend>;
              my Str $text = self!scan-for-unresolved-items($linkend);
              $!fh<parameters>[$!param-count].push: |($text.split(/\s+/));
            }
          }
        }

        when 'para' {
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
          }

          $!param-count++;
          $!fh<parameters>[$!param-count] = [];

          if $text ~~ m/^ ',' $<t> = (.+?) $/ {
            # text after comma
            $text = $<t>.Str;
            $text ~~ s:g/ '*' \s* /* /;

            # when the closing bracket was attached to the word, remove it
            $text ~~ s/ ')' //;
            
            $!fh<parameters>[$!param-count][*-1] ~= ' ' ~ $text;
          }
        }

        else {
          # when the closing bracket was attached to the word, remove it
          $text ~~ s/ ')' //;
          $!fh<parameters>[$!param-count][*-1] ~= $text;
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

      given $n.name {
        when 'primary' {
          my Str $text = self!get-text($n.nodes);
          my Str $section-prefix-name = $*work-data<sub-prefix>;
          $text ~~ s/ $section-prefix-name ':' //;
          $!fh<native-name> = $text;
        }

        when 'programlisting' {
          $!func-phase = FApi;
          $!fh<doc> = %();
          self!property-scan($n.nodes);
          $!func-phase = OutOfPhase;
        }

        when 'type' {
          if $!func-phase ~~ FApi {
            $!fh<type> = self!get-text($n.nodes);
          }
        }
        
        when 'para' {
          if $!phase ~~ Properties and $!func-phase ~~ OutOfPhase {
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
              $!fh<doc><property> ~= ' ' ~ $propdoc;
                #' ' ~ self!scan-for-unresolved-items($propdoc);
            }
          }
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
          self!property-scan($n.nodes);
        }
      }
    }
  }
}

#-------------------------------------------------------------------------------
# called from
#   <refsect2 id="some type" role="enum">
method !type-scan ( @nodes ) {

  for @nodes -> $n {
    if $n ~~ XML::Element {
      given $n.name {
        when 'primary' {
          my Str $text = self!get-text($n.nodes);
          $!fh<native-name> = $text;
        }
        
        when 'para' {
          if $!phase ~~ Types and $!func-phase ~~ OutOfPhase {
            my Str $typedoc = self!get-text($n.nodes);

            # skip since
            if $typedoc ~~ m/^ Since ':' / { }

            else {
              $!fh<type> ~= ' ' ~ $typedoc; #self!scan-for-unresolved-items($typedoc);
            }
          }
        }

        when 'refsect3' {
          $!refsect-level = 3;

          my %attribs = $n.attribs;

          if %attribs<id> eq "$!type-name\.members" {
            $!func-phase = FApiDoc;
            $!fh<doc> = [];
            $!fh<names> = [];
            self!type-scan($n.nodes);
            $!func-phase = OutOfPhase;
          }

          $!refsect-level = 2;
        }

        when 'entry' {
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

#      elsif $literal and $n.name eq 'literal' {
#        $text ~= self!scan-for-unresolved-items(self!get-text($n.nodes));
#      }

      # skip any nodes mentioned in the skip list
      elsif $n.name !~~ any(@skip) {
        $text ~= self!get-text($n.nodes);
      }
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method !linked-items ( Str $text is copy --> Str ) {
#note "$?LINE: $text, $*gnome-class, $*work-data<sub-prefix>";

  my Str $section-prefix-name = $*work-data<sub-prefix>;
  if $text ~~ m/ $section-prefix-name / {
    $text ~~ s/ $section-prefix-name '-' //;
  }

  else {
    my Str ( $class, $rest) = $text.split( '-', 2);
    with $*gnome-package {
      when Gtk3 { $class ~~ s:g/ Gtk (\w+) /Gnome::Gtk3::$0/; }
      when Gdk3 { $class ~~ s:g/ Gdk (\w+) /Gnome::Gdk3::$0/; }
      when Gtk4 { $class ~~ s:g/ Gtk (\w+) /Gnome::Gtk4::$0/; }
      when Gdk4 { $class ~~ s:g/ Gdk (\w+) /Gnome::Gdk4::$0/; }
      when Glib { $class ~~ s:g/ Glib (\w+) /Gnome::Glib::$0/; }
      when GObject { $class ~~ s:g/ GObject (\w+) /Gnome::GObject::$0/; }
      when Gio { $class ~~ s:g/ Gio (\w+) /Gnome::Gio::$0/; }
      when Pango { $class ~~ s:g/ Pango (\w+) /Gnome::Pango::$0/; }
      when Cairo { $class ~~ s:g/ Cairo (\w+) /Gnome::Cairo::$0/; }
    }

    if ?$rest and ?$class {
      $text = "$rest defined in B<$class>";
    }

    else {
      $text = '';
    }
  }

  ?$text ?? " I<$text> " !! '';
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
#note "text is empty: $!phase, $!func-phase, ", callframe(3).gist if !$text;

  my Str $section-prefix-name = $*work-data<sub-prefix>;

  # signals
  if $text ~~ m/ <|w> $section-prefix-name '::' \w+ / {
    $text ~~ s:g/ <|w> $section-prefix-name '::' (<[-\w]>+) /I<signal $0>/;
  }

  elsif $text ~~ m/ <|w> \w+ '::' \w+ / {
    $text ~~ s:g/ <|w> (\w+) '::' (<[-\w]>+) / I<signal $1 defined in $0>/;
  }

  elsif $text ~~ m/ <|w> '::' \w+ / {
    $text ~~ s:g/ <|w> '::' (<[-\w]>+) / I<signal $0>/;
  }


  # properties
  if $text ~~ m/ <|w> $section-prefix-name ':' \w+ / {
    $text ~~ s:g/ <|w> $section-prefix-name ':' (<[-\w]>+) /I<property $0>/;
  }

  elsif $text ~~ m/ <|w> \w+ ':' \w+ / {
    $text ~~ s:g/ <|w> (\w+) ':' (<[-\w]>+) / I<property $1 defined in $0>/;
  }

  elsif $text ~~ m/ <|w> ':' \w+ / {
    $text ~~ s:g/ <|w> ':' (<[-\w]>+) / I<property $0>/;
  }


  # css
  if $text ~~ m/ \s '.' / {
    $text ~~ s:g/ \s '.' (<[-\w]>+) / C<.$0>/;
  }

  # functions
  if $text ~~ m/ '()' \s / {
#print "$?LINE: text has (): $text";
    my Str $sub-prefix = $*work-data<sub-prefix>;
    if $text ~~ m/^ $sub-prefix / {
      $text ~~ s:g/^ $sub-prefix '_' (\w+) '()' /.$0\(\)/;
    }

    if $text ~~ m/ <|w> new <|w> / {
      $text ~~ s:g/ new '_' (\w+) '()' /.new(:$0)/;
    }
      
#note " --> $text";
  }

  # classes
  with $*gnome-package {
    # <!after '::'> is needed to keep previously converted text correct
    when Gtk3 { $text ~~ s:g/ <!after '::'> Gtk (\w+) /B<Gnome::Gtk3::$0>/; }
    when Gdk3 { $text ~~ s:g/ <!after '::'> Gdk (\w+) /B<Gnome::Gdk3::$0>/; }
    when Gtk4 { $text ~~ s:g/ <!after '::'> Gtk (\w+) /B<Gnome::Gtk4::$0>/; }
    when Gdk4 { $text ~~ s:g/ <!after '::'> Gdk (\w+) /B<Gnome::Gdk4::$0>/; }
    when Glib { $text ~~ s:g/ <!after '::'> Glib (\w+) /B<Gnome::Glib::$0>/; }
    when GObject {
      $text ~~ s:g/ <!after '::'> GObject (\w+) /B<Gnome::GObject::$0>/;
    }
    when Gio { $text ~~ s:g/ <!after '::'> Gio (\w+) /B<Gnome::Gio::$0>/; }
    when Pango {
      $text ~~ s:g/ <!after '::'> Pango (\w+) /B<Gnome::Pango::$0>/;
    }
    when Cairo {
      $text ~~ s:g/ <!after '::'> Cairo (\w+) /B<Gnome::Cairo::$0>/;
    }
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

#-------------------------------------------------------------------------------
method save-module ( Str:D $fname ) {

  $fname.IO.spurt(
    save-yaml(
      %( :description($!description),
         :functions($!functions),
         :signals($!signals),
         :properties($!properties),
         :types($!types),
       )
    )
  );
}

#-------------------------------------------------------------------------------
method load-module ( Str:D $fname ) {

  if $fname.IO ~~ :r {
    my Hash $h = load-yaml($fname.IO.slurp);

    $!description = $h<description>;
    $!functions = $h<functions>;
    $!signals = $h<signals>;
    $!properties = $<properties>;
    $!types = $h<types>;
  }
}
