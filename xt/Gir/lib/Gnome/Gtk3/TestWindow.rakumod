
use NativeCall;

use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::GlibToRakuTypes;
#use Gnome::N::Gir;

use Gnome::Gtk3::Bin;

use Gnome::Glib::Error;

use Gnome::Glib::GnomeRoutineCaller:api('gir');

#-------------------------------------------------------------------------------
unit class Gnome::Gtk3::TestWindow:api('gir');
also is Gnome::Gtk3::Bin;

#constant \Error = Gnome::Glib::Error;

my Bool $signals-added = False;
has Gnome::Glib::GnomeRoutineCaller $!routine-caller;
#-------------------------------------------------------------------------------
#TE:1:GtkWindowType:
enum GtkWindowType is export <
  GTK_WINDOW_TOPLEVEL GTK_WINDOW_POPUP
>;

#TE:1:GtkWindowPosition:
enum GtkWindowPosition is export <
  GTK_WIN_POS_NONE
  GTK_WIN_POS_CENTER
  GTK_WIN_POS_MOUSE
  GTK_WIN_POS_CENTER_ALWAYS
  GTK_WIN_POS_CENTER_ON_PARENT
>;

#-------------------------------------------------------------------------------
# Names from g_irepository_get_shared_library
# Install in TopLevelClassSupport in Gnome::N::NativeLib

#constant $library = 'libgtk-3.so.0';
#constant $sub-prefix = 'gtk_window_';

#has Bool $!pointers-in-args;

#`{{
enum RoutineType (
  'Constructor',            # Constructors will return an object of this class
  'Method',                 # First argument must be an instance parameter
                            # but is not noted in the parameters list. This
                            # is the default type and maybe left.
  'Function'                # The instance parameter is not inserted.
);
}}

# this hash is build using the gir repo
my Hash $methods = %(
  new => %(                 # We know to prefix 'gtk_window_' in this module
    :type(Constructor),     # Type of routine
    :parameters([GEnum]),   # Parameter types
    :returns(N-GObject),    # Return type if any,
  ),

  get_default_size => %(
    :parameters([ gint-ptr, gint-ptr]),
  ),

  get_position => %(
    :parameters([ gint-ptr, gint-ptr]),
  ),

  set_icon_from_file => %(
    :parameters([gchar-ptr]),
    :returns(CArray[N-GError]),
  ),

  get_size => %(
    :parameters([ gint-ptr, gint-ptr]),
  ),

  get_title => %(
    :returns(gchar-ptr),
  ),

  set_keep_above => %(
    :parameters([gboolean]),
  ),

  set_title => %(
    :parameters([gchar-ptr]),
  ),

  set_default_icon_from_file => %(
    :type(Function),
    :parameters([ gchar-ptr, CArray[N-GError]]),
    :returns(gboolean),
  ),
);

#-------------------------------------------------------------------------------
submethod BUILD ( *@arguments, *%options ) {
 
  $signals-added = self.add-signal-types( $?CLASS.^name,
    :w0<activate-default activate-focus keys-changed>,
    :w1<enable-debugging set-focus>,
  ) unless $signals-added;

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gtk3::TestWindow' or %options<GtkWindow> {

    # Initialize helper
    $!routine-caller .= new(
      :library(gtk-lib()), :sub-prefix<gtk_window_>, :!is-leaf
    );

    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<window-type> {
        $no = self._fallback-v2( 'new', my Bool $x, %options<window-type>);
      }

      #`{{ use this when the module is not made inheritable
      # check if there are unknown options
      elsif %options.elems {
        die X:Gnome.new(
          :message(
            'Unsupported, undefined, incomplete or wrongly typed options for ' ~
            self.^name ~ ': ' ~ %options.keys.join(', ')
          )
        );
      }
      }}

      #`{{ when there are no defaults use this
      # check if there are any options
      elsif %options.elems == 0 {
        die X:Gnome.new(:message('No options specified ' ~ self.^name));
      }
      }}

      ##`{{ when there are defaults use this instead
      # create default object
      else {
        $no = self._fallback-v2( 'new', my Bool $x, GTK_WINDOW_TOPLEVEL);
      }
      #}}

#note "$?LINE $no,gist()";
      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkWindow');
  }
}

#-------------------------------------------------------------------------------
method _fallback-v2 (
  Str $name is copy, Bool $_fallback-v2-ok is rw, *@arguments
) {
  $name ~~ s:g/ '-' /_/;
#note "\n$?LINE func $name {$methods{$name}:exists}";
  if $methods{$name}:exists {
    my $native-object = self.get-native-object-no-reffing;
 #self._f('GtkWindow');

#note "$?LINE no = {$native-object // '-'}";
    $_fallback-v2-ok = True;
    $!routine-caller.call-native-sub(
      $name, @arguments, $methods, :$native-object
    );
  }

  else {
#note "callsame";
   callsame;
  }
}

=finish

#  Str $name is copy, @arguments, Hash $methods, Str $library,
#  Str $sub-prefix, $widget, Str $widget-name, Bool $is-leaf












unit class Gnome::Glib::MethodHelper;

use Gnome::Glib::Error;
has Bool $!pointers-in-args;

#-------------------------------------------------------------------------------
method call-native-sub (
  Str $name is copy, @arguments, Hash $methods, Str $library, Str $sub-prefix
) {

  # Dashes to underscores
  $name ~~ s:g/ '-' /_/;
  die "Method $name not found" unless $methods{$name}:exists;

  # Set False, is set in native-parameters() as a side effect
  $!pointers-in-args = False;

  my Hash $routine := $methods{$name};
#note "\n", $?LINE, ', ', $name, ', ', $routine.gist;

# this check fails when pointers to variables are used.
#  die "Number of arguments not sufficient"
#    unless @arguments.elems >= abs($routine<parameters>.elems);

  my @parameters = $routine<parameters>:exists
                 ?? @($routine<parameters>)
                 !! ();

  # Get native parameters converted from @arguments
  my @native-args = self.native-parameters( @arguments, @parameters, $routine);
#note "$?LINE ", @arguments.gist, ', ', @parameters.gist, ', ', $routine,.gist, ', ', @native-args.gist;
  # Get routine address
  $routine<function-address> //=
    self.native-function( $name, @parameters, $routine, $library, $sub-prefix);

  # Call routine
  # If there are pointers in the argument list, values are placed
  # there. Mostly returned like this when there is more than one value,
  # otherwise it could have been returned the normal way using $x.
#note "$?LINE $!pointers-in-args";
  if $!pointers-in-args {
    my $x = $routine<function-address>(|@native-args);
    return self.make-list-from-result( @native-args, @parameters, $routine, $x)
  }

  else {
    my $x = self.convert-return(
      $routine<function-address>(|@native-args), $routine<returns>
    );

    return $x
  }
}

#-------------------------------------------------------------------------------
method native-parameters ( @arguments, @parameters, Hash $routine --> List ) {
  my @native-args = ();

  given $routine<type> {
    when Constructor { }
    when Function { }
    #when Method { }
    default {
      @native-args.push: self._f('GtkWindow');
    }
  }

  loop (my $i = 0; $i < @parameters.elems; $i++ ) {
    my $p = @parameters[$i];
    my $a = self.convert-args( @arguments[$i], $p);
    @native-args.push: $a;
    $!pointers-in-args = True if $p.^name ~~ m/ CArray /;
  }

  @native-args
}

#-------------------------------------------------------------------------------
method native-function (
  Str $name, @parameters, Hash $routine, Str $library, Str $sub-prefix
  --> Callable
) {
  my Str $routine-name = $sub-prefix ~ $name;

  # Create parameter list and start with inserting fixed arguments
  my @parameterList = ();

  given $routine<type> {
    when Constructor { }
    when Function { }
    #when Method { }
    default {
      @parameterList.push: Parameter.new(type => N-GObject);
    }
  }

  for @parameters -> $p {
    @parameterList.push: Parameter.new(type => $p);
  }

  # Create signature
  my $returns = $routine<returns>:exists ?? $routine<returns> !! void-ptr;
  my Signature $signature .= new( :params(|@parameterList), :$returns);

  # Get a pointer to the sub, then cast it to a sub with the proper
  # signature. after that, the sub can be called, returning a value.
  my Callable $f = nativecast(
    $signature, cglobal( $library, $routine-name, Pointer)
  );

  $f
}

#-------------------------------------------------------------------------------
method make-list-from-result (
  @native-args, @parameters, Hash $routine, $x
  --> List
) {
#note "$?LINE make-list-from-result: ", $routine.gist;
#note "$?LINE, ", @native-args.gist;
  my @return-list = ();
  @return-list.push: $x if $routine<returns>:exists;

  # Drop the first one when routine type is a Method
  my Int $start = 0;
  given $routine<type> {
    when Constructor { $start = 0; }
    when Function { $start = 0; }
    #when Method { $start = 1; }
    default { $start = 1; }
  }

#  @native-args.shift unless ?$routine<type> ~~ Function;
  loop ( my Int $i = 0; $i < @parameters.elems; $i++ ) {
    my $p = @parameters[$i];
    my $v = @native-args[$i + $start];
    next unless $p.^name ~~ m/ CArray /;
    @return-list.push: self.convert-return( $v, $p);
  }
#note "$?LINE result list: ", @return-list.gist;

  @return-list
}

#-------------------------------------------------------------------------------
method convert-args ( $v, $p ) {
  my $c;

  given $p {
    when gchar-pptr {
      $c = CArray[Str].new(|$v);
    }

    when gint-ptr {
      $c = CArray[gint].new;
    }

    when CArray[N-GError] {
      $c = CArray[N-GError].new(N-GError);
    }

    when GEnum {
      $c = $v.value;
    }

    when N-GObject {
      my N-GObject() $no = $v;
      $c = $no;
    }

    # Most values do not need conversion
    default {
      $c = $v;
    }
  }

  $c
}

#-------------------------------------------------------------------------------
method convert-return ( $v, $p ) {
  my $c;

#note "$?LINE return: ", $p.^name, ', ', $v.^name, ', ', $v.gist;

  # Use 'given' because $p is a type and is always undefined
  given $p {
    when gchar-pptr {
      my Int $i = 0;
      $c = [];
      while $v[$i].defined {
        $c.push: $v[$i++];
      }
    }

    when gint-ptr {
      $c = $v[0];
    }

    when CArray[N-GError] {
      $c = ?$v
         ?? Gnome::Glib::Error.new(:native-object($v[0]))
         !! Gnome::Glib::Error.new(:native-object(N-GError));
#note "$?LINE converted: ", $c.gist;
    }

    # Most values do not need conversion
    default {
      $c = $v;
    }
  }

  $c
}
}




=finish


  $!version = '3.0';
  $!module = 'Window';
  $!prefix = 'gtk_label_';

  # Get the repository. This is a global object for now.
  $!repository = g_irepository_get_default;


  my $e = CArray[N-GError].new(N-GError);
  my N-GObject $typelib = g_irepository_require(
    $!repository, $!name-space, $!version, 0, $e
  );

  unless $typelib {
    my Error() $error = $e[0];
    die $error.message;
  }

  $!library = g_irepository_get_shared_library( $!repository, $!name-space);

  $!object-info = g_irepository_find_by_name(
    $!repository, $!name-space, $!module
  );
  die "Module $!module not found" unless ?$!object-info;





note $?LINE;
  my N-GObject $function-info = g_object_info_find_method(
    $!object-info, $name
  );

  die "Method $name not found" unless ?$function-info;

  my UInt $flags = g_function_info_get_flags($function-info);

note "function: ",
       g_function_info_get_symbol($function-info),
       ", type $flags.fmt('0b%08b')";

  g_base_info_unref($function-info);



#-------------------------------------------------------------------------------
sub _gtk_window_new ( GEnum $type --> N-GObject )
  is native(&gtk-lib)
  is symbol('gtk_window_new')
  { * }
}