
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

  # Because of dependencies it is possible to have less to load when
  # we need to search

  note "Prepare for module generation" if $*verbose;

  # get workdata for other gnome packages
  my Gnome::SourceSkimTool::Prepare $p .= new;
  $!other-work-data = %();

  # Version 3
  if $*gnome-package.Str ~~ / '3' $/ {
    $!other-work-data<Gtk> = $p.prepare-work-data(Gtk3);
    $!other-work-data<Gdk> = $p.prepare-work-data(Gdk3);
  }

  # Version 4
  elsif $*gnome-package.Str ~~ / '3' $/ {
    $!other-work-data<Gtk> = $p.prepare-work-data(Gtk4);
    $!other-work-data<Gdk> = $p.prepare-work-data(Gdk4);
    $!other-work-data<Gsk> = $p.prepare-work-data(Gsk4);
  }

  # If it is a high end module, we add these too. They depend on Gtk.
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $!other-work-data<Atk> = $p.prepare-work-data(Atk);
    $!other-work-data<Pango> = $p.prepare-work-data(Pango);
    $!other-work-data<Cairo> = $p.prepare-work-data(Cairo);
  }

  # If it is not a high end module, we only need these
  $!other-work-data<Glib> = $p.prepare-work-data(Glib);
  $!other-work-data<Gio> = $p.prepare-work-data(Gio);
  $!other-work-data<GObject> = $p.prepare-work-data(GObject);

#`{{
  #TODO yaml problemen, not thread safe?
  # get object maps
  my Hash $promises = %();
  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;
  $!object-maps = %();
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $promises<atk> = Promise.start({
      $s.load-map($!other-work-data<Atk><gir-module-path>);
    });
    $promises<Gtk> = Promise.start({
      $s.load-map($!other-work-data<Gtk><gir-module-path>);
    });
    $promises<Gdk> = Promise.start({
      $s.load-map($!other-work-data<Gdk><gir-module-path>);
    });
    if ?$!other-work-data<Gsk> {
      $promises<Gsk> = Promise.start({
        $s.load-map($!other-work-data<Gsk><gir-module-path>)
      });
    }
    $promises<Pango> = Promise.start({
      $s.load-map($!other-work-data<Pango><gir-module-path>);
    });
    $promises<Cairo> = Promise.start({
      $s.load-map($!other-work-data<Cairo><gir-module-path>);
    });
  }


  $promises<Glib> = Promise.start({
    $s.load-map($!other-work-data<Glib><gir-module-path>);
  });
  $promises<Gio> = Promise.start({
    $s.load-map($!other-work-data<Gio><gir-module-path>);
  });
  $promises<GObject> = Promise.start({
    $s.load-map($!other-work-data<GObject><gir-module-path>);
  });

  await($promises.values);
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $!object-maps<Atk> = $promises<atk>.result;
    $!object-maps<Gtk> = $promises<Gtk>.result;
    $!object-maps<Gdk> = $promises<Gdk>.result;
    $!object-maps<Gsk> = $promises<Gsk>.result if ?$!other-work-data<Gsk>;
    $!object-maps<Pango> = $promises<Pango>.result;
    $!object-maps<Cairo> = $promises<Cairo>.result;
  }
  $!object-maps<Glib> = $promises<Glib>.result;
  $!object-maps<Gio> = $promises<Gio>.result;
  $!object-maps<GObject> = $promises<GObject>.result;
}}

##`{{
  # get object maps
  my Gnome::SourceSkimTool::SkimGtkDoc $s .= new;
  $!object-maps = %();
  if $*gnome-package.Str ~~ / '3' || '4' $/ {
    $!object-maps<Atk> = $s.load-map($!other-work-data<Atk><gir-module-path>);
    $!object-maps<Gtk> = $s.load-map($!other-work-data<Gtk><gir-module-path>);
    $!object-maps<Gdk> = $s.load-map($!other-work-data<Gdk><gir-module-path>);
    $!object-maps<Gsk> = ?$!other-work-data<Gsk> 
                       ?? $s.load-map($!other-work-data<Gsk><gir-module-path>)
                       !! %();
    $!object-maps<Pango> =
      $s.load-map($!other-work-data<Pango><gir-module-path>);
    $!object-maps<Cairo> =
      $s.load-map($!other-work-data<Cairo><gir-module-path>);
  }

  $!object-maps<Glib> = $s.load-map($!other-work-data<Glib><gir-module-path>);
  $!object-maps<Gio> = $s.load-map($!other-work-data<Gio><gir-module-path>);
  $!object-maps<GObject> =
    $s.load-map($!other-work-data<GObject><gir-module-path>);
#}}

  # load data for this module
  $!xpath .= new(:file($*work-data<gir-module-file>));
}

#-------------------------------------------------------------------------------
method generate-raku-module ( ) {

  my XML::Element $class-element = $!xpath.find('//class');

  my $module-doc = qq:to/RAKUMOD/;
    #TL:1:$*work-data<raku-class-name>:
    use v6;

    {HLSEPARATOR}
    {SEPARATOR('Class Description');}
    {HLSEPARATOR}
    RAKUMOD

  note "Generate module description" if $*verbose;  
  $module-doc ~= self!get-description($class-element);

  note "Generate module signals" if $*verbose;  
  my Hash $sig-info = self!generate-signals($class-element);

  note "Set class unit" if $*verbose;
  $module-doc ~= self!set-unit( $class-element, $sig-info);

#TODO generate types and enumerations

  note "Generate BUILD submethod" if $*verbose;  
  $module-doc ~= self!generate-build( $class-element, $sig-info);

  note "Generate module methods" if $*verbose;  
  $module-doc ~= self!generate-methods($class-element);

  # Add the signal doc here
  $module-doc ~= $sig-info<doc>;

  note "Generate module properties" if $*verbose;  
  $module-doc ~= self!generate-properties($class-element);

  note "Save module";
  $*work-data<raku-module-file>.IO.spurt($module-doc);
}

#-------------------------------------------------------------------------------
method generate-raku-module-test ( ) {

  my XML::Element $class-element = $!xpath.find('//class');
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  my Str $test-variable = '$' ~ $*gnome-class.lc;
  my $module-test-doc = qq:to/EOTEST/;
    use v6;
    use NativeCall;
    use Test;

    use $*work-data<raku-class-name>;

    use Gnome::N::GlibToRakuTypes;
    use Gnome::N::N-GObject;
    #use Gnome::N::X;
    #Gnome::N::debug(:on);

    {HLSEPARATOR}
    my $*work-data<raku-class-name> $test-variable;
    
    {HLSEPARATOR}
    subtest 'ISA test', \{
      $test-variable .= new;
      isa-ok $test-variable, $*work-data<raku-class-name>, '.new\()';
    \}

    {HLSEPARATOR}
    # set environment variable 'raku-test-all' if rest must be tested too.
    unless \%*ENV<raku_test_all>:exists \{
      done-testing;
      exit;
    \}

    EOTEST

    # check if class is inheritable
    if $h<inheritable> {
      $module-test-doc ~= qq:to/EOTEST/;
      {HLSEPARATOR}
      subtest 'Inherit $*work-data<raku-class-name>', \{
        class MyClass is $*work-data<raku-class-name> \{
          method new \( |c ) \{
            self.bless\( :$*work-data<gnome-name>, |c);
          }

          submethod BUILD \( *\%options ) \{

          }
        }

        my MyClass $test-variable .= new;
        isa-ok $test-variable, $*work-data<raku-class-name>, 'MyClass.new\()';
      }
      EOTEST
    }

    $module-test-doc ~= qq:to/EOTEST/;

    {HLSEPARATOR}
    done-testing;

    =finish


    {HLSEPARATOR}
    subtest 'Manipulations', \{
    \}

    {HLSEPARATOR}
    subtest 'Signals …', \{
      use Gnome::Gtk3::Main;
      use Gnome::N::GlibToRakuTypes;

      my Gnome::Gtk3::Main \$main .= new;

      class SignalHandlers \{
        has Bool \$!signal-processed = False;

        method … \(
          'any-args',
          $*work-data<raku-class-name>\(\) :\$_native-object, gulong :\$_handler-id
          # --> …
        ) \{

          isa-ok \$_native-object, $*work-data<raku-class-name>;
          \$!signal-processed = True;
        }

        method signal-emitter \( $*work-data<raku-class-name> :\$_widget --> Str ) \{

          while \$main.gtk-events-pending\() \{ \$main.iteration-do\(False); }

          \$_widget.emit-by-name\(
            'signal',
          #  'any-args',
          #  :return-type(int32),
          #  :parameters([int32,])
          );
          is \$!signal-processed, True, '\'…\' signal processed';

          while \$main.gtk-events-pending\() \{ \$main.iteration-do\(False); }

          #\$!signal-processed = False;
          #\$_widget.emit-by-name\(
          #  'signal',
          #  'any-args',
          #  :return-type\(int32),
          #  :parameters\(\[int32,])
          #);
          #is \$!signal-processed, True, '\'…\' signal processed';

          while \$main.gtk-events-pending\() \{ \$main.iteration-do\(False); }
          sleep(0.4);
          \$main.gtk-main-quit;

          'done'
        }
      }

      my $*work-data<raku-class-name> $test-variable .= new;

      #my Gnome::Gtk3::Window \$w .= new;
      #\$w.add(\$m);

      my SignalHandlers \$sh .= new;
      $test-variable.register-signal\( \$sh, 'method', 'signal');

      my Promise \$p = \$i.start-thread\(
        \$sh, 'signal-emitter',
        # :!new-context,
        # :start-time\(now + 1)
      );

      is \$main.gtk-main-level, 0, "loop level 0";
      \$main.gtk-main;
      #is \$main.gtk-main-level, 0, "loop level is 0 again";

      is \$p.result, 'done', 'emitter finished';
    }

    EOTEST

  note "Save module test";
  $*work-data<raku-module-test-file>.IO.spurt($module-test-doc);
}

#-------------------------------------------------------------------------------
method !get-description ( XML::Element $class-element --> Str ) {
  my Str $doc = "=head1 Description\n";

  #$doc ~= self!set-example-image;

  #$doc ~= $!xpath.find( 'doc/text()', :start($class-element)).Str;
  my Str $widget-picture = '';
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);
  $widget-picture = "\n!\[\]\(images/{$*gnome-class.lc}.png\)\n\n" if $h<inheritable>;

  $doc ~= self!modify-text(
    $!xpath.find( 'doc/text()', :start($class-element)).Str
  );

  #??$doc ~= self!set-declaration;
  $doc ~= self!set-uml;
  $doc ~= self!set-inherit-example($class-element);
  $doc ~= self!set-example;
  #$doc = self!cleanup($doc);

  qq:to/RAKUMOD/;
    =begin pod
    =head1 $*work-data<raku-class-name>
    $widget-picture$doc
    =end pod
    RAKUMOD
}

#-------------------------------------------------------------------------------
method !set-uml ( --> Str ) {
  # Using a markdown link not a Raku pod link
  my Str $doc = q:to/EOEX/;


    =begin comment
    =head2 Uml Diagram
    ![](plantuml/Label.svg)
    =end comment
    EOEX
  $doc
}

#-------------------------------------------------------------------------------
method !set-inherit-example ( XML::Element $class-element --> Str ) {

  my Str $doc = '';
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  if $h<inheritable> {
    # Code like {'...'} is inserted here and there to prevent interpretation
    $doc = qq:to/EOINHERIT/;

      =head2 Inheriting this class

      Inheriting is done in a special way in that it needs a call from new\() to get the native object created by the class you are inheriting from.

        use $*work-data<raku-class-name>;

        unit class MyGuiClass;
        also is $*work-data<raku-class-name>;

        submethod new \( \|c ) \{
          # let the {$*work-data<raku-class-name>} class process the options
          self\.bless\( :{$class-element.attribs<c:type>}, \|c);
        \}

        submethod BUILD \( ... ) \{
          ...
        \}

      EOINHERIT
  }

  $doc
}

#-------------------------------------------------------------------------------
method !set-example ( --> Str ) {
  my Str $doc = q:to/EOEX/;

    =begin comment
    =head2 Example

    =begin code
    =end code
    =end comment
    EOEX
  $doc
}

#-------------------------------------------------------------------------------
method !set-unit ( XML::Element $class-element, Hash $sig-info --> Str ) {

  my Str $use-enums;

  if $*gnome-package.Str ~~ / '3' $/ {
    $use-enums = "#use Gnome::Gtk3::Enums;\n";
  }

  elsif $*gnome-package.Str ~~ / '4' $/ {
    $use-enums = "#use Gnome::Gtk4::Enums;\n";
  }

  my Str ( $use-parent, $also-is);
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  my Str $parent = $h<parent-raku-name> // '';
  if ?$parent {
    $use-parent = "use $parent;\n";
    $also-is = "also is $parent;\n";
  }

  else {
    $use-parent = $also-is = '';
  }

  my Str $doc = qq:to/RAKUMOD/;

    {HLSEPARATOR}
    {SEPARATOR('Module Imports');}
    {HLSEPARATOR}
    use NativeCall;

    use Gnome::N::NativeLib;
    use Gnome::N::N-GObject;
    use Gnome::N::GlibToRakuTypes;

    $use-enums$use-parent

    {HLSEPARATOR}
    {SEPARATOR('Class Declaration');}
    {HLSEPARATOR}
    unit class {$*work-data<raku-class-name>}:auth<github:MARTIMM>;
    $also-is
    RAKUMOD

  if ?$sig-info<doc> {
    $doc ~= qq:to/RAKUMOD/;
      {HLSEPARATOR}
      my Bool \$signals-added = False;
      RAKUMOD
  }

  $doc
}

#-------------------------------------------------------------------------------
method !generate-build ( XML::Element $class-element, Hash $sig-info --> Str ) {

  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  my Hash $hcs = self!get-constructors($class-element);
  my Str $doc = self!make-build-doc( $class-element, $hcs);
  $doc ~= self!make-build-submethod( $class-element, $hcs, $sig-info);
  $doc ~= self!make-native-constructor-subs($hcs);

  $doc
}

#-------------------------------------------------------------------------------
method !make-build-doc ( XML::Element $class-element, Hash $hcs --> Str ) {
  my Str $doc = qq:to/EOBUILD/;

    {HLSEPARATOR}
    =begin pod
    =head1 Methods

    {HLSEPARATOR}
    {SEPARATOR('Class Description');}
    {HLSEPARATOR}
    =head2 new
    EOBUILD


  my Str $build-doc;
  for $hcs.keys.sort -> $function-name {
    $build-doc = '';

    my Str $option-name = $hcs{$function-name}<option-name>;
    
    # If $option-name is a dash, the new C-function has no special name.
    # It can have parameters. If so, take that name as an option name instead.
    # It will help to replace the text in the documentation noted as '@var'.
    if $option-name eq '-' {
      if $hcs{$function-name}<parameters>.elems {
        $option-name = $hcs{$function-name}<parameters>[0]<name>;
        $hcs{$function-name}<option-name> = $option-name;
      }
    }

    $build-doc ~= "\n=head3 :$option-name\n\n";
    $build-doc ~= "____FUNCTIONDOC___\n\n";
    $build-doc ~= "  multi method new (";

    my Hash $variable-map = %();
    if $hcs{$function-name}<parameters>.elems {
      my Bool $first = True;
      for @($hcs{$function-name}<parameters>) -> $parameter {
        if $first {
          $build-doc ~= " $parameter<raku-rtype> :\$$option-name!";
          $variable-map{$hcs{$function-name}<parameters>[0]<name>} = 
              $option-name;
          $first = False;
        }

        else {
          $build-doc ~= 
            ", $parameter<raku-rtype> :\$$hcs{$function-name}<option-name>";
        }
      }

      $build-doc.chop(1);
      $build-doc ~= " )\n\n";

      $first = True;
      for @($hcs{$function-name}<parameters>) -> $parameter {
        if $first {
          $build-doc ~= "=item :\$$option-name; $parameter<doc>\n\n";
          $first = False;
        }

        else {
          $build-doc ~=
            "=item :\$$hcs{$function-name}<option-name>; $parameter<doc>\n\n";
        }
      }
    }

    else {
      $build-doc ~= qq:to/EOPOD/;

        =head3 default, no options
        
        $hcs{$function-name}<function-doc>
        
          multi method new ( )
        EOPOD
    }

    # Add variable map to function data
    $hcs{$function-name}<variable-map> = $variable-map;

    # Modify variable names in the build doc and replace ____FUNCTIONDOC___
    my Str $d = self!modify-build-variables(
      $hcs{$function-name}<function-doc>, $variable-map
    );
    $build-doc ~~ s/ '____FUNCTIONDOC___' /$d/;
    $doc ~= $build-doc;
  }


  # Finish with standard options
  $doc ~= qq:to/EOBUILD/;

    =head3 :native-object

    Create an object using a native object from elsewhere. See also B<Gnome::N::TopLevelSupportClass>.

      multi method new ( N-GObject :\$native-object! )

    EOBUILD

  # Build id only used for widgets. We can test for inheritable because
  # it intices the same set of objects
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);
  if $h<inheritable> {
    $doc ~= qq:to/EOBUILD/;

      =head3 :build-id

      Create an object using a native object from a builder. See also B<Gnome::GObject::Object>.

        multi method new ( Str :\$build-id! )
      
      =end pod

      EOBUILD
  }

  $doc
}

#-------------------------------------------------------------------------------
method !make-build-submethod (
  XML::Element $class-element, Hash $hcs, Hash $sig-info --> Str
) {
  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);

  my Str $doc = qq:to/EOBUILD/;
    #TM:1:inheriting
    #TM:1:new(:text):
    #TM:1:new(:mnemonic):
    #TM:1:new(:native-object):
    #TM:1:new(:build-id):
    submethod BUILD ( *\%options ) \{
    EOBUILD

  # Check if signal admin is needed
  if ?$sig-info<doc> {
#:w3<move-cursor>, :w0<copy-clipboard activate-current-link>,
#:w1<populate-popup activate-link>,
    my Hash $signal-levels = %();
    for $sig-info<signals>.keys -> $signal-name {
      my Str $level = $sig-info<signals>{$signal-name}<parameters>.elems.Str;
      $signal-levels{$level} = [] unless $signal-levels{$level}:exists;
      $signal-levels{$level}.push: $signal-name;
    }

    my Str $sig-list = '';
    for ^10 -> Str() $level {
      if ?$signal-levels{$level} {
        $sig-list ~=
           [~] '    :w', $level, '<', $signal-levels{$level}.join(' '), ">,\n";
      }
    }

    $doc ~= qq:to/EOBUILD/;
        \$signals-added = self\.add-signal-types\( \$?CLASS\.^name,
      $sig-list  ) unless \$signals-added;

      EOBUILD
  }

  # Check if inherit code is to be inserted
#  my Str $ctype = $class-element.attribs<c:type>;
#  my Hash $h = self.search-name($ctype);
  if $h<inheritable> {
    $doc ~= [~] '  # prevent creating wrong widgets', "\n",
            '  if self.^name eq ', "'$*work-data<raku-class-name>'",
            ' or %options<', $*work-data<gnome-name>, ' {', "\n";
  }

  else {
    $doc ~= [~] '  # prevent creating wrong widgets', "\n",
            '  if self.^name eq ', "'$*work-data<raku-class-name>'", ' {', "\n";
  }

  # Add first few tests
  my Str $b-id-str = ?$h<inheritable>
                     ?? "\n" ~ '    elsif %options<build-id>:exists { }' !! '';
  $doc ~= qq:to/EOBUILD/;
        if self.is-valid \{ \}

        # check if common options are handled by some parent
        elsif \%options\<native-object>:exists \{ \}$b-id-str

        else \{
          my N-GObject\(\) \$no;
    EOBUILD

  my Str $ifelse = 'if';
  for $hcs.keys.sort -> $function-name {
    my Bool $first = True;
    my $par-list = '';
    my $decl-list = '';
    for @($hcs{$function-name}<parameters>) -> $parameter {
      if $first {
        $par-list ~= ", \$$hcs{$function-name}<option-name>";
        $decl-list ~= [~]  '        my $', $hcs{$function-name}<option-name>,
          ' = %options<', $parameter<name>, '>;', "\n";
      }

      else {
        $par-list ~= ", \$$parameter<name>";
        $decl-list ~= [~]  '        my $', $parameter<name>,
          ' = %options<', $parameter<name>, '>;', "\n";
      }

      $first = False;
    }

    # remove first comma
    $par-list ~~ s/^ . // if @($hcs{$function-name}<parameters>).elems == 1;

    # remove first space when there is only one parameter
    $par-list ~~ s/^ . // if @($hcs{$function-name}<parameters>).elems == 1;

    $doc ~= qq:to/EOBUILD/;
            #$ifelse \%options\<$hcs{$function-name}<option-name>\>.defined \{
            #$ifelse \? \%options\<$hcs{$function-name}<option-name>\> \{
            $ifelse \%options\<$hcs{$function-name}<option-name>\>:exists \{
      $decl-list
              \$no = $function-name\($par-list\);
            \}

      EOBUILD

    $ifelse = "elsif";
  }

  if !$h<inheritable> {
    $doc ~= q:to/EOBUILD/;
          # check if there are unknown options
          elsif %options.elems {
            die X::Gnome.new(
              :message(
                'Unsupported, undefined, incomplete or wrongly typed options for ' ~
                self.^name ~ ': ' ~ %options.keys.join(', ')
              )
            );
          }

    EOBUILD
  }

  $doc ~= q:to/EOBUILD/;
        #`{{ when there are no defaults use this
        # check if there are any options
        elsif %options.elems == 0 {
          die X::Gnome.new(:message('No options specified ' ~ self.^name));
        }
        }}

  EOBUILD

  $doc ~= q:to/EOBUILD/;
        #`{{ when there are defaults use this instead
        # create default object
        else {
          $no = $*work-data<sub-prefix>new();
        }
        }}

        self._set-native-object($no);
      }

  EOBUILD

  # End the BUILD submethod
  $doc ~= qq:to/EOBUILD/;
        # only after creating the native-object, the gtype is known
        self._set-class-info\('$*work-data<gnome-name>'\);
      \}
    \}
    EOBUILD

  $doc
}

#-------------------------------------------------------------------------------
method !make-native-constructor-subs ( Hash $hcs --> Str ) {
  my Str $doc = qq:to/EOSUB/;

      {HLSEPARATOR}
      {SEPARATOR('Constructors');}
      EOSUB

  for $hcs.keys.sort -> $function-name {
    my $par-list = '';

    for @($hcs{$function-name}<parameters>) -> $parameter {
      $par-list ~= [~] ', ', $parameter<raku-ntype>, ' $', $parameter<name>;
    }

    # remove first comma
    $par-list ~~ s/^ . //;

    $doc ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      #TM:1:$function-name:
      sub $function-name \(
       $par-list --> $hcs{$function-name}<return-raku-ntype>
      \) is native\($*work-data<library>\)
        \{ * \}

      EOSUB
  }

  $doc
}

#-------------------------------------------------------------------------------
method !generate-methods ( XML::Element $class-element --> Str ) {

  my Str $ctype = $class-element.attribs<c:type>;
  my Hash $h = self.search-name($ctype);
  my Bool $is-leaf = $h<leaf>;
  my Str $symbol-prefix = $h<symbol-prefix>;

  my Str $doc ~= qq:to/EOSUB/;
    {HLSEPARATOR}
    {SEPARATOR('Methods');}
    EOSUB

  my Hash $hcs = self!get-methods($class-element);
  for $hcs.keys.sort -> $function-name {
    my Hash $curr-function := $hcs{$function-name};

    # get method name
    my Str $method-name = $function-name;
    $method-name ~~ s/^ $symbol-prefix //;
    $method-name ~~ s:g/ '_' /-/;

    # get parameter lists
    my Str ( $par-list, $raku-list, $call-list, $items-doc) = ( '', '', '', '');

    for @($curr-function<parameters>) -> $parameter {
      $par-list ~= [~] ', ', $parameter<raku-ntype>, ' $', $parameter<name>;
      $call-list ~= ", \$$parameter<name>" unless $parameter<is-instance>;

      if ! $parameter<is-instance> {
        my $xtype = $parameter<raku-rtype>;
        $xtype ~= '()' if $xtype eq 'N-GObject';
        $raku-list ~= [~] ', ', $xtype, ' $', $parameter<name>;
        
        my Str $own = '';
        $own = "\(transfer ownership: $parameter<transfer-ownership>\) "
          if ?$parameter<transfer-ownership> and
             $parameter<transfer-ownership> ne 'none';

        $items-doc ~= qq:to/EOPDOC/;
          =item $parameter<name>; $own$parameter<doc>
          EOPDOC
      }
    }

    my Str $returns-doc = '';
    my $xtype = $curr-function<return-raku-ntype>;
    if ?$xtype and $xtype ne 'void' {
      $par-list ~= " --> $xtype";
    }

    $xtype = $curr-function<return-raku-rtype>;
    if ?$xtype and $xtype ne 'void' {
      $raku-list ~= " --> $xtype";
      my Str $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';

      $returns-doc = "\nReturn value; $own$curr-function<rv-doc>\n";
    }



    # remove first comma and substitute underscores
    $par-list ~~ s/^ . //;
#    $par-list ~~ s:g/ '_' /-/;
    $raku-list ~~ s/^ . //;
#    $raku-list ~~ s:g/ '_' /-/;
#    $call-list ~~ s:g/ '_' /-/;
#`{{
    my Str $returns-doc = '';
    if $curr-function<return-raku-rtype> ne 'void' {
      my Str $own = '';
      $own = "\(transfer ownership: $curr-function<transfer-ownership>\) "
        if ?$curr-function<transfer-ownership> and
            $curr-function<transfer-ownership> ne 'none';
      
      $returns-doc = $own ~ $curr-function<rv-doc>;
    }
  }}

    my Str $nobject-retrieve;
    if $is-leaf {
      $nobject-retrieve = 'self._get-native-object-no-reffing';
    }
    else {
      $nobject-retrieve = "self._f\('$*work-data<gnome-name>'\)";
    }

    $doc ~= qq:to/EOSUB/;
      {HLSEPARATOR}
      #TM:0:$method-name:
      =begin pod
      =head2 $method-name

      $curr-function<function-doc>

      =begin code
      method $method-name \(
       $raku-list
      \)
      =end code

      $items-doc
      $returns-doc
      =end pod

      method $method-name \(
       $raku-list
      \) \{
        $function-name\( $nobject-retrieve$call-list\)
      \}

      sub $function-name \(
       $par-list
      \) is native\($*work-data<library>\)
        \{ * \}

      EOSUB
  }

  $doc
}

#-------------------------------------------------------------------------------
method !generate-signals ( XML::Element $class-element --> Hash ) {
  my Hash $sig-info = %();
  my Str $doc = '';

  my @signal-info =
     $!xpath.find( 'glib:signal', :start($class-element), :to-list);

  my Hash $signals = %();
  for @signal-info -> $si {
    my Hash $attribs = $si.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # signal documentation
    my Str $signal-name = $attribs<name>;
    my Str $sdoc = self!cleanup(
      self!modify-text(($!xpath.find( 'doc/text()', :start($si)) // '').Str)
    );
    my Hash $curr-signal := $signals{$signal-name} = %(:$sdoc,);
#    $curr-signal = %(:$sdoc,);

    # return value info
    my XML::Element $rvalue = $!xpath.find( 'return-value', :start($si));
    $curr-signal<transfer-ownership> = $rvalue.attribs<transfer-ownership>;

    my Str ( $rv-doc, $rv-type, $return-raku-ntype, $return-raku-rtype) =
      self.get-doc-type($rvalue);
    $curr-signal<rv-doc> = $rv-doc;
    $curr-signal<rv-type> = $rv-type;
    $curr-signal<return-raku-ntype> = $return-raku-ntype;
    $curr-signal<return-raku-rtype> = $return-raku-rtype;

    # parameter info
    $curr-signal<parameters> = [];
    my @prmtrs =
        $!xpath.find( 'parameters/parameter', :start($si), :to-list);
    for @prmtrs -> $prmtr {
      my Hash $attribs = $prmtr.attribs;
      my $pname = $attribs<name>;
      my $transfer-ownership = $attribs<transfer-ownership>;
      my Str ( $pdoc, $ptype, $raku-ntype, $raku-rtype) =
        self.get-doc-type($prmtr);

      $curr-signal<parameters>.push: %(
        :$pname, :$pdoc, :$ptype,
        :$raku-ntype, :$raku-rtype,
        :$transfer-ownership
      );
    }
  }

  # If there are signals, make the docs for it
  if $signals.keys.elems {
    $doc ~= qq:to/EOSIG/;
      {HLSEPARATOR}
      {SEPARATOR('Signal Documentation');}
      {HLSEPARATOR}
      =begin pod
      =head1 Signals
      EOSIG

    for $signals.keys.sort -> $signal-name {
      my Hash $curr-signal := $signals{$signal-name};
      $doc ~= qq:to/EOSIG/;

        {HLPODSEPARATOR}
        =comment #TS:0:$signal-name:
        =head3 $signal-name

        $curr-signal<sdoc>

        =begin code
        method handler \(
        EOSIG

      for @($curr-signal<parameters>) -> $prmtr {
        $doc ~= "  $prmtr<raku-rtype> \$$prmtr<pname>,\n";
      }

      # return value info
      my Str ( $rv-method, $returns-doc ) = ( '', '');

      if ?$curr-signal<return-raku-ntype> and
         $curr-signal<return-raku-ntype> ne 'void' {
        my Str $own = '';
        $own = "\(transfer ownership: $curr-signal<transfer-ownership>\) "
          if ?$curr-signal<transfer-ownership> and
             $curr-signal<transfer-ownership> ne 'none';

        $returns-doc = "\nReturn value; $own$curr-signal<rv-doc>\n";
        $rv-method = "\n  --> $curr-signal<return-raku-ntype>";
      }

      $doc ~= qq:to/EOSIG/;
          Int :\$_handle_id,
          $*work-data<raku-class-name>\(\) :\$_native-object,
          $*work-data<raku-class-name> :\$_widget,
          *\%user-options$rv-method
        )
        =end code

        EOSIG

      for @($curr-signal<parameters>) -> $prmtr {
        my Str $own = ( ?$prmtr<transfer-ownership> and
                        $prmtr<transfer-ownership> ne 'none'
                      ) ?? "\(transfer ownership: $prmtr<transfer-ownership>)"
                        !! '';
        $doc ~= "=item $prmtr<pname>; $own$prmtr<pdoc>.\n";
      }

      $doc ~= q:to/EOSIG/;
        =item $_handle_id; the registered event handler id.
        =item $_native-object; The native object provided by the caller wrapped in the Raku object.
        =item $_widget; the object which received the signal.
        =item %user-options; A list of named arguments provided at the C<.register-signal() method from Gnome::GObject::Object>.
        EOSIG
      $doc ~= $returns-doc;

#`{{
      $doc ~= "Return value \(transfer ownership: $curr-signal<return-raku-ntype> \($curr-signal<transfer-ownership>); $curr-signal<rv-doc>\n"
            if $curr-signal<return-raku-ntype> ne 'void';
}}
    }

    $doc ~= "\n=end pod\n\n";
  }

  $sig-info<doc> = $doc;
  $sig-info<signals> = $signals;

  $sig-info
}

#-------------------------------------------------------------------------------
method !generate-properties ( XML::Element $class-element --> Str ) {
  my Str $doc = '';

  my @property-info =
     $!xpath.find( 'property', :start($class-element), :to-list);

  my Hash $properties = %();
  for @property-info -> $pi {
    my Hash $attribs = $pi.attribs;
    next if $attribs<deprecated>:exists and  $attribs<deprecated> == 1;

    # signal documentation
    my Str $property-name = $attribs<name>;
    my Bool $writable = $attribs<writable>.Bool;

    my Str ( $pgetter, $psetter);
    if $attribs<getter>:exists {
      $pgetter = $attribs<getter>;
      $pgetter ~~ s:g/ '_' /-/;
      $pgetter = "C<.$pgetter\()>";
    }
    if $attribs<setter>:exists {
      $psetter = $attribs<setter>;
      $psetter ~~ s:g/ '_' /-/;
      $psetter = "C<.$psetter\()>";
    }

    my Str $transfer-ownership = $attribs<transfer-ownership>;

    my Str ( $pdoc, $type, $raku-ntype, $raku-rtype, $g-type) =
      self.get-doc-type($pi);

    $properties{$property-name} = %(
      :$pdoc, :$writable, :$type, :$raku-ntype, :$g-type,
      :$pgetter, :$psetter, :$transfer-ownership
    );
  }

  $doc ~= qq:to/EOSIG/;

    {HLSEPARATOR}
    {SEPARATOR('Property Documentation');}
    {HLSEPARATOR}
    =begin pod
    =head1 Properties

    Please note that this information is not really necessary to use or know
    about because there are routines to get or set its value for many of
    those properties.
    EOSIG

  for $properties.keys.sort -> $property-name {
    $doc ~= qq:to/EOSIG/;

      {HLPODSEPARATOR}
      =comment #TP:0:$property-name:
      =head3 $property-name
      EOSIG

#say "$?LINE props $property-name: $properties{$property-name}.gist()";

    if $properties{$property-name}<pdoc> ~~ m/^ \s* $/ {
      $doc ~= "\nThere is no documentation for this property\n\n";
    }

    else {
      $doc ~= "\n$properties{$property-name}<pdoc>\n\n";
    }

    $doc ~= "=item B<Gnome::GObject::Value> for this property is $properties{$property-name}<g-type>.\n";

    $doc ~= "=item The native type is $properties{$property-name}<raku-ntype>.\n";

    if $properties{$property-name}<writable> {
      $doc ~= "=item Property is readable and writable\n";
    }

    else {
      $doc ~= "=item Property is readonly\n";
    }

    $doc ~= "=item Getter method is $properties{$property-name}<pgetter>\n"
      if ?$properties{$property-name}<pgetter>;

    $doc ~= "=item Setter method is $properties{$property-name}<psetter>\n"
      if ?$properties{$property-name}<psetter>;
  }

  $doc ~= "\n=end pod\n\n";

  $doc
}

#-------------------------------------------------------------------------------
method !get-constructors ( XML::Element $class-element --> Hash ) {
  my Hash $hcs = %();

  my @constructors =
    $!xpath.find( 'constructor', :start($class-element), :to-list);

  for @constructors -> $cn {
    my ( $function-name, %h) = self.get-method-data( $cn, :build);
    $hcs{$function-name} = %h;
  }

  $hcs
}

#-------------------------------------------------------------------------------
method !get-methods ( XML::Element $class-element --> Hash ) {
  my Hash $hms = %();

  my @methods =
    $!xpath.find( 'method', :start($class-element), :to-list);

  for @methods -> $cn {
    my ( $function-name, %h) = self.get-method-data( $cn, :!build);
    $hms{$function-name} = %h;
  }

  $hms
}

#-------------------------------------------------------------------------------
method get-method-data ( XML::Element $e, Bool :$build = False --> List ) {

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

  $function-doc = self!cleanup(
    self!modify-text(($!xpath.find( 'doc/text()', :start($e)) // '').Str)
  );

  my XML::Element $rvalue = $!xpath.find( 'return-value', :start($e));
  my Str $rv-transfer-ownership = $rvalue.attribs<transfer-ownership>;
  my Str ( $rv-doc, $rv-type, $return-raku-ntype, $return-raku-rtype) =
    self.get-doc-type($rvalue);

  # Get all parameters. Mostly the instance parameters come first
  # but I am not certain.
  my @parameters = ();
  my @prmtrs =
    $!xpath.find(
      'parameters/instance-parameter | parameters/parameter',
      :start($e), :to-list);
  for @prmtrs -> $p {
    if $p.name eq 'instance-parameter' {
      my Str ( $doc, $type, $raku-ntype, $raku-rtype) = self.get-doc-type($p);
      my Hash $attribs = $p.attribs;
      my Str $parameter-name = $attribs<name>;
      $parameter-name ~~ s:g/ '_' /-/;
      my Hash $ph = %(
        :name($parameter-name), :!allow-none, :!nullable, :is-instance,
        :transfer-ownership($attribs<transfer-ownership>),
        :$doc, :$type, :$raku-ntype, :$raku-rtype
      );

      @parameters.push: $ph;
    }

#  @prmtrs = $!xpath.find( 'parameters/parameter', :start($e), :to-list);
#  for @prmtrs -> $p {

    elsif $p.name eq 'parameter' {
      my Str ( $doc, $type, $raku-ntype, $raku-rtype) = self.get-doc-type($p);
      my Hash $attribs = $p.attribs;
      my Hash $ph = %(
        :name($attribs<name>), :allow-none($attribs<allow-none>.Bool),
        :nullable($attribs<nullable>.Bool), :!is-instance,
        :transfer-ownership($attribs<transfer-ownership>),
        :$doc, :$type, :$raku-ntype, :$raku-rtype
      );

      @parameters.push: $ph;
    }
  }

  ( $function-name, %(
      :$option-name, :$function-doc, :@parameters,
      :$rv-doc, :$rv-type, :$return-raku-ntype, :$return-raku-rtype,
      :$rv-transfer-ownership,
    )
  );
}

#-------------------------------------------------------------------------------
method get-doc-type ( XML::Element $e --> List ) {

  my Str ( $doc, $type, $raku-ntype, $raku-rtype, $g-type) =
     ( '', '', '', '', '');
  for $e.nodes -> $n {
    next if $n ~~ XML::Text;
    with $n.name {
      when 'doc' {
        $doc = self!cleanup(
          self!modify-text(($!xpath.find( 'text()', :start($n)) // '').Str)
        );
      }

      when 'type' {
        $type = $n.attribs<name>;
        $type ~~ s:g/ '.' //;
        $raku-ntype = self.convert-ntype($n.attribs<c:type> // $type);
        $raku-rtype = self.convert-rtype($n.attribs<c:type> // $type);
        $g-type = self.gobject-value-type($raku-ntype);
      }
    }
  }

  ( $doc, $type, $raku-ntype, $raku-rtype, $g-type)
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
method search-name ( Str $name is copy --> Hash ) {

  my Hash $h = %();
  for <Gtk Gdk Gsk Glib Gio GObject Pango Cairo PangoCairo> -> $map-name {

    # It is possible that not all hashes are loaded
    next unless $!object-maps{$map-name}:exists
            and ( $!object-maps{$map-name}{$name}:exists 
                  or $!object-maps{$map-name}{$map-name ~ $name}:exists
                );

    # Get the Hash from the object maps
    $h = $!object-maps{$map-name}{$name}
         // $!object-maps{$map-name}{$map-name ~ $name};

    # Add package name to this hash
    $h<raku-package> = $!other-work-data{$map-name}<raku-package>;
    last;
  }

#say "$?LINE: search $name -> {$h<rname> // $h.gist}";

  $h
}

#-------------------------------------------------------------------------------
method convert-ntype ( Str $ctype is copy --> Str ) {
  return '' unless ?$ctype;

  # ignore const
  $ctype ~~ s:g/\s* const \s*//;

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
        >
    ) {
      $raku-type = "g$ctype";
    }

#TODO check for any other types in gir files
#grep 'name="' Gtk-3.0.gir | grep '<type' | sed 's/^[[:space:]]*//' | sort -u

#    when $*work-data<gnome-type> {
#      $raku-type = 'N-GObject';
#    }

#TODO int/num/pointers as '$x is rw'
    # ignore const
    when /g? char \s* '*'/         { $raku-type = 'Str'; }
    when /g? char \s* '*' \s* '*'/ { $raku-type = 'CArray[Str]'; }
    when /g? int \s* '*'/          { $raku-type = 'CArray[gint]'; }
#    when /GtkWidget \s* '*'/       { $raku-type = 'N-GObject'; }
    when /GError \s* '*'/          { $raku-type = 'CArray[N-GError]'; }

    when 'void' { $raku-type = 'void'; }

    default {
      # remove any pointer marks
      $ctype ~~ s:g/ '*' //;

      my Hash $h = self.search-name($ctype);
      given $h<gir-type> // '-' {
        when 'class' { $raku-type = 'N-GObject'; }
        when 'enumeration' { $raku-type = 'GEnum'; }
        when 'bitfield' { $raku-type = 'GFlag'; }

#        when 'record' { }
#        when 'callback' { }
#        when 'interface' { }
#        when '' { }

        default {
          note 'Unknown gir type to convert to native raku type ', $h<gir-type> // '-',
               ' for ctype ', $ctype;
        }
      }
    }
  }

#say "$?LINE: convert to raku native type: '$ctype' -> '$raku-type'" if $ctype ~~ m/ gchar /;

  $raku-type
}

#-------------------------------------------------------------------------------
method convert-rtype ( Str $ctype is copy --> Str ) {
  return '' unless ?$ctype;

  # ignore const
  $ctype ~~ s:g/\s* const \s*//;

  my Str $raku-type = '';
  with $ctype {
    when / g? boolean / {
      $raku-type = 'Bool';
    }

    when any(<gchar gint gint16 gint32 gint64 gint8
         glong gshort gsize gssize char int int16 int32 int64 int8
         long short size ssize
         >
    ) {
      $raku-type = 'Int';
    }

    when any(<guchar guint guint16 guint32 guint64
         guint8 gulong gunichar gushort uchar uint uint16 uint32 uint64
         uint8 ulong unichar ushort
         >) {
      $raku-type = 'UInt';
    }

    when /g [float || double]/ {
      $raku-type = 'Num';
    }

#TODO check for any other types in gir files
#grep 'name="' Gtk-3.0.gir | grep '<type' | sed 's/^[[:space:]]*//' | sort -u

#    when $*work-data<gnome-type> {
#      $raku-type = 'N-GObject';
#    }

#TODO int/num/pointers as '$x is rw'
    when /g? char \s* '*'/         { $raku-type = 'Str'; }
    when /g? char \s* '*' \s* '*'/ { $raku-type = 'CArray[Str]'; }
    when /g? int \s* '*'/          { $raku-type = 'CArray[gint]'; }
#    when /GtkWidget \s* '*'/       { $raku-type = 'N-GObject'; }
    when /GError \s* '*'/          { $raku-type = 'CArray[N-GError]'; }

    when 'void' { $raku-type = 'void'; }

    default {
      # remove any pointer marks
      $ctype ~~ s:g/ '*' //;

      my Hash $h = self.search-name($ctype);
      given $h<gir-type> // '-' {
        when 'class' { $raku-type = 'N-GObject'; }
        when 'enumeration' { $raku-type = 'Int'; }
        when 'bitfield' { $raku-type = 'UInt'; }

#        when 'record' { }
#        when 'callback' { }
#        when 'interface' { }
#        when '' { }

        default {
          note 'Unknown gir type to convert to raku type', $h<gir-type> // '-',
               ' for ctype ', $ctype, ', ', $*work-data<gnome-type>;
        }
      }
    }
  }

#say "$?LINE: convert raku type; '$ctype' -> '$raku-type'" if $ctype ~~ m/ gchar /;

  $raku-type
}

#-------------------------------------------------------------------------------
method !modify-text ( Str $text is copy --> Str ) {

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

  $text = self!modify-signals($text);
  $text = self!modify-properties($text);
  $text = self!modify-functions($text);
  $text = self!modify-variables($text);
  $text = self!modify-markdown-links($text);
  $text = self!modify-classes($text);
  $text = self!modify-rest($text);

  # Subtitute the examples back into the text before we can finally modify it
  for $examples.keys -> $ex-key {
    $text ~~ s/ $ex-key /$examples{$ex-key}/;
  }

  $text = self!modify-xml($text);
  $text = self!modify-examples($text);

  $text
}

#-------------------------------------------------------------------------------
# Modify text '::sig-name'
method !modify-signals ( Str $text is copy --> Str ) {

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
method !modify-variables ( Str $text is copy --> Str ) {

  $text ~~ s:g/ \s? '@' (\w+) / C<\$$0>/;

  $text
}

#-------------------------------------------------------------------------------
method !modify-build-variables (
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
method !modify-functions ( Str $text is copy --> Str ) {

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
method !modify-classes ( Str $text is copy --> Str ) {

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

    if ?$raku-name {
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
method !modify-examples ( Str $text is copy --> Str ) {

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="xml"' \s* '-->' 
              /=begin comment\nFollowing text is XML\n=begin code\n/;

  $text ~~ s:g/^^ '|[<!-- language="plain" -->'
              /=begin comment\n=begin code/;

  $text ~~ s:g/^^ '|[' \s* '<!--' \s* 'language="C"' \s* '-->' 
              /=begin comment\n=begin code/;

  $text ~~ s:g/^^ ']|' /=end code\n=end comment\n/;

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
method !modify-markdown-links ( Str $text is copy --> Str ) {
  $text ~~ s:g/ \s '[' ( <-[\]]>+ ) '][' <-[\]]>+ ']' / $0/;

  $text
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
