
=begin pod

=head1 Find data using a filename

Generate code, documentation or test files contained in a file. The data is found in a C<repo-object-map.yaml>. It tests for every key where a sub-key matches the given filename. Then the found data is stored in a Hash C<$!filedata> with the top key its type of each found key.

When processing this Hash, the types class, interface, record and union are stored in separate files and the rest is gathered in a single file. This breaks compatibility with older packages but it is now possible to select the proper files more specificly.

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
#use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Prepare;

use XML;
use XML::XPath;
use JSON::Fast;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::File:auth<github:MARTIMM>;

#has Gnome::SourceSkimTool::SearchAndSubstitute $!sas;
has Gnome::SourceSkimTool::Code $!mod;
#has Gnome::SourceSkimTool::Doc $!grd;

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
  if $*verbose {
    note "\nTypes found in file $!filename";
    for $!filedata.kv -> $t, $h {
      note "\n  $t: $h.keys()";
    }
  }

  my Str ( $fname, $rname, $c);
#  $*gnome-class = $!filename.tc;
#  my Gnome::SourceSkimTool::Prepare $prepare .= new;
  for $!filedata.keys {
    # -> $type-name

    when 'class' {
      # There will always be one class in a file
      $*gnome-class = $!filedata<class>.values[0]<mname>;
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
      $*gnome-class = S/^ 'R-' // with $!filedata<interface>.values[0]<mname>;
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
#`{{
        $*gnome-class = $record-name;
        my Str $gnome-package = $*gnome-package.Str;
        $gnome-package ~~ s/ \d+ $//;
        $*gnome-class ~~ s/^ $gnome-package //;
}}
        $*gnome-class = self!chop-packagename($record-name);
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

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
      my Str $gnome-package = $*gnome-package.Str;
      $gnome-package ~~ s/ \d+ $//;
      $*gnome-class ~~ s/^ $gnome-package //;
      my Gnome::SourceSkimTool::Prepare $prepare .= new;

      say "Generate Raku role from ", $*work-data<raku-class-name> if $*verbose;

      require ::('Gnome::SourceSkimTool::Union');
      my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
      $raku-module.generate-code if $*generate-code;
      $raku-module.generate-test if $*generate-test;
      $raku-module.generate-doc if $*generate-doc;
    }
  }

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
#      $*gnome-class = $!filedata<constant>.values[0]<mname>;
#      my Gnome::SourceSkimTool::Prepare $prepare .= new;

      my @constants = ();
      for $!filedata<constant>.kv -> $k, $v {
        # The name to search for later must be without package prefix
        my Str $name = $k;
        my Str $pname = S/ \d+ $// with $*gnome-package.Str;
        $name ~~ s:i/^ $pname '_'//;
#note "\n$?LINE E $k, $name, $pname, $v.gist()";
        @constants.push: ( $name, $v<sname>);
        $fname = "$*work-data<result-path>$v<mname>.rakumod" unless ?$fname;
        $rname = $v<rname> unless ?$rname;
      }

      $c ~= $!mod.generate-constants(@constants);
    }

    when 'enumeration' {
#      $*gnome-class = $!filedata<enumeration>.values[0]<mname>;
#      my Gnome::SourceSkimTool::Prepare $prepare .= new;

      my Array $enum-names = [];
      for $!filedata<enumeration>.kv -> $k, $v {
#note "\n$?LINE E $k, $v.gist()";
        $enum-names.push: $k;
        $fname = "$*work-data<result-path>$v<mname>.rakumod" unless ?$fname;
        $rname = $v<rname> unless ?$rname;
      }

      $c ~= $!mod.generate-enumerations-code(:$enum-names);
    }

    when 'bitfield' {
#      $*gnome-class = $!filedata<bitfield>.values[0]<mname>;
#      my Gnome::SourceSkimTool::Prepare $prepare .= new;

      my Array $bitfield-names = [];
      for $!filedata<bitfield>.kv -> $k, $v {
#note "\n$?LINE B $k, $v.gist()";
        $bitfield-names.push: $k;
        $fname = "$*work-data<result-path>$v<mname>.rakumod" unless ?$fname;
        $rname = $v<rname> unless ?$rname;
      }

      $c ~= $!mod.generate-bitfield-code(:$bitfield-names);
    }

    when 'callback' {
      
    }

    when 'function' {
      
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
      $code ~= $!mod.generate-enumerations-code(:$enum-names);
    }

    if $!filedata<bitfield>:exists {
      my Array $bitfield-names = [];
      $bitfield-names = [$!filedata<bitfield>.keys];
      $code ~= $!mod.generate-bitfield-code(:$bitfield-names);
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
  my Str $code = qq:to/RAKUMOD/;
    use v6;
    RAKUMOD
#note "$?LINE $rname";

  $code ~= $!mod.set-unit-for-file($rname) ~ $c ~ "\n";

  if ?$fname and ?$code {
    note "Save module for types";
#    "$*work-data<result-path>$*gnome-class.rakumod".IO.spurt($code);
    $fname.IO.spurt($code);
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
# 'class-file' field of every object must match $filename. The data is reordered
# to have its type as its toplevel key.
method !get-data-from-filename ( ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  my Hash $h := $*object-maps{$package};
  $!filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<class-file>:exists and $v<class-file> eq $!filename;

    # Reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}

#-------------------------------------------------------------------------------
method !chop-packagename ( Str:D $name is copy --> Str ) {
  my Str $gnome-package = $*gnome-package.Str;

  # in case package has a version 3 or 4 attached
  $gnome-package ~~ s/ \d+ $//;
  $name ~~ s/^ $gnome-package //;

  $name
}
