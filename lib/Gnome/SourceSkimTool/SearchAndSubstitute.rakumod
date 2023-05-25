use Gnome::SourceSkimTool::ConstEnumType;

use XML;
use XML::XPath;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::SearchAndSubstitute:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
has $!gen-raku-module;

#-------------------------------------------------------------------------------
submethod BUILD ( ) { }

#-------------------------------------------------------------------------------
method get-types (
  Hash $parameter,
  Str $raku-list is rw, Str $par-list is rw, Str $call-list is rw,
  Str $items-doc is rw, Str $p-convert is rw, @rv-list,
  Str $returns-doc is rw
) {

#  my Str (
#    $raku-list, $par-list, $call-list, $items-doc, $p-convert, $returns-doc
#  ) = '' xx 6;
  my Str $own = '';
  my Int $a-count = 0;
#  my @rv-list = ();

  given my $xtype = $parameter<raku-ntype> {
    when 'N-GObject' {
      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
      $par-list ~= ", $parameter<raku-ntype> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[Str]' {
      $raku-list ~= ", Array[Str] \$$parameter<name>";
      $par-list ~= ", CArray[Str] \$$parameter<name>";
      $call-list ~= ", \$ca$a-count";
      $p-convert =
        "  my \$ca$a-count = CArray\[Str].new\(|\$$parameter<name>);\n";
      $a-count++;

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";
    }

    when 'CArray[gint]' {
#            $raku-list ~= ", CArray[gint] \$$parameter<name>";
#            my $ntype = 'gint';
      #$ntype ~~ s:g/ [const || \s+ || '*'] //;
      $par-list ~= ", CArray[gint] \$$parameter<name> is rw";
      @rv-list.push: "\$$parameter<name>";
      $call-list ~= ", my gint \$$parameter<name>";

      $returns-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";
    }
#`{{
    when 'CArray[UInt]' {
      $raku-list ~= ", $xtype \$$parameter<name>";
      $par-list ~= ", $parameter<raku-ntype> \$$parameter<name>";
      $call-list ~= ", \$ca$a-count";
      $p-convert =
        "  my \$ca$a-count = CArray\[Str].new\(|\$$parameter<name>);\n  ";
      $a-count++;
    }

    when 'CArray[N-GError]' {
      $raku-list ~= ", $xtype \$$parameter<name>";
      $par-list ~= ", $parameter<raku-ntype> \$$parameter<name>";
      $call-list ~= ", \$ca$a-count";
      $p-convert =
        "  my \$ca$a-count = CArray\[Str].new\(|\$$parameter<name>);\n  ";
      $a-count++;
    }
}}

    default {
      $raku-list ~= ", $parameter<raku-rtype> \$$parameter<name>";
      $par-list ~= ", $parameter<raku-ntype> \$$parameter<name>";
      $call-list ~= ", \$$parameter<name>";

      $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
        if ?$parameter<transfer-ownership> and
          $parameter<transfer-ownership> ne 'none';
      $items-doc ~= "=item \$$parameter<name>; $own$parameter<doc>\n";
    }
  }
  
  ( $raku-list, $par-list, $call-list,
    $items-doc, $p-convert, @rv-list, $returns-doc
  )
}

#-------------------------------------------------------------------------------
method gobject-value-type( Str $ctype --> Str ) {

  my $g-type = '';

  with $ctype {
    when 'gboolean' {
      $g-type = 'G_TYPE_BOOLEAN';
    }

    when 'gchar' {
      $g-type = 'G_TYPE_CHAR';
    }

    when 'gdouble' {
      $g-type = 'G_TYPE_DOUBLE';
    }
    
    when 'gfloat' {
      $g-type = 'G_TYPE_FLOAT';
    }
    
    when 'gint' {
      $g-type = 'G_TYPE_INT';
    }
    
#    when 'gint16' {
#      $g-type = '';
#    }
    
#    when 'gint32' {
#      $g-type = '';
#    }

    when 'gint64' {
      $g-type = 'G_TYPE_INT64';
    }

    when 'gint8' {
      $g-type = 'G_TYPE_CHAR';
    }

    when 'glong' {
      $g-type = 'G_TYPE_LONG';
    }

    when 'gpointer' {
      $g-type = 'G_TYPE_POINTER';
    }
    
#    when 'gshort' {
#      $g-type = '';
#    }
    
#    when 'gsize' {
#      $g-type = '';
#    }
    
#    when 'gssize' {
#      $g-type = '';
#    }
    
    when 'guchar' {
      $g-type = 'G_TYPE_UCHAR';
    }
    
    when 'guint' {
      $g-type = 'G_TYPE_UINT';
    }
    
#    when 'guint16' {
#      $g-type = '';
#    }
    
#    when 'guint32' {
#      $g-type = '';
#    }
    
    when 'guint64' {
      $g-type = 'G_TYPE_UINT64';
    }
    
    when 'guint8' {
      $g-type = 'G_TYPE_UCHAR';
    }
    
    when 'gulong' {
      $g-type = 'G_TYPE_ULONG';
    }
    
#    when 'gunichar' {
#      $g-type = '';
#    }
    
#    when 'gushort' {
#      $g-type = '';
#    }
       
#    when 'gushort' {
#      $g-type = '';
#    }
    
#    when 'gushort' {
#      $g-type = '';
#    }
 
    when 'GEnum' {
      $g-type = 'G_TYPE_ENUM';
    }
 
    when 'GFlag' {
      $g-type = 'G_TYPE_FLAGS';
    }

    default {
      my Hash $h = self.search-name($ctype);
      if ?$h<gir-type> {
        $g-type = 'G_TYPE_ENUM' if $h<gir-type> eq 'enumeration';
        $g-type = 'G_TYPE_FLAGS' if $h<gir-type> eq 'bitfield';
        $g-type = 'G_TYPE_OBJECT' if $h<gir-type> eq 'class';
      }
    }
  }

  $g-type
}

#-------------------------------------------------------------------------------
method convert-ntype (
  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;
#note "$?LINE ctype: $ctype";

  # ignore const and spaces
  $ctype ~~ s:g/ const //;
  $ctype ~~ s:g/ \s+ //;

  my Str $raku-type = '';
  with $ctype {
    when any(
        <gboolean gchar gdouble gfloat gint gint16 gint32 gint64 gint8 
        glong gpointer gshort gsize gssize guchar guint guint16
        guint32 guint64 guint8 gulong gunichar gushort
        >
    ) {
      $raku-type = $ctype;
    }

    when any(
        <boolean char double float int int16 int32 int64 int8 
        long pointer short size ssize uchar uint uint16
        uint32 uint64 uint8 ulong unichar ushort
        >) {
      $raku-type = "g$ctype";
    }

    when /GQuark/          { $raku-type = 'GQuark'; }
    when /GList/           { $raku-type = 'N-GList'; }
    when /GSList/          { $raku-type = 'N-GSList'; }

#TODO check for any other types in gir files
#grep 'name="' Gtk-3.0.gir | grep '<type' | sed 's/^[[:space:]]*//' | sort -u

#TODO int/num/pointers as '$x is rw'
    # ignore const
    when /g? char '**'/    { $raku-type = 'CArray[Str]'; }
    when /g? char '*'/     { $raku-type = 'Str'; }
    when /g? int '*'/      { $raku-type = 'CArray[gint]'; }
    when /g? uint '*'/     { $raku-type = 'CArray[guint]'; }
    when /g? size '*'/     { $raku-type = 'CArray[gsize]'; }
    when /GError '*'/      { $raku-type = 'CArray[N-GError]'; }

    when 'void' { $raku-type = 'void'; }

    default {
      # remove any pointer marks
      $ctype ~~ s:g/ '*' //;

      my Hash $h = self.search-name($ctype);
      given $h<gir-type> // '-' {
        when 'class' {
          $raku-type = 'N-GObject';
#          $raku-type ~= '()' unless $return-type;
        }

        when 'enumeration' { $raku-type = 'GEnum'; }
        when 'bitfield' { $raku-type = 'GFlag'; }

#        when 'record' { }
#        when 'callback' { }
        when 'interface' {
          $raku-type = 'N-GObject';
#          $raku-type ~= '()' unless $return-type;          
        }
#        when '' { }

        default {
          note 'Unknown gir type to convert to native raku type \'',
            $h<gir-type> // '-', '\' for ctype \'', $ctype, '\'';
        }
      }
    }
  }

#say "$?LINE: convert to raku native type: '$ctype' -> '$raku-type', return-type = $return-type";

  $raku-type
}

#-------------------------------------------------------------------------------
method convert-rtype (
  Str $ctype is copy, Bool :$return-type = False --> Str
) {
  return '' unless ?$ctype;

  # ignore const and spaces
  $ctype ~~ s:g/ const //;
  $ctype ~~ s:g/ \s+ //;

  my Str $raku-type = '';
  with $ctype {
    when / g? boolean / {
      $raku-type = 'Bool';
      $raku-type ~= '()';     # unless $return-type;
    }

    when any(<gchar gint gint16 gint32 gint64 gint8
         glong gshort gsize gssize char int int16 int32 int64 int8
         long short size ssize
         >) {
      $raku-type = 'Int';
      $raku-type ~= '()' unless $return-type;
    }

    when any(<guchar guint guint16 guint32 guint64
         guint8 gulong gunichar gushort uchar uint uint16 uint32 uint64
         uint8 ulong unichar ushort
         >) {
      $raku-type = 'UInt';
      $raku-type ~= '()' unless $return-type;
    }

    when /g [float || double]/ {
      $raku-type = 'Num';
      $raku-type ~= '()' unless $return-type;
    }

    when /GQuark/ { $raku-type = 'UInt'; }
    when /GList/ {
      $raku-type = 'N-GList';
      $raku-type ~= '()' unless $return-type;
    }
    when /GSList/ {
      $raku-type = 'N-GSList';
      $raku-type ~= '()' unless $return-type;
    }

#TODO check for any other types in gir files
#grep 'name="' Gtk-3.0.gir | grep '<type' | sed 's/^[[:space:]]*//' | sort -u

#TODO int/num/pointers as '$x is rw'
    when /g? char '**'/        { $raku-type = 'Array[Str]'; }
    when /g? char '*'/         { $raku-type = 'Str'; }
    when /g? int '*'/          { $raku-type = 'Array[Int]'; }
    when /g? uint '*'/         { $raku-type = 'Array[UInt]'; }
    when /g? size '*'/         { $raku-type = 'Array[gsize]'; }
    when /GError '*'/          { $raku-type = 'Array[N-GError]'; }
    when 'void' { $raku-type = 'void'; }

    default {
      # remove any pointer marks because objects are provided by pointer
      $ctype ~~ s:g/ '*' //;

      my Hash $h = self.search-name($ctype);
      given $h<gir-type> // '-' {
        when 'class' {
          $raku-type = 'N-GObject';
          $raku-type ~= '()' unless $return-type;
        }

        when 'enumeration' {
          # All C enumerations are integers and can coerce to the enum type
          # in input and output. Need to prefix package name because
          # enumerations are mentioned without it
          $raku-type = $h<rname> ~ '()';
        }

        when 'bitfield' {
          $raku-type = 'UInt';
          $raku-type ~= '()' unless $return-type;
        }

#        when 'record' { }
#        when 'callback' { }
        when 'interface' {
          $raku-type = 'N-GObject';
          $raku-type ~= '()' unless $return-type;          
        }
#        when '' { }

        default {
          note 'Unknown gir type to convert to raku type \'',
            $h<gir-type> // '-', '\' for ctype \'', $ctype,
            '\', \'', $*work-data<gnome-type>, '\'';
        }
      }
    }
  }

#say "$?LINE: convert raku type; '$ctype' -> '$raku-type', return-type = $return-type";

  $raku-type
}

#-------------------------------------------------------------------------------
method search-name ( Str $name is copy --> Hash ) {

  my Hash $h = %();
  for <Gtk Gdk Gsk Glib Gio GObject Pango Cairo PangoCairo> -> $map-name {

    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists
            and ( $*object-maps{$map-name}{$name}:exists 
                  or $*object-maps{$map-name}{$map-name ~ $name}:exists
                );

    # Get the Hash from the object maps
    $h = $*object-maps{$map-name}{$name}
         // $*object-maps{$map-name}{$map-name ~ $name};

    # Add package name to this hash
    $h<raku-package> = $*other-work-data{$map-name}<raku-package>;
    last;
  }

#say "$?LINE: search $name -> {$h<rname> // $h.gist}";

  $h
}

#-------------------------------------------------------------------------------
# Search for names of specific type in object maps 
method search-names ( Str $prefix-name, Str $entry-name, Str $value --> Hash ) {

  my Hash $h = %();
  for <Gtk Gdk Gsk Glib Gio GObject Pango Cairo PangoCairo> -> $map-name {

    # It is possible that not all hashes are loaded
    next unless $*object-maps{$map-name}:exists;

    for $*object-maps{$map-name}.kv -> $name, $value-hash {
      next unless $value-hash{$entry-name} eq $value;
      next unless $name ~~ m/^ [ $map-name ]? $prefix-name /;
      $h{$name} = $value-hash;

      # Add package name to this hash
      $h{$name}<raku-package> = $*other-work-data{$map-name}<raku-package>;
    }

    last if ?$h;
  }

#say "$?LINE: search $name -> {$h<rname> // $h.gist}";

  $h
}

#-------------------------------------------------------------------------------
method get-method-data (
  XML::Element $e, Bool :$build = False, XML::XPath :$xpath
  --> List
) {
  my Str ( $function-name, $option-name, $function-doc);

  $option-name = $function-name = $e.attribs<c:identifier>;
  my Str $sub-prefix := $*work-data<sub-prefix>;

  # option names are used in BUILD only
  if $build {
    # constructors have '_new' in the name
    $option-name ~~ s/^ $sub-prefix new '_'? //;
    my Int $last-u = $option-name.rindex('_');
    $option-name .= substr($last-u + 1) if $last-u.defined;
#    $option-name ~~ s:g/ '_' /-/;
    $option-name = '-' if $option-name ~~ m/^ \s* $/;
  }

  my Str $edoc = ($xpath.find( 'doc/text()', :start($e)) // '').Str;
  my Str $s = self.modify-text($edoc);
  $function-doc = self.cleanup($s);

  my XML::Element $rvalue = $xpath.find( 'return-value', :start($e));
  my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-doc, $rv-type, $return-raku-ntype, $return-raku-rtype) =
    self.get-doc-type( $rvalue, :return-type, :$xpath);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs = $xpath.find(
    'parameters/instance-parameter | parameters/parameter',
    :start($e), :to-list
  );

  for @prmtrs -> $p {
    my Str ( $doc, $type, $raku-ntype, $raku-rtype) =
      self.get-doc-type( $p, :$xpath);
    my Hash $attribs = $p.attribs;
    my Str $parameter-name = $attribs<name>;
    $parameter-name ~~ s:g/ '_' /-/;

    my Hash $ph = %(
      :name($parameter-name), :transfer-ownership($attribs<transfer-ownership>),
      :$doc, :$type, :$raku-ntype, :$raku-rtype
    );

    if $p.name eq 'instance-parameter' {
      $ph<allow-none> = False;
      $ph<nullable> = False;
      $ph<is-instance> = True;

    }

    elsif $p.name eq 'parameter' {
      $ph<allow-none> = $attribs<allow-none>.Bool;
      $ph<nullable> = $attribs<nullable>.Bool;
      $ph<is-instance> = False;
    }

    @parameters.push: $ph;
  }

  ( $function-name, %(
      :$option-name, :$function-doc, :@parameters,
      :$rv-doc, :$rv-type, :$return-raku-ntype, :$return-raku-rtype,
      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
method get-doc-type (
  XML::Element $e, Bool :$return-type = False,
  Bool :$add-gtype = False, XML::XPath :$xpath
  --> List
) {

  my Str ( $doc, $type, $raku-ntype, $raku-rtype, $g-type) =
     ( '', '', '', '', '');
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;
    with $n.name {
      when 'doc' {
        $doc = self.cleanup(
          self.modify-text(($xpath.find( 'text()', :start($n)) // '').Str)
        );
      }

      when 'type' {
        $type = $n.attribs<name>;
        $type ~~ s:g/ '.' //;
        $raku-ntype =
          self.convert-ntype($n.attribs<c:type> // $type, :$return-type);
        $raku-rtype =
          self.convert-rtype($n.attribs<c:type> // $type, :$return-type);
        $g-type = self.gobject-value-type($raku-ntype) if $add-gtype;
      }

      when 'array' {
        # sometime there is no 'c:type', assume an array of strings
        $type = $n.attribs<c:type> // 'gchar**';
        $raku-ntype = self.convert-ntype( $type, :$return-type);
        $raku-rtype = self.convert-rtype( $type, :$return-type);
        $g-type = self.gobject-value-type($raku-ntype) if $add-gtype;
      }
    }
  }

  ( $doc, $type, $raku-ntype, $raku-rtype, $g-type)
}

#-------------------------------------------------------------------------------
method modify-text ( Str $text is copy --> Str ) {

  # Do not modify text whithin example code. C code is to be changed
  # later anyway and on other places like in XML examples it must be kept as is.
  my Int $ex-counter = 0;
  my Hash $examples = %();
  while $text ~~ m/ $<example> = [ '|[' .*? ']|' ] / {
    my Str $example = $<example>.Str;
    my Str $ex-key = '____EXAMPLE____' ~ $ex-counter++;
    $examples{$ex-key} = $example;
    $text ~~ s/ $example /$ex-key/;
  }

  $text = self.modify-signals($text);
  $text = self.modify-properties($text);
  $text = self.modify-functions($text);
  $text = self.modify-variables($text);
  $text = self.modify-markdown-links($text);
  $text = self.modify-classes($text);
  $text = self.modify-rest($text);

  # Subtitute the examples back into the text before we can finally modify it
  for $examples.keys -> $ex-key {
    $text ~~ s/ $ex-key /$examples{$ex-key}/;
  }

  $text = self.modify-xml($text);
  $text = self.modify-examples($text);

  $text
}

#-------------------------------------------------------------------------------
# Modify text '::sig-name'
method modify-signals ( Str $text is copy --> Str ) {

  my Str $section-prefix-name = $*work-data<gnome-name>;
  my Regex $r = / '#'? $<cname> = [\w+]? '::' $<signal-name> = [<[-\w]>+] /;
  while $text ~~ $r {
    my Str $signal-name = $<signal-name>.Str;
    my Str $cname = ($<cname>//'').Str;
    if !$cname or $cname eq $section-prefix-name {
      $text ~~ s:g/ '#'? $cname '::' $signal-name /I<$signal-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $cname'::' $signal-name /I<$signal-name defined in $cname>/;
    }
  }

  $text
}

#-------------------------------------------------------------------------------
method modify-properties ( Str $text is copy --> Str ) {

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
method modify-variables ( Str $text is copy --> Str ) {

  $text ~~ s:g/ \s? '@' (\w+) / C<\$$0>/;

  $text
}

#-------------------------------------------------------------------------------
method modify-build-variables (
  Str $text is copy, Hash $variable-map
  --> Str
) {
  # Only map for names in hash, others are done above. This is meant to
  # be used for the BUILD options to variable mapping. The substitutions might
  # already been done via .modify-text() so check on '$' as well.
  for $variable-map.kv -> $orig, $new {
    $text ~~ s:g/ \s? ['$'] $orig / \$$new/;
    $text ~~ s:g/ \s? ['@'] $orig / C<\$$new>/;
  }

  $text
}

#-------------------------------------------------------------------------------
method modify-functions ( Str $text is copy --> Str ) {

  my Str $sub-prefix = $*work-data<sub-prefix>;

  # When a local function has '_new_' in the text, convert it into an init call
  # E.g. 'gtk_label_new_with_mnemonic()' becomes '.new(:$with-mnemonic)'
  $text ~~ s:g/ $sub-prefix new '_' (\w+) '()'
              /C<.new(:\${ S:g/'_'/-/ with $0 })>/;

  # Other functions local to this module, remove the sub-prefix and place
  # a '.' at front. E.g in module Label and package Gtk3 converting
  # 'gtk_label_set-line-wrap()' becomes '.set-line-wrap()'.
  $text ~~ s:g/ $sub-prefix (\w+) '()' 
              /C<.{S:g/'_'/-/ with $0}\(\)>/;

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
    my Hash $h = self.search-name($function-name);
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

  $text
}

#-------------------------------------------------------------------------------
method modify-classes ( Str $text is copy --> Str ) {

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
    my Str $class-name = $<class-name>.Str;
    my Hash $h = self.search-name($class-name);
    my Str $raku-name = $h<rname> // '';

    if ?$h<gir-type> and $h<gir-type> eq 'enumeration' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name enumeration>/;
    }
    
    elsif ?$h<gir-type> and $h<gir-type> eq 'bitfield' {
      $text ~~ s:g/ '#'? $class-name /C<\x200B$class-name bitfield>/;
    }
    
    elsif ?$raku-name {
      $text ~~ s:g/ '#'? $class-name /B<\x200B$raku-name>/;
    }

    else {
      $text ~~ s:g/ '#'? $class-name /\x200B$class-name/;
    }
  }

  # After all work remove the zero width space marker
  $text ~~ s:g/ \x200B //;

  $text
}

#-------------------------------------------------------------------------------
# convert |[ … ]| marks. Must be processed at the end because other
# modifications may depend on those marks
method modify-examples ( Str $text is copy --> Str ) {

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="xml"' \s* '-->' 
              /=begin comment\nFollowing text is XML\n= begin code\n/;

  $text ~~ s:g/^^ '|[<!-- language="plain" -->'
              /=begin comment\n= begin code/;

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="C"' \s* '-->' 
              /=begin comment\n= begin code/;

  $text ~~ s:g/^^ ']|' /= end code\n=end comment\n/;

  $text
}

#-------------------------------------------------------------------------------
# Modify xml remnants
method modify-xml ( Str $text is copy --> Str ) {
  
  # xml escapes
  $text ~~ s:g/ '&lt;' /</;
  $text ~~ s:g/ '&gt;' />/;
  $text ~~ s:g/ '&amp;' /\&/;
  $text ~~ s:g/ [ '&#160;' || '&nbsp;' ] / /;

  $text
}

#-------------------------------------------------------------------------------
method modify-markdown-links ( Str $text is copy --> Str ) {
  $text ~~ s:g/ \s '[' ( <-[\]]>+ ) '][' <-[\]]>+ ']' / $0/;

  $text
}

#-------------------------------------------------------------------------------
# Modify rest
method modify-rest ( Str $text is copy --> Str ) {

  # variable changes
  $text ~~ s:g/ '%' TRUE /C<True>/;
  $text ~~ s:g/ '%' FALSE /C<False>/;
  $text ~~ s:g/ '%' NULL /C<Nil>/;

  # sections
  $text ~~ s:g/^^ '#' \s+ (\w) /=head2 $0/;

  $text
}

#-------------------------------------------------------------------------------
method cleanup ( Str $text is copy, Bool :$trim = False --> Str ) {
#  $text = self.scan-for-unresolved-items($text);
  $text ~~ s:g/ ' '+ / /;
  $text ~~ s:g/ <|w> \n <|w> / /;
  $text ~~ s:g/ \n ** 3..* /\n\n/;

  if $trim {
    $text ~~ s/^ \s+ //;
    $text ~~ s/ \s+ $//;
  }

  $text
}
