use v6.d;

=begin pod

=head1 Generate Raku files using a filename.

=end pod

use Gnome::SourceSkimTool::ConstEnumType;
use Gnome::SourceSkimTool::Code;
use Gnome::SourceSkimTool::Doc;
use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::Resolve;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GenerateDoc:auth<github:MARTIMM>;

has Gnome::SourceSkimTool::Code $!mod;
has Gnome::SourceSkimTool::Doc $!grd;
has Gnome::SourceSkimTool::Resolve $!solve;

has Str $!filename;
has Hash $!filedata;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$!filename ) {
  $!mod .= new;
  $!grd .= new;

  $!filedata = $!solve.new.get-data-from-filename($!filename);
}

#-------------------------------------------------------------------------------
method generate-doc ( ) {

  # Info of types found
  note "\nTypes found in file $!filename";
  for $!filedata.kv -> $t, $h {
    note "  $t: $h.keys()";
    print "\n";
  }

  my Str ( $filename, $class-name, $function-hash);
  my Bool $has-functions = False;
  my Hash $types-code = %();
  $types-code<record> = $types-code<union> = '';

  for $!filedata.keys {
    # -> $type-name

    next if ?@*gir-type-select and ($_ ~~ none(|@*gir-type-select));

    # First check keys class, interface, record and union
    when 'class' {
      for $!filedata<class>.keys -> $class-name {

        $*gnome-class = $!filedata<class>{$class-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        require ::('Gnome::SourceSkimTool::Class');
        my $raku-module = ::('Gnome::SourceSkimTool::Class').new;
        
        say "\nGenerate documentation for Raku class ", 
            $*work-data<raku-class-name>;
        $raku-module.generate-doc;
      }
    }

    when 'interface' {
     for $!filedata<interface>.keys -> $interface-name {
        $*gnome-class = $!filedata<interface>{$interface-name}<gnome-name>;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        require ::('Gnome::SourceSkimTool::Interface');
        my $raku-module = ::('Gnome::SourceSkimTool::Interface').new;

        say "\nGenerate documentation for Raku role ", 
            $*work-data<raku-class-name>;
        $raku-module.generate-doc;
      }
    }

    when 'record' {
note "$?LINE doc $!filedata<record>.keys()";
      for $!filedata<record>.keys -> $record-name {
        $*gnome-class = $record-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;
#`{{
        # Generate a structure into a 'package-path/N-*.rakumod' file
        $!mod.generate-structure(
          |$!mod.init-xpath(
            'record',
            "$*work-data<gir-module-path>R-$*gnome-class.gir"
#            'gir-record-file'
          )
        );
}}
        require ::('Gnome::SourceSkimTool::Record');
        my $raku-module = ::('Gnome::SourceSkimTool::Record').new;
        $raku-module.generate-doc;

        say "\nGenerate documentation for Raku record ",
            $*work-data<raku-class-name>;
        $types-code<record> ~= $raku-module.generate-structure-doc;
      }
    }

#`{{
    when 'union' {
      for $!filedata<union>.keys -> $union-name {
        $*gnome-class = $union-name;
        my Gnome::SourceSkimTool::Prepare $prepare .= new;

        # Generate a union into a 'package-path/N-*.rakumod' file
        $!mod.generate-union(
          |$!mod.init-xpath(
            'union',
            "$*work-data<gir-module-path>U-$*gnome-class.gir"
#            'gir-union-file'
          )
        );

        say "\nGenerate documentation for Raku union ", $*work-data<raku-class-name>;

        require ::('Gnome::SourceSkimTool::Union');
        my $raku-module = ::('Gnome::SourceSkimTool::Union').new;
        $raku-module.generate-code;
      }
    }
}}
  }

#  my Bool $first = True;
  my Hash $types-doc = %();
  my Gnome::SourceSkimTool::Prepare $t-prep .= new;
  for $!filedata.keys.sort -> $gir-type {
    # Records and unions must be seen here to generate a type file when
    # only one of those are available
    next if $gir-type ~~ any(<class interface>);
    next if $gir-type ~~ any(<alias function-macro>);

    # Test if gir-type is selected Skip a key if not mentioned on the
    # commandline or just do it when there is no preference
    next if ?@*gir-type-select and ($gir-type ~~ none(|@*gir-type-select));

    my Hash $data = $!filedata{$gir-type}.values[0];

    next unless ?$data<type-name>;

    # When there are only records and unions, the names start with 'N-'.
    # For a types file/class it must start with 'T-'.
    $data<type-letter> = 'T';
    $data<package-name> = $*work-data<raku-package>;

    $*gnome-class = $data<type-name>;

#    my Str $type-name = $data<type-name>;
#    my Str $prefix = $*work-data<name-prefix>;
#    $type-name ~~ s:i/^ 'T-' $prefix /T-/;
#    $filename = [~] $*work-data<result-docs>, $type-name, '.rakudoc';
#    $filename = $!solve.set-object-name(
#      %( :type-name($*work-data<raku-name>), :type-letter<T>),
#      :name-type(FilenameDocType)
#    );

    $filename = $!solve.set-object-name( $data, :name-type(FilenameDocType));
    $class-name = $!solve.set-object-name($data);
#    $class-name = $!solve.set-object-name(
#      %( :type-name($*work-data<raku-name>), :type-letter<T>)
#    );
    #$data<class-name>;
#    $class-name ~~ s:i/ '::T-' $prefix /::T-/;
    $!mod.add-import($class-name);

    given $gir-type {
note "$?LINE $gir-type";
      when 'constant' {
        my @constants = ();
        for $!filedata<constant>.kv -> $k, $v {
          @constants.push: $k; #( $name, $v<constant-type>, $v<constant-value>);
        }

        $types-doc<constant> = $!grd.document-constants(@constants);
      }

      # Only for documentation
      when 'docsection' { }

      when 'enumeration' {
        my @enum-names = ();
        for $!filedata<enumeration>.kv -> $k, $v {
          @enum-names.push: $k;
        }

        $types-doc<enumeration> = $!grd.document-enumerations(@enum-names);
      }

      when 'bitfield' {
        my @bitfield-names = [];
        for $!filedata<bitfield>.kv -> $k, $v {
          @bitfield-names.push: $k;
        }

        $types-doc<bitfield> = $!grd.document-bitfield(@bitfield-names);
      }

      when 'callback' {
        my @callbacks = ();
        for $!filedata<callback>.kv -> $k, $v {
          @callbacks.push: $k;
        }

#note "$?LINE ", @callbacks.gist;
        $types-doc<callback> = $!grd.document-callback(@callbacks);
#note "$?LINE ", $types-doc<callback>;
      }

      when 'function' {
        $has-functions = True;
        my @function-names = [];
        for $!filedata<function>.kv -> $k, $v {
          @function-names.push: $v<function-name>;
        }

        $types-doc<function> =
          $!grd.document-standalone-functions(@function-names);
      }

      #when 'alias' { }
      #when 'function-macro' { }
    }
  }

  if ?$class-name and ?$filename {
    note "Document init" if $*verbose;
#    my Str $doc = $!grd.start-document('T');
    my Str $doc = qq:to/EODOC/;
      $*command-line
      use v6.d;

      =begin pod
      =TITLE $class-name
      =end pod
      
      EODOC

    $doc ~= qq:to/EODOC/ if ?$types-doc<function>;
      {pod-header('Class Initialization')}
      =begin pod
      =head1 Class initialization

      =head2 new

      Initialization of a type class is simple and only needed when the standalone functions are used.

        method new ( )

      =end pod
      EODOC

    $doc ~= [~] $types-code<record>,
                $types-code<union>,
                ($types-doc<constant> // ''),
                ($types-doc<enumeration> // ''),
                ($types-doc<bitfield> // ''),
                ($types-doc<callback> // ''),
                ($types-doc<function> // '');

    $!mod.save-file( $filename, $doc, "types documentation");
  }
}



=finish
#-------------------------------------------------------------------------------
# Fill the Hash $!filedata with data from a repo-object-map.yaml where the
# 'source-filename' field of every object must match $filename. The data is
# reordered to have its type as its toplevel key.
method !get-data-from-filename ( ) {

  my Str $package = S/ \d+ $// with $*gnome-package.Str;
  $!solve.check-search-list;
  $!solve.check-map($package);
  my Hash $h := $*object-maps{$package};
  $!filedata = %();

  for $h.kv -> $k, $v {
    next unless $v<source-filename>:exists
                and $v<source-filename> eq $!filename;

    # Reorder on type
    $!filedata{$v<gir-type>}{$k} = $v;
  }
}
