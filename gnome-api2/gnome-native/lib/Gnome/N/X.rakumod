#TL:1:Gnome::N::X

use v6.d;

#-------------------------------------------------------------------------------
class X::Gnome is Exception {
  has $.message;

  #TM:1:new():
  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
class Gnome::N {

#-------------------------------------------------------------------------------
=begin pod
=head2 Gnome::N::debug

There are many situations when exceptions are retrown within code of a callback method, Raku is sometimes not able to display the error properly. In those cases you need another way to display errors and show extra messages leading up to it. For instance turn debugging on.

  sub Gnome::N::debug ( Bool :$on, Bool :$off )

=item :on; turn debugging on
=item :!on; turn debugging off
=item :off; turn debugging off
=item :!off; turn debugging on

When both arguments are used, :on has preverence over :off. When no arguments are provided, the debugging is turned off.

The state is saved in `$Gnome::N::x-debug` and can be accessed directly to get
its state.

=end pod

  #TS:1:x-debug:
  #TM:1:debug():
  our $Gnome::N::x-debug = False;
  our &Gnome::N::debug = sub ( Bool :$on, Bool :$off ) {

    # when both are undefined only return debug state
    if !$on.defined and !$off.defined {
      $Gnome::N::x-debug = False;
    }

    # when only $off is defined, set debug to its opposite
    elsif !$on.defined and $off.defined {
      $Gnome::N::x-debug = !$off;
    }

    # all other cases $on is defined and has preverence above $off
    else {
      $Gnome::N::x-debug = $on;
    }
  }

#-------------------------------------------------------------------------------
=begin pod
=head2 Gnome::N::deprecate

Set a deprecation message whith the Raku trait 'is DEPRECATED' on classes and methods is not sufficient enough. Like those, a message is generated when the X module ends, i.e. when your application exits (hopefully ;-).

  sub Gnome::N::deprecate (
    Str $old, Str $new,
    Str $since-version, Str $remove-version,
    Str :$gnome-lib = '', Bool :$class = False
  )

=item $old; Method or class as it was used.
=item $new; New method or class or way to use or non when no replacement is made.
=item $since-version; When it was deprecated. Version is from package wherein the module/class and method is defined.
=item $remove-version; Version of package when the method will be removed.
=item When $gnome-lib is set, the $remove-version is the version of the gnome lib and $remove-version is ignored.

=end pod

  #TM:1:deprecate():
  my $x-deprecated = %();
  our &Gnome::N::deprecate = sub (
    Str $old, Str $new,
    Str $deprecate-version, Str $remove-version,
    Str :$gnome-lib = '', Bool :$class = False
  ) {

    my Str $cf-file;
    my $cf-line;
    for ^100 -> $cfi {
      try {
        my $cf = callframe($cfi);
        $cf-file = $cf.file;
        next if $cf-file ~~ m/ | '.nqp'
                               | '.moarvm'
                               | 'Gnome::'
                               | 'Mu.rakumod'
                             /;

#note "$?LINE callframe; {$cf-file.IO.basename} {$cf.annotations}";
        $cf-line = $cf.line();
        last;

        CATCH {
          # No callframe at level …
          #.note;
          last;
        }
      }
    }

    # found this one before?
    if !$x-deprecated{$cf-file}{"$old $new"} {
      $cf-file ~~ s/ \( <-[)]>+ \) .* //;
      $cf-file ~~ s/$*HOME/~/;

      my %message-data = %(
        :$cf-file, :$cf-line, :$old, :$new,
        :$deprecate-version, :$remove-version, :$gnome-lib, :$class
      );

      $x-deprecated{$cf-file}{"$old $new"} = %message-data;
    }

    else {
      my %message-data := $x-deprecated{$cf-file}{"$old $new"};
      %message-data{'cf-line'} ~= ", $cf-line"
        unless %message-data{'cf-line'} ~~ m/ <?wb> $cf-line <?wb> /;
    }
  }

  # if this object ends throw out the deprecation messages if any
  END {
    if ?$x-deprecated {
      note '=' x 80; #, '  Deprecations found at';
      for $x-deprecated.keys.sort -> $file {
        for $x-deprecated{$file}.keys.sort -> $m {
          my %message-data := $x-deprecated{$file}{$m};
          my Bool $native = ?%message-data<gnome-lib>;

          my Str $message = '';
          if %message-data<class> {
            if $native {
              $message ~= "The native representation of class %message-data<old> is deprecated";
            }

            else {
              $message ~= "Class %message-data<old> is deprecated";
            }
          }

          else {
            if $native {
              $message ~= "The native representation of method %message-data<old> is deprecated";
            }

            else {
              $message ~= "Method %message-data<old> is deprecated";
            }
          }

          if $native {
            $message ~= " in %message-data<gnome-lib> library since version %message-data<deprecate-version>.\n";
          }

          else {
            $message ~= " since version %message-data<deprecate-version>.\n";
            if ?%message-data<remove-version> and %message-data<class> {
              $message ~= "This class will be removed after version %message-data<remove-version>.\n";
            }

            elsif ?%message-data<remove-version> {
              $message ~= "Method will be removed from this class after version %message-data<remove-version>.\n";
            }

            if ?%message-data<new> {
              $message ~= "Please use %message-data<new> instead.\n";
            }
          }

          $message ~= "Found in file %message-data<cf-file> at lines %message-data<cf-line>.\n";
#`{{
          note Q:qq:to/EOTXT/;
            Method '%message-data<old> is deprecated in favor of '%message-data{"new-method"}'
            Deprecated since version %message-data{"deprecate-version"} and will be removed at version %message-data{"remove-version"}
            Found in file %message-data{'cf-file'} at lines %message-data{'cf-line'}
          EOTXT
}}
          note $message, "\n", '-' x 80;
        }
      }

      # and when it ends more than once, clear it just in case
      $x-deprecated = %();
    }
  }
}

#-------------------------------------------------------------------------------
sub test-call-without-natobj ( Callable:D $found-routine, |c ) is export {

  note "\nCalling sub $found-routine.gist()\(\n  ",
    stringify( |c, :join-str(",\n  ")), "\n);" if $Gnome::N::x-debug;
  $found-routine(|c)
}

#-------------------------------------------------------------------------------
sub test-call ( Callable:D $found-routine, $gobject is rw, |c ) is export {

#TODO would like to simplify but e.g. gtk_builder_new_from_string() in
# Gnome::Gtk3::Builder does not need a N-Object inserted on 1st argument
# so need another test

  my List $sig-params = $found-routine.signature.params;
  note "\nSignature parameters of $found-routine: ", |$sig-params if $Gnome::N::x-debug;

  my $result;
  if +$sig-params and

    # test for native object in any of the Gnome packages
    $sig-params[0].type.^name ~~ m/^ ['Gnome::' .*?]? [ 'N-G' || cairo ] / {

    note "\nCalling sub $found-routine.gist()\(\n  ",
      stringify( $gobject, |c, :join-str(",\n  ")), "\n);"
      if $Gnome::N::x-debug;

    $result = $found-routine( $gobject, |c)
  }

  else {
    note "Calling sub $found-routine.gist()\(\n  ",
      stringify( |c, :join-str(",\n  ")), "\n);"
      if $Gnome::N::x-debug;

    $result = $found-routine(|c)
  }

#note "test-call R: {$result//'-'}";
  $result
}

#-------------------------------------------------------------------------------
sub stringify ( *@list, Str :$join-str = ', ', *%options --> Str ) {

  map( {
      if ! $_.defined {
        $_.WHAT.gist;
      }

      elsif $_ ~~ Str {
        "'$_'";
      }

      elsif $_ ~~ any(Num|Int|Rat) {
        $_;
      }

      elsif $_ ~~ Pair {
        if $_.value.WHAT ~~ Bool {
          [~] ':', $_.value ?? '' !! '!', $_.key;
        }
        else {
          [~] ':', $_.key, '(...)';
#`{{
          [~] ':', $_.key, '(', ?$_.value ?? $_.value !! 'undefined', ')';
}}
        }
      }

      else {
        $_.perl;
      }
    }, ( |@list, |%options)
  )>>.Str.join($join-str)
}
