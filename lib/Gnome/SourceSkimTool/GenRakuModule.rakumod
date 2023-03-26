
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::SkimGtkDoc;
use Gnome::SourceSkimTool::ConstEnumType;

use XML;
use XML::XPath;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenRakuModule:auth<github:MARTIMM>;

has XML::XPath $!xpath;
has Hash $!object-maps;
has Hash $!other-work-data;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
#TODO add rules for gdkPixbuf, etc.

  # get workdata for other gnome packages
  my Gnome::SourceSkimTool::Prepare $p .= new;
  $!other-work-data = %();
  if $*gnome-package.Str ~~ / '3' $/ {
    $!other-work-data<Gtk> = $p.prepare-work-data(Gtk3);
    $!other-work-data<Gdk> = $p.prepare-work-data(Gdk3);
  }

  else {
    $!other-work-data<Gtk> = $p.prepare-work-data(Gtk4);
    $!other-work-data<Gdk> = $p.prepare-work-data(Gdk4);
    $!other-work-data<Gsk> = $p.prepare-work-data(Gsk4);
  }

  $!other-work-data<Atk> = $p.prepare-work-data(Atk);
  $!other-work-data<Glib> = $p.prepare-work-data(Glib);
  $!other-work-data<Gio> = $p.prepare-work-data(Gio);
  $!other-work-data<GObject> = $p.prepare-work-data(GObject);
  $!other-work-data<Pango> = $p.prepare-work-data(Pango);
  $!other-work-data<Cairo> = $p.prepare-work-data(Cairo);

  # get object maps
  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;
  $!object-maps = %();
  $!object-maps<Atk> = $s.load-map($!other-work-data<Atk><gir-module-path>);
  $!object-maps<Gtk> = $s.load-map($!other-work-data<Gtk><gir-module-path>);
  $!object-maps<Gdk> = $s.load-map($!other-work-data<Gdk><gir-module-path>);
  $!object-maps<Gsk> = ?$!other-work-data<Gsk> 
                       ?? $s.load-map($!other-work-data<Gsk><gir-module-path>)
                       !! %();
  $!object-maps<Glib> = $s.load-map($!other-work-data<Glib><gir-module-path>);
  $!object-maps<Gio> = $s.load-map($!other-work-data<Gio><gir-module-path>);
  $!object-maps<GObject> =
    $s.load-map($!other-work-data<GObject><gir-module-path>);
  $!object-maps<Pango> = $s.load-map($!other-work-data<Pango><gir-module-path>);
  $!object-maps<Cairo> = $s.load-map($!other-work-data<Cairo><gir-module-path>);

  # load data for this module
  $!xpath .= new(:file($*work-data<gir-module-file>));
}

#-------------------------------------------------------------------------------
method generate-raku-module ( ) {
  my $module-doc = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:";
    use v6;
    {HLSEPARATOR}
    RAKUMOD
  
  $module-doc ~= self!get-description;

#  self!inheritable;
#  self!get-constructors;
#  self!make-build;

#  $module-doc ~= self!get-methods;
#  $module-doc ~= self!get-signals;
#  $module-doc ~= self!get-properties;

  $*work-data<raku-module-file>.IO.spurt($module-doc);
}

#-------------------------------------------------------------------------------
method generate-raku-module-test ( ) {
  my $module-test-doc = '';

  $*work-data<raku-module-test-file>.IO.spurt($module-test-doc);
}

#-------------------------------------------------------------------------------
method !get-description ( --> Str ) {
  my Str $doc = "\n=head1 Description\n";

  #$doc ~= self!set-example-image;

  $doc ~= $!xpath.find('//class[@name="' ~ $*gnome-class ~ '"]/doc/text()').Str;

  #$doc ~= self!set-declaration;
  #$doc ~= self!set-uml;
  #$doc ~= self!set-inherit-example;
  #$doc ~= self!set-example;

  $doc = self!modify-text($doc);
  #$doc = self!cleanup($doc);

  qq:to/RAKUMOD/;
    =begin pod
    =head1 $*work-data<raku-class-name>

    $doc
    =end pod
    RAKUMOD
}

#-------------------------------------------------------------------------------
method !make-init ( --> Str ) {
  my Str $doc = '';

  $doc
}

#-------------------------------------------------------------------------------
method !get-constructors ( --> Str ) {
  my Str $doc = '';

  $doc
}

#-------------------------------------------------------------------------------
method !get-methods ( --> Str ) {
  my Str $doc = '';

  $doc
}



#-------------------------------------------------------------------------------
method !modify-text ( Str $text is copy --> Str ) {
#note "text is empty: $!phase, $!func-phase, ", callframe(3).gist if !$text;
note 'description';
  $text = self!modify-xml($text);

#  $text = self!modify-signals($text);
#  $text = self!modify-properties($text);
#  $text = self!modify-css($text);
#  $text = self!modify-functions($text);
  $text = self!modify-classes($text);
#  $text = self!modify-examples($text);

  $text = self!modify-rest($text);

  $text;
}

#-------------------------------------------------------------------------------
# Modify text '::sig-name'
method !modify-signals ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<sub-prefix>;

  if $text ~~ m/ '#' $section-prefix-name '::' \w+ / {
    $text ~~ s:g/ '#' $section-prefix-name '::' (<[-\w]>+) /I<signal $0>/;
  }

  elsif $text ~~ m/ '#' \w+ '::' \w+ / {
    $text ~~ s:g/ '#' (\w+) '::' (<[-\w]>+) / I<signal $1 defined in $0>/;
  }

  elsif $text ~~ m/ '#' '::' \w+ / {
    $text ~~ s:g/ '#' '::' (<[-\w]>+) / I<signal $0>/;
  }

  $text;
}

#-------------------------------------------------------------------------------
method !modify-properties ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<sub-prefix>;

  if $text ~~ m/ '#' $section-prefix-name ':' \w+ / {
    $text ~~ s:g/ '#' $section-prefix-name ':' (<[-\w]>+) /I<property $0>/;
  }

  elsif $text ~~ m/ '#' \w+ ':' \w+ / {
    $text ~~ s:g/ '#' (\w+) ':' (<[-\w]>+) / I<property $1 defined in $0>/;
  }

  elsif $text ~~ m/ '#' ':' \w+ / {
    $text ~~ s:g/ '#' ':' (<[-\w]>+) / I<property $0>/;
  }

  $text;
}

#-------------------------------------------------------------------------------
method !modify-css ( Str $text is copy --> Str ) {

  $text ~~ s:g/ \s '.' (<[-\w]>+) / C<.$0>/ if $text ~~ m/ \s '.' \w /;
  $text ~~ s:g/ \s '#' (<[-\w]>+) / C<#$0>/ if $text ~~ m/ \s '#' \w /;

  $text;
}

#-------------------------------------------------------------------------------
method !modify-functions ( Str $text is copy --> Str ) {

  my Str $sub-prefix = $*work-data<sub-prefix>;

  $text ~~ s:g/ $sub-prefix new '_' (\w+) '()' /C<.new(:$0)>/;
  $text ~~ s:g/ $sub-prefix (\w+) '()' /C<.$0\(\)>/;

  $text;
}

#-------------------------------------------------------------------------------
method !modify-classes ( Str $text is copy --> Str ) {
note 'classes';

  # Do not modify class names whithin example code. C code is to be changed
  # later anyway and on other places like in XML examples it must be kept as is.
  my Int $ex-counter = 0;
  my Hash $examples = %();
  while $text ~~ m/ $<example> = [ '|[' .*? ']|' ] / {
    my Str $example = $<example>.Str;
    my Str $ex-key = '____EXAMPLE____' ~ $ex-counter++;
    $examples{$ex-key} = $example;
    $text ~~ s/ $example /$ex-key/;
  }

  # When classnames are found (or not) a zero width space is inserted just
  # before the word to prevent finding this word (or part of it again when not
  # substituted. See also https://invisible-characters.com/.
  my Regex $r = / '#'? $<class-name> = [
                     <!after ["\x200B" || '::']>
                     [ Atk || Gtk || Gdk || Gsk ||
                       PangoCairo || Pango || Cairo || G
                     ]
                     \w+
                  ]
                /;
note "regex: $r.gist()";

  while $text ~~ $r {
    my Str $class-name = $<class-name>.Str;
note "find $class-name";
    my Str $raku-name = self.search-name($class-name);

    if ?$raku-name {
      $text ~~ s:g/ '#'? $class-name /B<\x200B$raku-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $class-name /\x200B$class-name/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;

  # Subtitute the examples back into the text
  for $examples.keys -> $ex-key {
    $text ~~ s/ $ex-key /$examples{$ex-key}/;
  }

  $text;
}

#-------------------------------------------------------------------------------
method search-name ( Str $name --> Str ) {
print "$?LINE: search for $name -> ";
  my Str ( $rname, $pname);
  for <Gtk Gdk Gsk Glib Gio GObject Pango Cairo PangoCairo> -> $map-name {
    $rname = $!object-maps{$map-name}{$name}<rname> // '';
    if ?$rname {
      $pname = $!other-work-data{$map-name}<raku-package>;
print " \($map-name)";
      last;
    }
  }

say " {$rname//'-'}";
  $rname//''
}

#-------------------------------------------------------------------------------
# convert |[ … ]| marks. Must be processed at the end because other
# modifications may depend on those marks
method !modify-examples ( Str $text is copy --> Str ) {

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="xml"' \s* '-->' 
              /=begin comment\nFollowing text is XML\n=begin code\n/;

  $text ~~ s:g/^^ '|[<!-- language="plain" -->'
              /=begin comment\n=begin code/;

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="C"' \s* '-->' 
              /=begin comment\n=begin code/;

  $text ~~ s:g/^^ ']|' /=end code\n=end comment\n/;

  $text;
}

#-------------------------------------------------------------------------------
# Modify xml remnants
method !modify-xml ( Str $text is copy --> Str ) {
  
  # xml escapes
  $text ~~ s:g/ '&lt;' /</;
  $text ~~ s:g/ '&gt;' />/;
  $text ~~ s:g/ [ '&#160;' || '&nbsp;' ] / /;

  $text;
}

#-------------------------------------------------------------------------------
# Modify rest
method !modify-rest ( Str $text is copy --> Str ) {

  # variable changes
  $text ~~ s:g/ '%' TRUE /C<True>/;
  $text ~~ s:g/ '%' FALSE /C<False>/;
  $text ~~ s:g/ '%' NULL /C<Nil>/;

  # sections
  $text ~~ s:g/^^ '#' \s+ (\w) /=head2 $0/;

  $text;
}









#`{{
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

}}







=finish

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
use Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex;
use Gnome::SourceSkimTool::Prepare;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenRakuModule:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare;
constant \ModuleDoc = Gnome::SourceSkimTool::SkimGtkDoc::ModuleDoc;
constant \ApiIndex = Gnome::SourceSkimTool::SkimGtkDoc::ApiIndex;

has Prepare $!preparation .= new;
has ModuleDoc $!module-docs handles <
  description functions signals properties types
>;
has ApiIndex $!api-docs handles <objects>;

# holds all content
has Str $!raku-test;

# holds build method only and native new functions
has Str $!build-method;
has Str $!build-doc;

# holds all methods and native functions
has Str $!methods;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {
  die "A Raku module name is missing" unless ?$*gnome-class;
  $!preparation .= new;

  $!module-docs .= new;
  $!module-docs.load-module($*work-data<skim-module-result>);

  $!api-docs .= new;
  $!api-docs.load-objects;
  
  $!raku-test = '';
}

#-------------------------------------------------------------------------------
method generate ( ) {
  self!generate-methods;
}

#-------------------------------------------------------------------------------
method !generate-methods ( ) {
  $!methods = '';
  $!build-method = '';
  $!build-doc = q:to/EOBUILD/;
    #-------------------------------------------------------------------------------
    =begin pod
    =head1 Methods
    =head2 new
    EOBUILD

  my Hash $functions := $!module-docs.functions;
  for $functions.keys.sort -> $fname {
    if $fname ~~ m/ <|w> new <|w> / {
      self!add-new-function( $fname, $functions{$fname});
    }

    else {
      self!add-method( $fname, $functions{$fname});
    }
  }

  $!build-doc ~= q:to/EOBUILD/;
    =end pod

    =head3 :native-object

    Create a RAKU-CLASS-NAME object using a native object from elsewhere. See also B<Gnome::N::TopLevelClassSupport>.

      multi method new ( N-GObject :$native-object! )


    =head3 :build-id

    Create a RAKU-CLASS-NAME object using a native object returned from a builder. See also B<Gnome::GObject::Object>.

      multi method new ( Str :$build-id! )

    =end pod
    EOBUILD
}

#-------------------------------------------------------------------------------
method !add-new-function ( Str $fname, Hash $fdata ) {
  #$!build-method

#  my Str $sub-doc = $fdata<doc><function>;
  my Str $native-sub-name = '_' ~ $fdata<native-name>;
  my Str $args = '';
  my Str $returns = '';
  my Str $pod-args = '';
  my Str $pod-returns = '';
  my Str $pod-doc-items = '';

  # The native subroutine documentation
  if $fname eq 'new' {
    $!build-doc ~= qq:to/EOBUILD/;

      =head3 default, no options

      $fdata<doc><function>

        multi method new ( )
      EOBUILD
  }

  else {
    $!build-doc ~= qq:to/EOBUILD/;

      =head3 :$fname

      $fdata<doc><function>

        multi method new ( :$fname! )

      EOBUILD
  }

  # The native subroutine declaration
  my Str $sub = qq:to/EOSUB/;

    #-------------------------------------------------------------------------------
    #TM:1:$native-sub-name:

    sub $native-sub-name ( $args $returns )
      is native($*work-data<library>)
      is symbol\('$fdata<native-name>')
      \{ * \}
    EOSUB

  $!methods ~= $sub;
}

#-------------------------------------------------------------------------------
method !add-method ( Str $fname, Hash $fdata ) {
}

#-------------------------------------------------------------------------------
method save ( ) {
  my Str $parent = $!preparation.raku-class-name(
    :gnome-name($!api-docs.objects(){$*gnome-class}<parent>),
    :package($*gnome-package)
  );

  # only inheriting on widget classes except GtkWidget
  my Str $inheriting-doc = '';
  my Str $inheriting-code = '';

  my Str $raku-module = qq:to/EOMODULE/;
    #TL:1:$*work-data<raku-class-name>:

    use v6;

    =begin pod
    $!module-docs.description()
    =end pod

    #-------------------------------------------------------------------------------
    use NativeCall;

    use Gnome::N::NativeLib;
    use Gnome::N::N-GObject;
    use Gnome::N::GlibToRakuTypes;

    # !!!this is not always from the same raku package!!!
    use $parent;
    #use Gnome::Gtk3::Enums;

    #-------------------------------------------------------------------------------
    # See /usr/include/gtk-3.0/gtk/gtkbutton.h
    # https://developer.gnome.org/gtk3/stable/GtkButton.html
    unit class $*work-data<raku-class-name>:auth<github:MARTIMM>;
    also is $parent;
    #also does …;

    #-------------------------------------------------------------------------------
    my Bool \$signals-added = False;


    $!build-doc

    $!build-method

    $!methods
    EOMODULE

  note "Save $*work-data<new-raku-modules>$*gnome-class.rakumod" if $*verbose;
  "$*work-data<new-raku-modules>$*gnome-class.rakumod".IO.spurt($raku-module);

  note "Save $*work-data<new-raku-modules>$*gnome-class.rakutest" if $*verbose;
  "$*work-data<new-raku-modules>$*gnome-class.rakutest".IO.spurt($!raku-test);
}