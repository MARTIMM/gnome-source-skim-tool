
=begin pod

=head1 Generate Raku files using a filename.

=head2 Find the data

Code and documentation is retrieved indirectly from C source files (originally in *.h and *.c). The data found is stored in a C<repo-object-map.yaml>. It tests for every key where a sub-key matches the given filename. Then the found data is stored in a Hash C<$!filedata> with the top key its type of each found key.

Gnome has a notion of several types of which the larger ones are C<classes>, C<interfaces>, C<records> and C<unions>. Written in the C-language, a class or interface does not exist. It is by clever programming that the Gnome team have introduced those by defining structures in a consistent way and added a set of subroutines to initialize and use the structures. They are called constructors and methods. A constructor returns an initialized structure and the methods use that structure.
There may also be subroutines, which are called functions, defined in a class or interface. They do not use the initialized structure but are added as a convenience routine.
The record is a C-stucture and the union is, well …, a union.


=head2 Generating code, doc or testfiles

When processing the C<$!filedata> Hash, the types C<class> and C<interface>, are stored in separate files and the rest is gathered in a single file. This breaks compatibility with older packages. This is an improvement because the data is better categorized into files and for the developer it is possible to select the proper files more specificly.
The C<class> code becomes a Raku class and an C<interface> code becomes a Raku role.
The C<record> and C<union> code is stored in one or two files depending if there are subroutines defined to manipulate the structures. The C<record> becomes a Raku C<repr('CStruct')> and the C<union> a Raku C<>

=item classes; The key of the sub-hash is used to create the class module. E.g a filename of C<aboutdialog> shows several types. The class type carries this key; C<GtkAboutDialog>. The class may be from Gtk3 and so the class name becomes B<Gnome::Gtk3::AboutDialog> and the files C<AboutDialog.*> (code, doc and tests are in separate files).

=item interfaces; These are the roles for Raku. The name is set the same way as for classes. The result modules have no use to the developer directly. They are used as a role by the classes. So it will be usefull to mark the role by prefixing them with I<R->. The name will then standout better. E.g. the file C<buildable> has an interface C<GtkBuildable> and delivers the module B<Gnome::Gtk3::R-Buildable> in files C<R-Buildable.*>. This is different from the older packages but would not be noticable.

=item records; Records are the C-structures which are the native Raku CStruct types. The name for that will be record name with I<N-> attached to it. E.g. The file C<events> has several records specified like C<GdkEventButton>. The results of that record becomes a class B<Gnome::Gdk3::N-EventButton> in files C<N-EventButton.*>.

=item union; Unions are also C-structures which are the Raku native CUnion types. The name for that will also be union name with I<N-> attached to it. E.g. The file C<events> has also a union specified like C<GdkEvent>. The results of that union becomes a class B<Gnome::Gdk3::N-Event> in files C<N-Event.*>.

=begin item
The other types are stored together in a separate file. The types can be enumerations, bitfields, constants, functions, etc. The name of the file will become the filename with its first letter uppercased and prefixed with I<T->.
E.g. the filename C<enums> has a lot of enumerations. The class name to store this data is B<Gnome::Gtk3::T-Enums> in file C<T-Enums.*>.
The file C<events> has also some enumerations and bitfields. Those are stored in files C<T-Events.*> with class B<Gnome::Gdk3::T-Events>.
This breaks also the compatebility with older packages in two ways because of its name and secondly, when a definition is needed the file must be imported explicitly where they were together in a class. However, the import (C<use>) is the only thing to change because 1) the class name is never used directly and 2) all declarations in the file are unchanged.
=end item

=end pod

use Gnome::SourceSkimTool::ConstEnumType;
#use Gnome::SourceSkimTool::SearchAndSubstitute;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Prepare;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::File:auth<github:MARTIMM>;

#has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Doc $!grd;

has XML::XPath $!xpath;

has Str $!filename;
has Hash $!filedata;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {
  $!mod .= new;

  self!get-data-from-filename;
}

#-------------------------------------------------------------------------------
method generate-code ( ) {

  # Info of types found
  note "\nTypes found in file $!filename";
  for $!filedata.kv -> $t, $h {
    note "  $t: $h.keys()";
    print "\n";
  }

  my Str ( $c, $filename, $class-name, $function-hash);
  my Bool $has-functions = False;
#  $*gnome-class = $!filename.tc;
#  my Gnome::SourceSkimTool::Prepare $prepare .= new;
  for $!filedata.keys {
    # -> $type-name

    when 'class' {
      # There will always be one class in a file
      $*gnome-class = $!filedata<class>.values[0]<gnome-name>;
      my Gnome::SourceSkimTool::Prepare $prepare .= new;

      say "\nGenerate Raku class ", $*work-data<raku-class-name> if $*verbose;

      require ::('Gnome::SourceSkimTool::Class');
      my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
      $raku-module.generate-code if $*generate-code;
      $raku-module.generate-test if $*generate-test;
      $raku-module.generate-doc if $*generate-doc;
    }

    when 'interface' {
      # There will always be one class in a file
#TODO must change when Prepare is changed
      $*gnome-class =
        S/^ 'R-' // with $!filedata<interface>.values[0]<gnome-name>;
      my Gnome::SourceSkimTool::Prepare $prepare .= new;

      say "\nGenerate Raku role ", $*work-data<raku-class-name> if $*verbose;

      require ::('Gnome::SourceSkimTool::Interface');
      my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;
      $raku-module.generate-code if $*generate-code;
      $raku-module.generate-test if $*generate-test;
      $raku-module.generate-doc if $*generate-doc;  
    }

    when 'record' {
      for $!filedata<record>.keys -> $record-name {
        $*gnome-class = $record-name;
#`{{
        my Str $gnome-package = $*gnome-package.Str;
        $gnome-package ~~ s/ \d+ $//;
        $*gnome-class ~~ s/^ $gnome-package //;
}}
#        $*gnome-class = self!chop-packagename($record-name);
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        #my XML::XPath $xpath .= new(:file($*work-data<gir-record-file>));
        #my XML::Element $element = $!xpath.find('//record');
        #die "//record elements not found in $*work-data<gir-record-file> for $*work-data<raku-class-name>" unless ?$element;
        
#        my XML::XPath $xpath;
#        my XML::Element $element;
#        ( $xpath, $element) = $!mod.init-xpath('record');
#        self.generate-structure( $element, $xpath);
        $!mod.generate-structure(|$!mod.init-xpath('record'));

        say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

        require ::('Gnome::SourceSkimTool::Record');
        my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
        $raku-module.generate-code if $*generate-code;
        $raku-module.generate-test if $*generate-test;
        $raku-module.generate-doc if $*generate-doc;
      }
    }

#`{{
  # If there is one record, generate a single raku module. The record
  # may have constructors and methods too
  elsif $!filedata<record>:exists and $!filedata<record>.keys.elems == 1 {
    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

    require ::('Gnome::SourceSkimTool::Record');
    my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }
}}

    when 'union' {
      for $!filedata<union>.keys -> $union-name {
        $*gnome-class = $union-name;
  #      my Str $gnome-package = $*gnome-package.Str;
  #      $gnome-package ~~ s/ \d+ $//;
  #      $*gnome-class ~~ s/^ $gnome-package //;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

        require ::('Gnome::SourceSkimTool::Union');
        my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
        $raku-module.generate-code if $*generate-code;
        $raku-module.generate-test if $*generate-test;
        $raku-module.generate-doc if $*generate-doc;
      }
    }
  }

  # int before continuing
  $*external-modules = [<
    NativeCall Gnome::N::NativeLib Gnome::N::N-GObject Gnome::N::GlibToRakuTypes
  >];

  for $!filedata.keys {
    # -> $type-name

#`{{
  # If there is one union, generate a single raku module. The union
  # may have constructors and methods too
  elsif $!filedata<union>:exists and $!filedata<union>.keys.elems == 1 {
    my Str $name = $!filedata<union>.keys[0];
    my Str $name-prefix = $*work-data<name-prefix>;
    $name ~~ s:i/^ $name-prefix //;
    $*gnome-class = $name;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

    require ::('Gnome::SourceSkimTool::Union');
    my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
    $raku-module.generate-code if $*generate-code;
    $raku-module.generate-test if $*generate-test;
    $raku-module.generate-doc if $*generate-doc;
  }
}}

    when 'docsection' {
      
    }

    when 'constant' {
      my @constants = ();
      for $!filedata<constant>.kv -> $k, $v {
        # The name to search for later must be without package prefix
        my Str $name = $k;
        my Str $pname = S/ \d+ $// with $*gnome-package.Str;
        $name ~~ s:i/^ $pname '_'//;
#note "\n$?LINE E $k, $name, $pname, $v.gist()";
        @constants.push: ( $name, $v<constant-type>, $v<constant-value>);
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      $c ~= $!mod.generate-constants(@constants);
    }

    when 'enumeration' {
      my Array $enum-names = [];
      for $!filedata<enumeration>.kv -> $k, $v {
#note "\n$?LINE E $k, $v.gist()";
        $enum-names.push: $k;
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      $c ~= $!mod.generate-enumerations-code($enum-names);
    }

    when 'bitfield' {
      my Array $bitfield-names = [];
      for $!filedata<bitfield>.kv -> $k, $v {
#note "\n$?LINE B $k, $v.gist()";
        $bitfield-names.push: $k;
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      $c ~= $!mod.generate-bitfield-code($bitfield-names);
    }

    when 'callback' {
      
    }

    when 'function' {
      $has-functions = True;
      my Array $function-names = [];
      for $!filedata<function>.kv -> $k, $v {
#note "\n$?LINE B $k, $v.gist()";
#        $function-names.push: S:g/ '-' /_/ with $v<function-name>;
        $function-names.push: $v<function-name>;
        $filename = $v<module-filename> unless ?$filename;
        $class-name = $v<class-name> unless ?$class-name;
      }

      my Str $package-name = S/ \d+ $// with $*gnome-package.Str;
      $*work-data<sub-prefix> = $package-name.lc ~ '_';

      my Hash $hms = $!mod.get-standalone-functions($function-names);
      $function-hash = $!mod.generate-functions($hms);
    }

    when 'alias' {
      
    }
  }

#`{{
  else {
    # No class or interface. This module becomes the mixture of all other types.
    my Bool $need-routine-caller = False;

    $*gnome-class = $!filename.tc;
    my Gnome::SourceSkimTool::Prepare $prepare .= new;

    my Str $code = qq:to/RAKUMOD/;
      #TL:1:$*work-data<raku-class-name>:
      use v6;
      RAKUMOD

    $code ~= $!mod.set-unit-for-file;

    if $!filedata<docsection>:exists {
    }

    if $!filedata<constant>:exists {
    }

    if $!filedata<enumeration>:exists {
      my Array $enum-names = [];
      $enum-names = [$!filedata<enumeration>.keys];
      $code ~= $!mod.generate-enumerations-code($enum-names);
    }

    if $!filedata<bitfield>:exists {
      my Array $bitfield-names = [];
      $bitfield-names = [$!filedata<bitfield>.keys];
      $code ~= $!mod.generate-bitfield-code($bitfield-names);
    }

#`{{
    # There are more than one records, gather them all in this module
    if $!filedata<record>:exists {
      for $!filedata<record>.keys -> $record-name {
        $*gnome-class = $record-name;
        my Str $gnome-package = $*gnome-package.Str;
        $gnome-package ~~ s/ \d+ $//;
        $*gnome-class ~~ s/^ $gnome-package //;

        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        say "Generate Raku record from $*gnome-class" if $*verbose;

        require ::('Gnome::SourceSkimTool::Record');
        my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
        $raku-module.generate-code if $*generate-code;
        $raku-module.generate-test if $*generate-test;
        $raku-module.generate-doc if $*generate-doc;
      }
    }

    # There are more than one unions, gather them all in this module
    if $!filedata<union>:exists {
    }
}}

    if $!filedata<callback>:exists {
    }

    if $!filedata<function>:exists {
      $need-routine-caller = True;
    }
}}


#TL:1:$*work-data<raku-class-name>:
  if ?$c and ?$class-name and ?$filename {
    my Str $code = qq:to/RAKUMOD/;
      # Command to generate: $*command-line
      use v6;
      RAKUMOD

    $code ~= $!mod.set-unit-for-file( $class-name, $has-functions);
    $code ~= $c ~ "\n";

    if $has-functions {
      $code ~= qq:to/RAKUMOD/;

      {$!grd.pod-header('BUILD variables')}
      # Define helper
      has Gnome::Glib::GnomeRoutineCaller \$!routine-caller;

      {$!grd.pod-header('BUILD submethod')}
      submethod BUILD ( ) \{
        # Initialize helper
        \$!routine-caller .= new\( :library\($*work-data<library>\), :sub-prefix\<$*work-data<sub-prefix>\>);
      }

      my Hash \$methods = \%\(
        $function-hash
      );

      RAKUMOD

      $code ~= q:to/RAKUMOD/;
        # This method is recognized in class Gnome::N::TopLevelClassSupport.
        method _fallback-v2 ( Str $n, Bool $_fallback-v2-ok is rw, *@arguments ) {
          my Str $name = S:g/ '-' /_/ with $n;
          if $methods{$name}:exists {
            my $native-object = self.get-native-object-no-reffing;
            $_fallback-v2-ok = True;
            return $!routine-caller.call-native-sub(
              $name, @arguments, $methods, :$native-object
            );
          }

          else {
            callsame;
          }
        }
        RAKUMOD
    }


    $code = $!mod.substitute-MODULE-IMPORTS($code);

    note "Save types module in ", $filename.IO.basename;
#    "$*work-data<result-path>$*gnome-class.rakumod".IO.spurt($code);
    $filename.IO.spurt($code);
  }
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {
}

#-------------------------------------------------------------------------------
method generate-test ( ) {
}

#-------------------------------------------------------------------------------
# Fill the Hash $!filedata with data from a repo-object-map.yaml where the
# 'source-filename' field of every object must match $filename. The data is
# reordered to have its type as its toplevel key.
method !get-data-from-filename ( ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  my Hash $h := $*object-maps{$package};
  $!filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<source-filename>:exists
                and $v<source-filename> eq $!filename;

    # Reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}


=finish
#-------------------------------------------------------------------------------
method !chop-packagename ( Str:D $name is copy --> Str ) {
  my Str $gnome-package = $*gnome-package.Str;

  # in case package has a version 3 or 4 attached
  $gnome-package ~~ s/ \d+ $//;
  $name ~~ s/^ $gnome-package //;

  $name
}
