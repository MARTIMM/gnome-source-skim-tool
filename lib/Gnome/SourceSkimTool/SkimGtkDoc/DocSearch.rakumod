use Gnome::SourceSkimTool::ConstEnumType;

use XML::Actions;
use XML;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SkimGtkDoc::DocSearch;
also is XML::Actions::Work;

enum Phase <OutOfPhase Description Functions Signals Properties>;
has Phase $!phase = OutOfPhase;
has Str $.description;
has Hash $.functions;
has Str $!function-name;
has Int $!param-count;

has Hash $!fh;


has Str $!section-prefix-name;
has Int $!refsect-level;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  # Devise the section name using the provided subroutine prefix.
  # Something like 'gtk_button' or 'gio_file'. The examples must
  # become 'gtk3-GtkButton' or 'gio-GFile'.
  my Str $sp = $*sub-prefix;
  $sp .= tc;
  $sp ~~ s:g/ '_'(\w) /$0.tc()/;
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

  $!description = '';
  $!functions = %();
}

#-------------------------------------------------------------------------------
method refsect1:start ( Array $parent-path, :$id --> ActionResult ) {
  return Truncate unless ?$id;

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
  #my ActionResult $ar = Recurse;
  $!refsect-level = 2;

  given $!phase {
    when Functions {
      return Truncate unless %attribs<role> eq 'function';
      if (%attribs<condition>//'') eq 'deprecated' {
        note "function %attribs<id> is deprecated";
        return Truncate;
      }

      $!function-name = %attribs<id>;
      $!functions{$!function-name} = %();
      $!fh := $!functions{$!function-name};
      $!fh<init> = $!function-name ~~ m/ <|w> new <|w> /.Bool;

#note "$?LINE: $!function-name init: $!fh<init>";
    }
  }

  Recurse
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
      for $parent-path[*-1].nodes -> $n {
        next unless $n ~~ XML::Text;
        $!description ~= $n.string;
      }
      $!description ~= "\n\n";
      $ar = Truncate;
    }
  }

  $ar
}

#-------------------------------------------------------------------------------
method primary:start ( Array $parent-path --> ActionResult ) {
  my ActionResult $ar = Recurse;

  given $!phase {
    when Functions {
      $!functions{$!function-name}<native-name> = '';
      for $parent-path[*-1].nodes -> $n {
        next unless $n ~~ XML::Text;
        $!functions{$!function-name}<native-name> ~= $n.string;
      }
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

    when Functions {
      if 'programlisting' ~~ any($parent-path[0..*-1]>>.name) {
        $!fh<returnvalue> = '' unless $!fh<returnvalue>:exists;
        $!fh<returnvalue> ~= $txt if $parent-path[*-1].name eq 'returnvalue';
      }

      # Punctuation in argument list;
      #  '(' start list ≡ init,
      #  ',' next argument
      #  ');' end list
      if 'programlisting' ~~ any($parent-path[0..*-1]>>.name)
            and $txt ~~ m/ '(' / {
        $!fh<parameters> = [];
        $!param-count = 0;
        $!fh<parameters>[$!param-count] = [];
      }

      elsif 'programlisting' ~~ any($parent-path[0..*-1]>>.name)
            and $txt ~~ m/ ',' / {
        $!param-count++;
        $!fh<parameters>[$!param-count] = [];
      }

#      elsif 'programlisting' ~~ any($parent-path[0..*-1]>>.name)
#            and $txt ~~ m/ ');' / {
#      }

      # if there is a parent element called 'parameter'
      elsif 'parameter' ~~ any($parent-path[0..*-1]>>.name) {
        $!fh<parameters>[$!param-count].push: $txt;
      }
    }
  }
}

#-------------------------------------------------------------------------------
method programlisting:start ( Array $parent-path, *%attribs ) {
note $?LINE;

  given $!phase {
    when Functions {
#`{{
      my XML::Element $e = $parent-path[*-1];
      for $e.nodes {
        when XML::Element {
note $?LINE, ', n=', .name;
          if .name eq 'returnvalue' {
            $!functions{$!function-name}<returnvalue> = '';
            for .nodes -> $t {
              next unless $t ~~ XML::Text;
              $!functions{$!function-name}<returnvalue> ~= $t.Str;
            }
          }
        }

        when XML::Text {
note $?LINE, ', t=', .Str;
        }
      }
}}
    }
  }
}


#-------------------------------------------------------------------------------
method !cleanup ( Str $text is copy --> Str ) {
#  $text = self!scan-for-unresolved-items($text);

  $text ~~ s:g/ ' '+ / /;
  $text ~~ s:g/ <|w> \n <|w> / /;
  $text ~~ s:g/ \n ** 3..* /\n\n/;

  $text
}

#-------------------------------------------------------------------------------
method !scan-for-unresolved-items ( Str $text is copy --> Str ) {

  # signals
  if $text ~~ m/ \s '::' / {
note $?LINE ~ 'text has ::';
  }

  # properties
  if $text ~~ m/ \s ':' / {
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

  $text
}