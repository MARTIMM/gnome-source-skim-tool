
use v6.d;

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Resolve;

use YAMLish;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::DocText:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Resolve $!solve;

my Int $ex-counter;
my Hash $examples;

#-------------------------------------------------------------------------------
submethod BUILD ( ) {

  $ex-counter = 0;
  $examples = %();

  $!solve .= new;
}

#-------------------------------------------------------------------------------
method add-example-code ( Str $example --> Str ) {

  my Str $ex-key = '____EXAMPLE____' ~ $ex-counter.fmt('%03d');
  $ex-counter++;

  # Store example in hash
  $examples{$ex-key} = Q:s:to/EOEX/;
    =begin comment
    $example
    =end comment
    EOEX

#note "$?LINE $ex-key";#, $example, $examples{$ex-key}";
  $ex-key
}

#-------------------------------------------------------------------------------
method modify-text ( Str $file-basename, Str $text is copy --> Str ) {
#  $ex-counter = 0;
#  $examples = %();

  # Gtk version 4 docs have specifications which differ from previous versions.
  # It uses a spec like e.g. '[enum@Gtk.License]'. GtkLicense is defined with
  # AboutDialog and stored in T-AboutDialog.rakumod. Types being enum, method,
  # property, etc.
  #
  # So taking the format like [type @ prefix . name1 c2 name2]
  # Where prefix is only Gtk, Gdk, or Gsk because those are of version 4

  #   type      name1            c2 name2
  # --------------------------------------------------
  #   enum      enum name
  #   struct    structure name
  #   class     class name
  #   func      function name
  #   method    class name       .  function name
  #   signal    class name       :: signal name
  #   property  class name       :  property name
  
  #   iface     interface name


  # Then there is;
  #   `prefix classname`, e.g. `GtkCssSection` (with backticks)
  #   @parameter, e.g. @orientable and @section.
  #   Sometimes the prefix is missing e.g. [method@CssSection.get_parent]

#  my Bool $version4 = ($*gnome-package.Str ~~ m/ 4 || Pango /).Bool;

  # Do not modify text whithin example code. C code is to be changed
  # later anyway and on other places like in XML examples it must be kept as is.
#  my Int $ex-counter = 0;
#  my Hash $examples = %();

  # Some types are better specified in version 4 and can be translated better.
  # Properties are not documented but can be referenced from other docs.
#  if $version4 {
# Seem needed here to ignore error: `Use of Nil in string context`
CONTROL {
  when CX::Warn {
    .resume if .message ~~ m/ 'Use of Nil in string context' /;
    note .gist;
    exit;
    #`{{note .gist; note $text; exit;}}
    #.resume;
  }
}

  say "Convert example code" if  $*verbose;
  # New type code section is using markdown; "``` code ```".
  my token new-type-code-section { <-[\`]>+ }
  my regex new-code-regex { '```' \w* \n <new-type-code-section> '```' }
  while $text ~~ / <new-code-regex> /  {
    my Str $ex-key = self.add-example-code(
      $/<new-code-regex><new-type-code-section>.Str
    );

    # Modify with an example key
    $text ~~ s/ <new-code-regex> /$ex-key/;
  }

  # Old type code section is using; "|[ code ]|".
  my token old-type-code-section { .*? }
  my regex old-code-regex { '|[' <old-type-code-section> ']|' }
  while $text ~~ / <old-code-regex> / {
    my Str $ex-key = self.add-example-code(
      $/<new-code-regex><new-type-code-section>.Str
    );

    # Modify with an example key
    $text ~~ s/ <old-code-regex> /$ex-key/;
  }

  say "Convert signal text" if  $*verbose;
  $text = self!modify-v4signals($text);
  $text = self!modify-signals($text);

  say "Convert property text" if  $*verbose;
  $text = self!modify-v4properties($text);
#  $text = self!modify-properties($text);

  say "Convert constructors and methods text" if  $*verbose;
  $text = self!modify-v4methods($text);

  say "Convert functions text" if  $*verbose;
  $text = self!modify-v4functions($text);
  $text = self!modify-functions($text);

  say "Convert enumerations text" if  $*verbose;
  $text = self!modify-v4enum($text);

  say "Convert structure text" if  $*verbose;
  $text = self!modify-v4structure($text);

  say "Convert loose ends" if  $*verbose;
#  $text = self!modify-v4rest($text);
  $text = self!modify-rest($text);

  # Classes can not be processed before signals, properties and other stuf
  # because of used '::' and ':'
  say "Convert class text" if  $*verbose;
  $text = self!modify-v4classes($text);
  $text = self!modify-classes($text);

  say "Convert variables text" if  $*verbose;
  $text = self!modify-variables($text);

  say "Convert markdown text" if  $*verbose;
  $text = self!modify-markdown-links($text);

  say "Convert XML text" if  $*verbose;
  $text = self!modify-xml($text);

  if ?$examples {
    say "Insert saved example text" if $*verbose;

    # Get examples from file if exists
    my Str $example-file = $file-basename;
    $example-file ~~ s/ \. <-[\.]>+ $/.yaml/;
    $example-file = [~] $*work-data<result-code-sections>, $example-file;
    my Hash $external-examples = %();
    $external-examples = load-yaml($example-file.IO.slurp)
      if $example-file.IO.r;

    # Substitute the examples back into the text before we can finally modify it
    if ?$external-examples {
note "$?LINE $example-file, $examples.keys.elems()";
      for $examples.keys -> $ex-key {
        my Str $t = $external-examples{$ex-key};
note "$?LINE $ex-key, ", ?$t;
        $text ~~ s/ $ex-key /$t/;
      }
    }

    else {
      for $examples.keys -> $ex-key {

        my Str $t = self!modify-xml($examples{$ex-key});
        $text ~~ s/ $ex-key /$t/;

        $external-examples{$ex-key} = $t;
      }

      $example-file.IO.spurt(save-yaml($external-examples));
    }
  }

  self!cleanup($text);
}

#-------------------------------------------------------------------------------
# Convert [signal@Gtk.AboutDialog::activate-link]
method !modify-v4signals ( Str $text is copy --> Str ) {

  my Str $prefix = $*work-data<name-prefix>.tc;
  my Str $gname = $*work-data<gnome-name>;
  $gname ~~ s/^ $prefix //;

  # Signals within same module/class
  $text ~~ s:g/ '[' signal '@' $prefix '.' $gname '::' (<-[\]]>+) ']'
              /I<$0>/;

  # Signals defined elsewhere
  $text ~~ s:g/ '[' signal '@' $prefix '.' (<-[\.]>+) '::' (<-[\]]>+) ']'
              /I<$1 defined in $0>/;

  $text
}

#-------------------------------------------------------------------------------
# Convert [property@Gtk.AboutDialog:system-information]
method !modify-v4properties ( Str $text is copy --> Str ) {
  my token prelude { '[property@' }
  my token package { <-[\.\:\]]>+ }
  my token class { <-[\:\]]>+ }
  my token propname { <-[\]]>+ }
  my regex prop-regex { <prelude> <package> '.' <class> ':' <propname> ']' }
  while $text ~~ m/ <prop-regex> / {
    my Str $package = $/<prop-regex><package>.Str;
    my Str $class = $/<prop-regex><class>.Str;
    my Str $propname = $/<prop-regex><propname>.Str;

    if "$package$class".lc eq $*work-data<gnome-name>.lc {
      $text ~~ s/ <prop-regex> /I<$propname>/;
    }

    else {
      my Hash $h = $!solve.search-name("$package$class");
      my Str $classname = $!solve.set-object-name($h);
      $text ~~ s/ <prop-regex> /I<$propname defined in $classname>/;
    }
  }
 
#`{{
  my Str $prefix = $*work-data<name-prefix>.tc;
  my Str $gname = $*work-data<gnome-name>;
  $gname ~~ s/^ $prefix //;

  # Properties within same module/class
  $text ~~ s:g/ '[' property '@' $prefix '.' $gname ':' (<-[\]]>+) ']'
              /I<$0>/;

  # Properties defined elsewhere
  $text ~~ s:g/ '[' property '@' $prefix '.' (<-[\.]>+) ':' (<-[\]]>+) ']'
              /I<$1 defined in $0>/;
}}

  $text
}

#-------------------------------------------------------------------------------
# Convert [method@Gtk.AboutDialog.set_logo]
# or      [ctor@Gtk.Label.new_with_mnemonic]  ( ctor ≡ constructor )
method !modify-v4methods ( Str $text is copy --> Str ) {

  my Str ( $package, $class, $funcname);

  my token mprelude { '[method@' }
  my token package { <-[\.\]]>+ }
  my token class { <-[\.\]]>+ }
  my token funcname { <-[\]]>+  }
  my regex mfunc-regex { <mprelude> <package> '.' <class> '.' <funcname> ']' }
  while $text ~~ m/ <mfunc-regex> / {
    $package = $/<mfunc-regex><package>.Str;
    $class = $/<mfunc-regex><class>.Str;
    $funcname = $/<mfunc-regex><funcname>.Str;
    $funcname ~~ s:g/ '_' /-/;

    if "$package$class".lc eq $*work-data<gnome-name>.lc {
      $text ~~ s/ <mfunc-regex> /C<.$funcname\(\)>/;
    }

    else {
      my Hash $h = $!solve.search-name($package ~ $class);
      my $classname = $!solve.set-object-name($h);
      $text ~~ s/ <mfunc-regex> /C<.$funcname\(\) in class $classname>/;
    }
  }

  my token cprelude { '[ctor@' }
  my regex cfunc-regex { <cprelude> <package> '.' <class> '.' <funcname> ']' }
  while $text ~~ m/ <cfunc-regex> / {
    $package = $/<cfunc-regex><package>.Str;
    $class = $/<cfunc-regex><class>.Str;
    $funcname = $/<cfunc-regex><funcname>.Str;
    $funcname ~~ s:g/ '_' /-/;
    $funcname = 'new' ~ $*work-data<raku-name>.lc if $funcname eq 'new';

    if "$package$class".lc eq $*work-data<gnome-name>.lc {
      $text ~~ s/ <cfunc-regex> /C<.$funcname\(\)>/;
    }

    else {
      my Hash $h = $!solve.search-name($package ~ $class);
      my $classname = $!solve.set-object-name($h);
      $text ~~ s/ <cfunc-regex> /C<.$funcname\(\) in class $classname>/;
    }
  }



#`{{
  my Str $prefix = $*work-data<name-prefix>;
  my Str $gname = $*work-data<gnome-name>;
  $gname ~~ s:i/^ $prefix //;

  # Methods within same module/class
  while $text ~~ m/ '[method@' $prefix ".$gname." $<func> = <-[\]]>+ ']' / {
    my Str $func = $/<func>.Str;
    $func ~~ s:g/ '_' /-/;
    $text ~~ s/ '[method@' $prefix ".$gname." <-[\]]>+ ']' /C<.$func\(\)>/;
  }

  # Constructors within same module/class
  while $text ~~ m/ '[ctor@' $prefix ".$gname." $<func> = <-[\]]>+ ']' / {
    my Str $func = $/<func>.Str;
    $func ~~ s:g/ '_' /-/;
    $func = 'new' ~ $gname.lc if $func eq 'new';
    $text ~~ s/ '[ctor@' $prefix ".$gname." <-[\]]>+ ']' /C<.$func\(\)>/;
  }

  # Methods defined elsewhere
  while $text ~~ m/ '[method@' $prefix '.' $<class> = <-[\.]>+ 
                                         '.' $<func> = <-[\]]>+ ']' / {
    my Str $class = $/<class>.Str;
    my Str $func = $/<func>.Str;
    $func ~~ s:g/ '_' /-/;
    $text ~~ s/ '[method@' $prefix '.' <-[\.]>+ '.' <-[\]]>+ ']'
              /C<.$func\(\) defined in $class>/;
  }
}}

  $text
}

#-------------------------------------------------------------------------------
# Convert [func@Gtk.show_uri]
method !modify-v4functions ( Str $text is copy --> Str ) {
  my Str $funcname;
  my Str $package;

  my token prelude { '[func@' }
  my token package { <-[\.\]]>+ }
  my token funcname { <-[\]]>+  }
  my regex func-regex { <prelude> <package> '.' <funcname> ']' }

  while $text ~~ m/ <func-regex> / {
#note $/.gist;
    $package = $/<func-regex><package>.Str;
    $funcname = $/<func-regex><funcname>.Str;
    my Hash $h = $!solve.search-name($funcname);
    $funcname ~~ s:g/ '_' /-/;
#note "$?LINE $funcname, $package";
    if ?$h {
      my $classname = $!solve.set-object-name($h);
      $text ~~ s/ <func-regex> /C<.$funcname\(\) in class $classname>/;
    }

    else {
      if $package.lc eq $*work-data<name-prefix> {
        $text ~~ s/ <func-regex> /C<.$funcname\(\)>/;
      }

      else {
        $text ~~ s/ <func-regex> /C<.$funcname\(\) in package Gnome::$package>/;
      }
    }
  }

  $text
}

#-------------------------------------------------------------------------------
# Convert classes [class@Gtk.Entry] also found [class@Button]
# and interfaces [iface@Gtk.TreeSortable]
method !modify-v4classes ( Str $text is copy --> Str ) {

  my Str $package;
  my Str $prefix;
  my Str $gname;

  # [class@Gtk.Entry]
  $text ~~ m/ '[class@' $<prefix> = [<-[\.\]]>+] '.' $<gname> = [<-[\]]>+] ']' /;
  while $/.Bool {
    $prefix = $/<prefix>.Str;
    $gname = $/<gname>.Str;
    $package = $prefix;
    $package ~= '4' if $prefix ~~ any(<Gtk Gsk Gdk>);
    $text ~~ s/ '[class@' $prefix '.' $gname ']'
              /B<Gnome\:\:$package\:\:$gname>/;
    $text ~~ m:c/ '[class@' $<prefix> = <-[\.]>+ '.' $<gname> = <-[\]]>+ ']' /;
  }

  # [class@Button]
  $text ~~ m/ '[class@' $<gname> = [<-[\]]>+] ']' /;
  while $/.Bool {
    $gname = $/<gname>.Str;
    $package = $*gnome-package.Str;
#note "$?LINE $gname, $package";

    # substitute
    $text ~~ s/ '[class@' $gname ']' /B<Gnome\:\:$package\:\:$gname>/;

    # next
    $text ~~ m:c/ '[class@' $<gname> = <-[\]]>+ ']' /;
  }

  $text
}

#-------------------------------------------------------------------------------
# Convert [enum@Gtk.Overflow]
method !modify-v4enum ( Str $text is copy --> Str ) {

  my token prefix { <-[\.\]]>+ }
  my token enumname { <-[\]]>+ }
  my regex enum { '[enum@' <prefix> '.' <enumname> ']' }
  while $text ~~ m/ <enum> / {
    my Str $prefix = $/<enum><prefix>.Str;
    my Str $enumname = $/<enum><enumname>.Str;
    my Hash $h = $!solve.search-name($prefix ~ $enumname);
    if ?$h {
      my $classname = $!solve.set-object-name($h);
      $text ~~ s/ <enum> / C<enumeration $enumname from $classname> /;
    }
    
    else {
      $text ~~ s/ <enum> / C<enumeration $enumname> /;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
# Convert [struct@Pango.Attribute]
method !modify-v4structure ( Str $text is copy --> Str ) {

  my token prefix { <-[\.\]]>+ }
  my token structname { <-[\]]>+ }
  my regex struct { '[struct@' <prefix> '.' <structname> ']' }
  while $text ~~ m/ <struct> / {
    my Str $prefix = $/<struct><prefix>.Str;
    my Str $structname = $/<struct><structname>.Str;
    my Hash $h = $!solve.search-name($prefix ~ $structname);
    if ?$h {
      my $classname = $!solve.set-object-name($h);
      $text ~~ s/ <struct> / B<$classname> /;
    }
    
    else {
      $text ~~ s/ <struct> / B<$structname> /;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method !modify-word ( Str $text is copy --> Str ) {

  my Str $gname = $*work-data<gnome-name>;
  my Str $rname = $*work-data<raku-class-name>;
  given $text {

#`{{
    # Class names
    when / $gname / {
      $text ~~ s/ $gname /B<$rname>/;
    }
}}

    # Email, replace AT-sign
    when / <|w> '@' <|w> / {
      $text ~~ s/ '@' /\\x0040/;
      $text = "I<$text>";
    }

    # Functions
    when / '()' $/ {
      $text = "C<$text>";
    }

    # Links
    when / '&lt;' .*? '&gt;' / {
      $text ~~ s/ '&lt;' (.*?) '&gt;' /U<$0>/;
    }

    default {
      $text = "I<$text>";
    }
  }

  $text
}

#-------------------------------------------------------------------------------
# Convert '::sig-name'
method !modify-signals ( Str $text is copy --> Str ) {

  my Str $gnome-name = $*work-data<gnome-name>;
  my token classname { [\w+] }
  my token signal-name { <[-\w]>+ }
  my regex signal {
    [ '#' <classname> '::' <signal-name> | \s '::' <signal-name> ]
  }

  while $text ~~ m/ <signal> / {
#note "$?LINE $/.gist()";
    my Str $classname = $<signal><classname>.Str // '';
    my Str $signal-name = $<signal><signal-name>.Str;
    if $classname eq $*work-data<gnome-name> {
      $text ~~ s/ <signal> / I<$signal-name>/;
    }

    elsif $classname {
      $text ~~ s/ <signal> 
                / I<$signal-name defined in $*work-data<raku-class-name>>/;
    }

    else {
      $text ~~ s/ <signal> / I<$signal-name>/;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method !modify-functions ( Str $text is copy --> Str ) {

#`{{
  my token name { <[\w\-]>+ }
  my token bracks { '()' }
  my regex func-regex { <|w> <!after 'C<' > <name> <bracks> <|w> }
  while $text ~~ m/ <func-regex> / {
note "$?LINE $/.gist()";

    my Str $classname;
    my Str $funcname = $/<func-regex><name>.Str;
    my Hash $h = $!solve.search-name($funcname);
    if ?$h {
      $classname = $!solve.set-object-name($h);
note "$?LINE $funcname, $classname, $h.gist()";
      $text ~~ s/ <func-regex> /C<$funcname\(\) defined in $classname>/;
    }

    else {
      $text ~~ s/ <func-regex> /C<$funcname\(\)>/;
    }
  }
}}

##`{{
  my Str $sub-prefix = $*work-data<sub-prefix>;
  my Str $raku-name = $*work-data<raku-name>.lc;

  # When a local function has '_new' at the end in the text, convert it into
  # a different name. E.g. 'gtk_label_new()' becomes '.new-label()'
  $text ~~ s:g/ $sub-prefix new '()' /C<.new-$raku-name\(\)>/;
#              /C<.new(:\${ S:g/'_'/-/ with $0 })>/;

  # Other functions local to this module, remove the sub-prefix and place
  # a '.' at front. E.g in module Label and package Gtk3 converting
  # 'gtk_label_set_line_wrap()' becomes '.set-line-wrap()'.
  $text ~~ s:g/ $sub-prefix (\w+) '()' /C<.{S:g/'_'/-/ with $0}\(\)>/;

  # Functions not local to this module
  my Regex $r = / $<function-name> = [
                    <!after "\x200B">
                    [ atk || gtk || gdk || gsk ||
                      pangocairo || pango || cairo || g
                    ]
                    '_' \w*?
                  ] '()'
                /;

  while $text ~~ $r {
    my Str $function-name = $<function-name>.Str;
    my Hash $h = $!solve.search-name($function-name);
    my Str $package-name = $h<raku-package> // '';
    my Str $raku-name = $h<rname> // '';

    if ?$raku-name {
      $text ~~ s:g/ $function-name\(\) 
                  /C<\x200B$raku-name\(\) function from $package-name>/;
    }

    else {
      $text ~~ s:g/ $function-name\(\) /\x200B$function-name\(\)/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;
#}}

  $text
}

#-------------------------------------------------------------------------------
method !modify-variables ( Str $text is copy --> Str ) {

  $text ~~ s:g/ \s? '@' (\w+) / C<\$$0>/;

  $text
}

#-------------------------------------------------------------------------------
method !modify-markdown-links ( Str $text is copy --> Str ) {
  $text ~~ s:g/ \s '[' ( <-[\]]>+ ) '][' <-[\]]>+ ']' / $0/;

  $text
}

#-------------------------------------------------------------------------------
method !modify-classes ( Str $text is copy --> Str ) {

# single letter is matched too easily with many words
# | [ G <!before [ 'nome' | 'TK' ] > ]
  my token package {
    <!after ['Gnome::' | '%'] >
    [ Atk | Gtk | Gdk | Gsk | PangoCairo | Pango | Cairo | G
    ]
  }

  my token classname { <[a..zA..Z]>+ }
  my regex class-regex { '#' <package> <classname> }

  while $text ~~ m/ <class-regex> / {
#note "$?LINE $/.gist()\n\n";
    my Str $package = $/<class-regex><package>.Str;
    my Str $classname = $/<class-regex><classname>.Str;

    my Hash $h = $!solve.search-name($package ~ $classname);
#note "$?LINE $h.gist()";
    $classname = $!solve.set-object-name($h);
    $text ~~ s/ <class-regex> /B<$classname>/;
  }

#`{{
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

  while $text ~~ $r {
enumeration
    my Str $class-name = $<class-name>.Str;
    my Hash $h = $!solve.search-name($class-name);

    if ?$h<gir-type> and $h<gir-type> eq 'enumeration' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name enumeration>/;
    }
    
    elsif ?$h<gir-type> and $h<gir-type> eq 'bitfield' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name bitfield>/;
    }
    
    elsif ?$h<type-name> {
      my Str $name = $!solve.set-object-name($h);
      $text ~~ s:g/ '#'? $class-name /B<\x200B$name>/;
    }

    else {
      $text ~~ s:g/ '#'? $class-name /\x200B$class-name/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;
}}

  $text
}

#-------------------------------------------------------------------------------
# Modify rest
method !modify-rest ( Str $text is copy --> Str ) {

  # New type literal changes
  $text ~~ s:g/ '`' TRUE '`' /C<True>/;
  $text ~~ s:g/ '`' FALSE '`' /C<False>/;

  if $text ~~ / '`NULL`' / {
#note "$?LINE $text";
    $text ~~ s:g/ '`NULL`-terminated' \s* (\w+) \s* array /$0 array/;
    $text ~~ s:g/ '`NULL`-terminated' \s* array \s* of (\w+) /$0 array/;
    $text ~~ s:g/ not \s '`NULL`' /defined/;
    $text ~~ s:g/ '`NULL`' /undefined/;
  }

  # Markdown backtick changes
  while $text ~~ m:c/ '`' $<word> = [<-[`]>+] '`' / {
    my Str $word = self!modify-word($/<word>.Str);
    $text ~~ s/ '`' <-[`]>+ '`' /$word/;
  }

  # Old type literal changes
  $text ~~ s:g/ '%' TRUE /C<True>/;
  $text ~~ s:g/ '%' FALSE /C<False>/;

  # Old type with '%' prefix
  if $text ~~ / '%NULL' / {
#note "$?LINE $text";
    $text ~~ s:g/ '%NULL-terminated' \s+ (\w+) \s+ array /$0 array/;
    $text ~~ s:g/ '%NULL-terminated' \s+ array \s+ of \s+ (\w+) /$0 array/;
    $text ~~ s:g/ not \s* '%NULL' /defined/;
    $text ~~ s:g/ '%NULL' /undefined/;
  }

  # Other types found like %GTK_ACCESSIBLE_ROLE_LABEL
  $text ~~ s:g/ '%' (<alpha>+) <|w> /C<$0>/;

  # Markdown Sections
  $text ~~ s:g/^^ '###' \s+ (\w) /=head4 $0/;
  $text ~~ s:g/^^ '##' \s+ (\w) /=head3 $0/;
  $text ~~ s:g/^^ '#' \s+ (\w) /=head2 $0/;


  # Gnome seems to use markdown directly too to say it is a class like
  # `GtkShortcutTrigger` or an enumeration like `PangoEllipsizeMode` and
  # maybe more of that mumbo jumbo.
  my token name { <-[`]>+ }
  my regex name-regex { '`' <name> '`' }
  while $text ~~ m/ <name-regex> / {
#note "$?LINE $/.gist()" if $text ~~ /NULL/;
    my Str $name = $/<name-regex><name>.Str;
    my Hash $h = $!solve.search-name($name);
#note "$?LINE $name, $h.gist()";
    if ?$h {
      my Str $classname = $!solve.set-object-name($h);
      given $h<gir-type> {
        when 'class' {
          $text ~~ s/ <name-regex> /B<$classname>/;
        }

        when 'enumeration' {
          $text ~~ s/ <name-regex> /C<enumeration $name defined in $classname>/;
        }

        when 'bitfield' {
          $text ~~ s/ <name-regex> /C<bit field $name defined in $classname>/;
        }

        default {
          $text ~~ s/ <name-regex> /U<$classname>/;
        }
      }
    }

    else {
      $text ~~ s/ <name-regex> /B<$name>/;
    }
  }
  # types
  #$text ~~ s:g/ '#' (\w+) /C<$0>/;

  $text
}

#-------------------------------------------------------------------------------
# Modify xml remnants
method !modify-xml ( Str $text is copy --> Str ) {
  
  # xml escapes
  $text ~~ s:g/ '&lt;' /</;
  $text ~~ s:g/ '&gt;' />/;
  $text ~~ s:g/ '&amp;' /\&/;
  $text ~~ s:g/ [ '&#160;' || '&nbsp;' ] / /;

  $text
}

#-------------------------------------------------------------------------------
method !cleanup ( Str $text is copy, Bool :$trim = False --> Str ) {
#  $text = self.scan-for-unresolved-items($text);
#  $text ~~ s:g/ ' '+ / /;              # wrong indenting
#  $text ~~ s:g/ <|w> \n <|w> / /;      # wrong 
  $text ~~ s:g/ \n ** 3..* /\n\n/;

#  if $trim {
#    $text ~~ s:g/^^ \s+ //;             # wrong indenting
#    $text ~~ s:g/ \s+ $$//;
#  }

  $text
}







=finish

#-------------------------------------------------------------------------------
# Convert ``` … ``` marks. Must be processed at the end because other
# modifications may change this code example
method !modify-v4examples ( Str $text is copy --> Str ) {

  # Indent first
  $text ~~ s:g/^^/  /;

  if $text ~~ m/ '  ```' \w+ / {
    $text ~~ s/ '  ```' (\w+)?
              /=begin comment \nFollowing example code is in $0\n/;
  }

  else {
    # Only first ```
    $text ~~ s/ '  ```' /=begin comment\n/;
  }

  # Then second
  $text ~~ s/'  ```' /=end comment/;

  $text
}

#-------------------------------------------------------------------------------
# convert |[ … ]| marks. Must be processed at the end because other
# modifications may depend on those marks
method !modify-examples ( Str $text is copy --> Str ) {

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="xml"' \s* '-->' 
              /=begin comment\n/;

  $text ~~ s:g/^^ '|[<!-- language="plain" -->'
              /=begin comment\n/;

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="C"' \s* '-->' 
              /=begin comment\n/;

  # Only literal text
  $text ~~ s:g/^^ '|[' /=begin comment\n/;

  $text ~~ s:g/^^ ']|' /=end comment\n/;

  $text
}

#-------------------------------------------------------------------------------
# Convert ':prop-name'
method !modify-properties ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<gnome-name>;
  my Regex $r = / '#'? $<cname> = [\w+]? ':' $<pname> = [<[-\w]>+] /;
  while $text ~~ $r {
    my Str $pname = $<pname>.Str;
    my Str $cname = ($<cname>//'').Str;
    if !$cname or $cname eq $section-prefix-name {
      $text ~~ s:g/ '#'? $cname ':' $pname /I<property $pname>/;
    }

    else {
      $text ~~ s:g/ '#'? $cname':' $pname /I<property $pname defined in $cname>/;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
# Modify rest
method !modify-v4rest ( Str $text is copy --> Str ) {

  # Gnome seems to use markdown directly too to say it is a class like
  # `GtkShortcutTrigger` or an enumeration like `PangoEllipsizeMode` and
  # maybe more of that mumbo jumbo.
  my token name { <-[`]>+ }
  my regex name-regex { '`' <name> '`' }
  while $text ~~ m/ <name-regex> / {
note "$?LINE $/.gist()";
    my Str $name = $/<name-regex><name>.Str;
    my Hash $h = $!solve.search-name($name);
    my Str $classname;
    if ?$h {
      $classname = $!solve.set-object-name($h);
      given $h<gir-type> {
        when 'class' {
          $text ~~ s/ <name-regex> /B<$classname>/;
        }

        when 'enumeration' {
          $text ~~ s/ <name-regex> /C<enumeration $name defined in $classname>/;
        }

        when 'bitfield' {
          $text ~~ s/ <name-regex> /C<bit field $name defined in $classname>/;
        }

        default {
          $text ~~ s/ <name-regex> /U<$classname>/;
        }
      }
    }

    else {
      $classname = $name;
      $text ~~ s/ <name-regex> /B<$classname>/;
    }
  }

  # Literals changes
  $text ~~ s:g/ '`' TRUE '`' /C<True>/;
  $text ~~ s:g/ '`' FALSE '`' /C<False>/;

  if $text ~~ / '`NULL`' / {
    $text ~~ s:g/ '`NULL`-terminated' \s* (\w+) \s* array /$0 array/;
    $text ~~ s:g/ '`NULL`-terminated' \s* array \s* of (\w+) /$0 array/;
    $text ~~ s:g/ not \s '`NULL`' /defined/;
    $text ~~ s:g/ '`NULL`' /undefined/;
  }

  # Markdown backtick changes
  while $text ~~ m:c/ '`' $<word> = [<-[`]>+] '`' / {
    my Str $word = self!modify-word($/<word>.Str);
    $text ~~ s/ '`' <-[`]>+ '`' /$word/;
  }

  $text
}
