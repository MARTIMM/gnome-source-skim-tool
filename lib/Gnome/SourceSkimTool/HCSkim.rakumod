use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::HCSkim;

#-------------------------------------------------------------------------------
submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method guess-parent-classes ( ) {

  # if given by user
  if $*class-is-top {
    $*raku-parent-classname = 'TopLevelClassSupport';
    $*raku-parent-modname = 'N';
  }

  else {
    # a parent class is defined in a struct of the C-include file
    # e.g. "GtkBinClass  parent_class;"
    $*include-content ~~ m/
      ^^ \s* $<lib-parent> = [<alnum>+] \s+ 'parent_class'
    /;

    # set the raku classname of its parent if any
    $*raku-parent-classname = ($<lib-parent> // '').Str;

    # check it out via version and then by the name
    if $*use-doc-source ~~ Gtk3 {
      if $*raku-parent-classname ~~ /^ Gtk / {
        $*raku-parent-modname = 'Gtk3';
      }

      elsif $*raku-parent-classname ~~ /^ Gdk / {
        $*raku-parent-modname = 'Gdk3';
      }
    }

    elsif $*use-doc-source ~~ Gtk4 {
      if $*raku-parent-classname ~~ /^ Gtk / {
        $*raku-parent-modname = 'Gtk4';
      }

      elsif $*raku-parent-classname ~~ /^ Gdk / {
        $*raku-parent-modname = 'Gdk4';
      }
    }

    # GApplication is a parent from Gio module
    elsif $*raku-parent-classname ~~ /^ GApplicationClass / {
      $*raku-parent-modname = 'Gdk4';
    }

    # GObject is a parent from GObject module
    elsif $*raku-parent-classname ~~ /^ GObjectClass / {
      $*raku-parent-modname = 'Gdk4';
    }

    $*raku-parent-classname ~~ s/^ [ Gtk || Gdk || G ] //;
    $*raku-parent-classname ~~ s/ Class $//;
  }
}

use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
# Descriptions are found in SECTION doc of C-code content. In version 4 there
# is no SECTION, nor short @description nor @title but can be found at the
# first /** … */ comment block of the c-code. The first /** … */ comment
# block this happens to be the same for the version 3.
method get-descriptions ( --> Hash ) {

  # it is possible that there are only include files
  return ( '', '', '') unless ?$*source-content;

  # search for first doc block
  $*source-content ~~ m/ '/**' .*? SECTION ':' .*? '*/' /;
  return ( '', '', '') unless ?$/;

  # get in string and remove from c-code content
  my Str $section-doc = $/.Str;
  $*source-content ~~ s/ $section-doc //;

  # get short description and remove it from $section-doc
  $section-doc ~~ m:i/
      ^^ \s+ '*' \s+ '@Short_description:' \s*
      $<text> = [
        [ \s+ '*' \s+ [ <-[@]> || \S ] .*? \n ] ||
        [ .*? \n ]
      ]
  /;
  my Str $short-description = ~($<text>//'');
  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ '@Short_description:'
                       \s* $short-description//;

  $short-description ~~ s:g/ \n\s* '*' \s* / /;
#note 'sd: ', $short-description;
  $short-description = self.cleanup-source-doc($short-description);


  # get see also and remove it from $section-doc
  $section-doc ~~ m:i/ ^^ \s+ '*' \s+ '@See_also:' \s* $<text> = [.*?] $$ /;
  my Str $see-also = ~($<text>//'');
  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ '@See_also:' [.*?] \n //;

  # cleanup rest
#note "get-section 0: $section-doc";

  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ 'SECTION:' [.*?] \n //;
  $section-doc ~~ s:i/ ^^ \s+ '*' \s+ '@Title:' [.*?] \n //;
  $section-doc = self.cleanup-source-doc($section-doc);
  $section-doc ~~ s:i/ '#' \s+ CSS \s+ nodes
                     /\n\n=head2 Css Nodes\n\n/;

#note "get-section 1: $section-doc";
  $section-doc ~~ s:g:i/ ^^ '#' '#'? \s+ /\n=head2 /;
#  $section-doc ~~ s:g/ \n\s* '*' \s* / /;


#note "doc 2: ", $section-doc;

  ( self.primary-doc-changes($section-doc),
    self.primary-doc-changes($short-description),
    (?$see-also ?? "=head2 See Also\n\n" ~ self.primary-doc-changes($see-also) !! '')
  )
}

#-------------------------------------------------------------------------------
method get-doc-attributes ( Str $doc is rw --> Hash ) {
  my Hash $attr-doc = %();

}

#-------------------------------------------------------------------------------
method cleanup-source-doc (  ) {
}

#-------------------------------------------------------------------------------
method primary-doc-changes (  ) {
}