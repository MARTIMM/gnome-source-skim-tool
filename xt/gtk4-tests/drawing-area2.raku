use v6.d;

use Cairo;

use Gnome::Glib::N-MainLoop:api<2>;

use Gnome::Gtk4::DrawingArea:api<2>;
use Gnome::Gtk4::Window:api<2>;

use Gnome::N::GlibToRakuTypes:api<2>;
use Gnome::N::N-Object:api<2>;

#-------------------------------------------------------------------------------
constant Window = Gnome::Gtk4::Window;
constant DrawingArea = Gnome::Gtk4::DrawingArea;



my Cairo::cairo_surface_t $surface;

sub clear-surface ( ) {
  my Cairo::cairo_t $cr .= 
}
=finish
static cairo_surface_t *surface = NULL;

static void
clear_surface (void)
{
    cairo_t *cr;
    
    cr = cairo_create(surface);
    cairo_set_source_rgb(cr, 1, 1, 1); // White
    cairo_paint(cr);
    cairo_destroy(cr);
}

static void
resize_cb (GtkWidget *widget,
          int        width,
          int        height,
          gpointer   data)
{
    if (surface)
        cairo_surface_destroy(surface);
    
    surface = gdk_surface_create_similar_surface(gtk_widget_get_native(widget)->surface,
                                                CAIRO_CONTENT_COLOR,
                                                width, height);
    
    clear_surface();
}

static gboolean
draw_callback (GtkDrawingArea *area,
              cairo_t         *cr,
              int               width,
              int               height,
              gpointer          user_data)
{
    cairo_set_source_surface(cr, surface, 0, 0);
    cairo_paint(cr);
    return FALSE;
}

static void
draw_brush (GtkWidget *widget,
            double     x,
            double     y)
{
    cairo_t *cr;
    
    cr = cairo_create(surface);
    cairo_rectangle(cr, x - 3, y - 3, 6, 6);
    cairo_fill(cr);
    cairo_destroy(cr);
    
    gtk_widget_queue_draw(widget);
}

static void
drag_begin (GtkGestureDrag *gesture,
             double          x,
             double          y,
             GtkWidget      *area)
{
    draw_brush(area, x, y);
}

static void
drag_update (GtkGestureDrag *gesture,
             double          x,
             double          y,
             GtkWidget      *area)
{
    draw_brush(area, x, y);
}

int main(int argc, char *argv[])
{
    GtkApplication *app;
    GtkWidget *window, *drawing_area;

    app = gtk_application_new("org.example.DrawingApp", G_APPLICATION_DEFAULT_FLAGS);
    g_signal_connect(app, "activate", G_CALLBACK(lambda_main), NULL);

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "Cairo Drawing");

    drawing_area = gtk_drawing_area_new();

    g_signal_connect(drawing_area, "draw", G_CALLBACK(draw_callback), NULL);
    g_signal_connect(drawing_area, "resize", G_CALLBACK(resize_cb), NULL);

    gtk_container_add(GTK_CONTAINER(window), drawing_area);

    gtk_widget_show_all(window);

    g_application_run(G_APPLICATION(app), argc, argv);
}

void lambda_main(GtkApplication *app, gpointer user_data)
{
    // Implementation of lambda_main...
}
