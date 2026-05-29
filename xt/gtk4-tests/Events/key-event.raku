#!/usr/bin/env raku

use v6.d;

use Gnome::Glib::N-MainLoop:api<2>;
use Gnome::Gtk4::Window:api<2>;
use Gnome::Gtk4::EventControllerKey:api<2>;

use Gnome::Gdk4::T-enums:api<2>;

constant Window = Gnome::Gtk4::Window;
constant EventControllerKey = Gnome::Gtk4::EventControllerKey;

#-------------------------------------------------------------------------------
class Helper {
  method key-pressed (
    UInt() $keyval, UInt $keycode, GdkModifierType $state
  ) {
    note "$keyval, $keycode, $state";
  }

  method key-released (
    UInt() $keyval, UInt $keycode, GdkModifierType $state
  ) {
    note "$keyval, $keycode, $state";
  }
}

my Helper $helper .= new;

#-------------------------------------------------------------------------------
with my EventControllerKey $eck = new-eventcontrollerkey {
  .register-signal( $helper, 'key-pressed', 'key-pressed');
  .register-signal( $helper, 'key-released', 'key-released');
}

with my Window $window .= new-window {
  .set-title('mouse button event test');
  .set-child($frame);
  .set-default-size( 200, 200);

  .add-controller($eck);

  .present;
}

$main-loop.run;
say 'done it';









=finish

#-------------------------------------------------------------------------------
#include <gtk/gtk.h>

static void
on_key_pressed (GtkEventControllerKey *controller,
                guint                  keyval,
                guint                  keycode,
                GdkModifierType        state,
                GtkWidget             *widget)
{
  // Handle key press
  if (keyval == GDK_KEY_Escape)
    gtk_window_close (GTK_WINDOW (widget));
}

static void
on_key_released (GtkEventControllerKey *controller,
                 guint                  keyval,
                 guint                  keycode,
                 GdkModifierType        state,
                 GtkWidget             *widget)
{
  // Handle key release
}

static void
activate (GtkApplication *app,
          gpointer        user_data)
{
  GtkWidget *window;
  GtkEventControllerKey *controller;

  window = gtk_application_window_new (app);
  gtk_window_set_title (GTK_WINDOW (window), "Keyboard Events");
  gtk_window_set_default_size (GTK_WINDOW (window), 200, 200);

  // Create and configure the event controller
  controller = gtk_event_controller_key_new ();
  g_signal_connect (controller, "key-pressed",
                    G_CALLBACK (on_key_pressed), window);
  g_signal_connect (controller, "key-released",
                    G_CALLBACK (on_key_released), window);

  // Attach controller to the window
  gtk_widget_add_controller (window, GTK_EVENT_CONTROLLER (controller));

  gtk_window_present (GTK_WINDOW (window));
}

int
main (int    argc,
      char **argv)
{
  GtkApplication *app;
  int status;

  app = gtk_application_new ("org.example.keyboard", G_APPLICATION_NONE);
  g_signal_connect (app, "activate", G_CALLBACK (activate), NULL);
  status = g_application_run (G_APPLICATION (app), argc, argv);
  g_object_unref (app);

  return status;
}




#-------------------------------------------------------------------------------
GdkEvent *event = gtk_event_controller_get_current_event (GTK_EVENT_CONTROLLER (gesture));
GdkModifierType state = gdk_event_get_modifier_state (event