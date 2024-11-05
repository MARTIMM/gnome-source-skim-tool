![Gtk+ Raku logo][logo]


# Gnome::Gtk4:api<2> - Raku interface to the GTK toolkit
![L][license-svg]

# Description

This package holds the native object description as well as the interface description to connect to the Gnome libraries. This set of modules will never act on their own. They will be used by other packages such as `Gnome::Gtk4` and the like.

## Example

An example of a window showing two buttons is shown below. Its origin comes from the package **GTK::Simple** of Richard Hainsworth.

 Some important things to note;
* It is important to add the `:api<2>` part to the module in the _use_ statement to be sure you get the proper module. This is neccesary to prevent clashes with the older **Gnome::Gtk3** series of modules when you have installed them or when your application gets installed on some other machine. However, this set of repos only holds **Gnome::Gtk4** but the repos it depends on have the same names as before like **Gnome::Glib**, **Gnome::Gio** and **Gnome::GObject**. Those classes are all redone with the :api<2> tag. And, dunno, maybe the gtk3 gets added in the future.
 &nbsp;
* The instanciation of the classes in the `Gnome::*` `:api<2>` packages is changed compared to the `:api<1>` version. There is no `new()` (for most classes).
 &nbsp;
  The decision is made to follow the interface of the gnome libraries more strictly. Because of that, it is easier to look into examples written in C and translate it into Raku.
 &nbsp;  
  The Raku new method only accepts named arguments, except when you tinker a bit with it, which I didn't want to do.
 &nbsp;
  E.g. the GtkWindow class has a `gtk_window_new()`. So it became `new-window()` and returns an instanciated object. Other examples like this are `new-label()` and `new-grid()`, with or without parameters. Other new functions are longer, e.g. Label has also `gtk_label_new_with_mnemonic()` which becomes `new-with-mnemonic()`.
 &nbsp;
* As with the :api<1> version, this version makes use of native types as used in the gnome libraries. An example of this is `gboolean` type which is mapped to some Raku native type in the **Gnome::N::GlibToRakuTypes** module.

### Initialization
Loading the modules needed for the application.

```
use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::Gtk4::Button:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::Grid:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;

# Convenience shortened class names
constant Window = Gnome::Gtk4::Window;
constant Button = Gnome::Gtk4::Button;
constant Grid = Gnome::Gtk4::Grid;

my Gnome::Glib::N-MainLoop $main-loop .= new-mainloop( N-Object, True);
```

### Helper class to handle the events from the buttons

The first method `stopit()` is used to stop the application, triggered by a button on the decoration of the application. The second method `b1-press()` is called when the top button is pressed. After showing a message it will make the second button responsive and the top button is made insensitive. The third method `b2-press()` will also stop the program.

```
class SH {
  method stopit ( --> gboolean ) {
    say 'close request';
    $main-loop.quit;

    0
  }

  method b1-press ( Button() :_native-object($button1), Button :$button2 ) {
    say 'button1 pressed';
    $button2.set-sensitive(True);
    $button1.set-sensitive(False);
  }

  method b2-press ( ) {
    say 'button2 pressed';
    $main-loop.quit;
  }
}

# Instanciate the helper object
my SH $sh .= new;
```

### Building the GUI

First the two buttons are created. Registration of the signal is using the methods in the **SH** class. The first three parameters are obliged and the named arguments are optional. 
```
with my Button $button2 .= new-with-label('Goodbye') {
  .register-signal( $sh, 'b2-press', 'clicked');
  .set-sensitive(False);
}

with my Button $button1 .= new-with-label('Hello World') {
  .register-signal( $sh, 'b1-press', 'clicked', :$button2);
}
```

Next, the buttons are placed in a grid. The grid gets a wide empty area around the buttons.
```
with my Grid $grid .= new-grid {
  .set-margin-top(30);
  .set-margin-bottom(30);
  .set-margin-start(30);
  .set-margin-end(30);

  .attach( $button1, 0, 0, 1, 1);
  .attach( $button2, 0, 1, 1, 1);
}
```

Finally the grid is placed in a window. It gets a title in the decoration of the window and the button action in the decoration to stop the application will be processed by `stopit()`.
```
with my Window $window .= new-window {
  .register-signal( $sh, 'stopit', 'close-request');
  .set-title('Hello GTK!');
  .set-child($grid);
  .show;
}
```

### Starting the application

To get everything visible and responsive we need to start the event loop. The call to `$main-loop.quit();` in two of the methods in the **SH** class will cause the program to return from this call.
```
$main-loop.run;
```

# Documentation
* [ 🔗 Website](https://martimm.github.io/)
* [ 🔗 License document][licence-lnk]
* [ 🔗 Release notes][changes]
* [ 🔗 Issues][issues]

# Installation
Use the following command to install `Gnome::Gtk4:api<2>` and all its dependencies.
```
zef install Gnome::Gtk4:api<2>
```

# Author

Name: **Marcel Timmerman**
Github account name: **MARTIMM**


# Issues

There are always some problems! If you find one please help by filing an issue at [my github project root][issues].

# Attribution

* The inventors of Raku, formerly known as Perl 6, of course and the writers of the documentation which helped me out every time again and again.
* The builders of all the Gnome libraries and the documentation.
* Other helpful modules for their insight and use.

[//]: # (---- [refs] ----------------------------------------------------------)
[changes]: https://github.com/MARTIMM/gnome-native/blob/master/CHANGES.md
[logo]: https://martimm.github.io/gnome-gtk3/content-docs/images/gtk-raku.png
[issues]: https://github.com/MARTIMM/gnome-source-skim-tool/issues

[license-svg]: http://martimm.github.io/label/License-label.svg
[licence-lnk]: http://www.perlfoundation.org/artistic_license_2_0
