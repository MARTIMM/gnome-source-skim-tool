
use NativeCall;

use Gnome::N::N-GObject;
use Gnome::N::NativeLib;
use Gnome::N::GlibToRakuTypes;
#use Gnome::N::Gir;

use Gnome::Gtk3::Bin;

use Gnome::Glib::Error;

#-------------------------------------------------------------------------------
unit class Gnome::Gtk3::Window:api('gir');
also is Gnome::Gtk3::Bin;

constant \Error = Gnome::Glib::Error;

my Bool $signals-added = False;

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
constant \gtk3-lib = 'libgtk-3.so.0';
constant \Prefix = 'gtk_window_';

# this hash is build using the gir repo
my Hash $methods = %(
  new => %(               # We know to prefix 'gtk_window_' in this module
    :constructor,         # True if constructor and will return an object
                          # when False, first argument must be this object
                          # rest of the arguments is in the list below
    :returns(N-GObject),  # Return type, Type is Mu if no return.(void)
    parameters => [
      GEnum,              # Parameter types
    ],
  ),

  set_keep_above => %(
    :!constructor, :returns(Pointer),
    parameters => [gboolean]
  ),

  set_title => %(
    :!constructor, :returns(Pointer),
    parameters => [gchar-ptr]
  ),
);

#-------------------------------------------------------------------------------
submethod BUILD ( *@arguments, *%options ) {
  $signals-added = self.add-signal-types( $?CLASS.^name,
    :w0<activate-default activate-focus keys-changed>,
    :w1<enable-debugging set-focus>,
  ) unless $signals-added;

  # prevent creating wrong native-objects
  if self.^name eq 'Gnome::Gtk3::Window' or %options<GtkWindow> {

    if self.is-valid { }

    # check if common options are handled by some parent
    elsif %options<native-object>:exists { }
    elsif %options<build-id>:exists { }

    # process all other options
    else {
      my $no;
      if ? %options<window-type> {
        $no = self.FALLBACK( 'new', %options<window-type>);
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
        $no = self.FALLBACK( 'new', GTK_WINDOW_TOPLEVEL);
      }
      #}}

      self._set-native-object($no);
    }

    # only after creating the native-object, the gtype is known
    self._set-class-info('GtkWindow');
  }

#`{{  $!name-space = 'Gtk';
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
}}
}

#-------------------------------------------------------------------------------
method FALLBACK ( Str $name is copy, *@arguments ) {

  # Dashes to underscores
  $name ~~ s:g/ '-' /_/;
  die "Method $name not found" unless $methods{$name}:exists;

  my Hash $method := $methods{$name};
  if !$method<function> {
    $name = Prefix ~ $name;
    die "Number of arguments not sufficient"
      unless @arguments.elems >= abs($method<parameters>.elems);

    # Create parameter list and start with inserting fixed arguments
    my @parameterList = ();
    @parameterList.push: Parameter.new(type => N-GObject)
      unless $method<constructor>;

    for @($method<parameters>) -> $p {
      #TODO check type against argument
      @parameterList.push: Parameter.new(type => $p);
    }

    # Create signature
    my Signature $signature .= new(
      :params(|@parameterList), :returns($method<returns>)
    );

    # Get a pointer to the sub, then cast it to a sub with the proper
    # signature. after that, the sub can be called, returning a value.
    state $ptr = cglobal( gtk-lib, $name, Pointer);
    my Callable $f = nativecast( $signature, $ptr);
    $method<function> = $f;
  }

  # Call routine
  @arguments.prepend(self._f('GtkWindow')) unless $method<constructor>;
  my $x = $method<function>(|@arguments);

  $x
}

#`{{
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
}}



=finish


#-------------------------------------------------------------------------------
sub _gtk_window_new ( GEnum $type --> N-GObject )
  is native(&gtk-lib)
  is symbol('gtk_window_new')
  { * }
}