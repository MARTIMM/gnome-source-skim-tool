
use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::Prepare:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
submethod BUILD ( Str :$test-cwd ) {

  # $test-cwd may be significant part of path
  with $test-cwd // $*CWD {
    when / 'gnome-gtk3' / {
      $*use-doc-source = Gtk3;
      $*library = '&gtk-lib';
#      $*raku-modname = 'Gtk3';
    }
    
    when / 'gnome-gdk3' / {
      $*use-doc-source = Gdk3;
      $*library = '&gdk-lib';
#      $*raku-modname = 'Gdk3';
    }
    
    when / 'gnome-gtk4' / {
      $*use-doc-source = Gtk4;
      $*library = '&gtk4-lib';
#      $*raku-modname = 'Gtk4';
    }
    
    when / 'gnome-gdk4' / {
      $*use-doc-source = Gdk4;
      $*library = '&gdk4-lib';
 #     $*raku-modname = 'Gtk4';
    }
    
    when / 'gnome-glib' / {
      $*use-doc-source = Glib;
    }
    
    when / 'gnome-gio' / {
      $*use-doc-source = Gio;
    }
    
    when / 'gnome-gobject' / {
      $*use-doc-source = GObject;
    }
    
    when / 'gnome-cairo' / {
      $*use-doc-source = Cairo;
    }
    
    when / 'gnome-pango' / {
      $*use-doc-source = Pango;
    }

    default {
      die 'Use :$test-cwd to specify gnome source for testing';
    }
  }
}

#-------------------------------------------------------------------------------
method set-source-dir ( --> Str ) {
  my Str $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my Str $source-dir = '';

  with $*use-doc-source {
    when Gtk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gtk'; }
    when Gdk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gdk'; }
    when Gtk4 { $source-dir = [~] $source-root, 'gtk-', VGtk4, '/gtk'; }
    when Gdk4 { $source-dir = [~] $source-root, 'gtk-', VGtk4, '/gdk'; }
    when Glib { $source-dir = [~] $source-root, 'glib', VGlib, 'glib'; }
    when Gio { $source-dir = [~] $source-root, 'glib', VGlib, 'gio'; }
    when GObject { $source-dir = [~] $source-root, 'glib', VGlib, 'gobject'; }
    when Cairo { $source-dir = [~] $source-root, 'cairo', VCairo, 'src'; }
    when Pango { $source-dir = [~] $source-root, 'pango', VPango, 'pango'; }
    #when  { $source-dir = [~] $source-root, '', , ''; }
  }

  if $*verbose {
    note "Config root: ", SKIMTOOLROOT;
    note "Source directory: $source-dir";
  }

  $source-dir
}

#-------------------------------------------------------------------------------
method set-gtkdoc-dir ( --> Str ) {
  my Str $dir = '';

  with $*use-doc-source {
    when Gtk3 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gtk3'; }
    when Gdk3 { $dir= SKIMTOOLROOT ~ 'Gtkdoc/Gdk3'; }
    when Gtk4 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gtk4'; }
    when Gdk4 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gdk4'; }
    when Glib { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Glib'; }
    when Gio { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gio'; }
    when GObject { $dir = SKIMTOOLROOT ~ 'Gtkdoc/GObject'; }
    when Cairo { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Cairo'; }
    when Pango { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Pango'; }
    #when  { $dir = SKIMTOOLROOT ~ 'Gtkdoc/'; }
  }

  mkdir $dir, 0o700 unless $dir.IO.e;

  note "Gtk doc directory: $dir" if $*verbose;

  $dir
}

#-------------------------------------------------------------------------------
method get-gtkdoc-file ( Str $postfix, Bool :$txt = True --> Str ) {
  my Str $gtkdoc-fname = '';

  with $*use-doc-source {
    when Gtk3 {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gtk3/gtk3$postfix";
    }
    when Gdk3 {
      $gtkdoc-fname= SKIMTOOLROOT ~ "Gtkdoc/Gdk3/gdk3$postfix";
    }
    when Gtk4 {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gtk4/gtk4$postfix";
    }
    when Gdk4 {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gdk4/gdk4$postfix";
    }
    when Glib {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Glib/glib$postfix";
    }
    when Gio {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Gio/gio$postfix";
    }
    when GObject {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/GObject/gobject$postfix";
    }
    when Cairo {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Cairo/cairo$postfix";
    }
    when Pango {
      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/Pango/pango$postfix";
    }
#    when  {
#      $gtkdoc-fname = SKIMTOOLROOT ~ "Gtkdoc/…/…$postfix";
#    }
  }

  $gtkdoc-fname ~= '.txt' if $txt;

  note "Gtk doc file: $gtkdoc-fname" if $*verbose;

  $gtkdoc-fname
}

#-------------------------------------------------------------------------------
method set-skim-result-file ( --> Str ) {
  my Str $dir = '';
  my Str $file = $*sub-prefix;
  $file .= tc;
  $file ~~ s:g/ '_' (\w) /$0.tc()/;

  with $*use-doc-source {
    when Gtk3 { $dir = SKIMTOOLDATA ~ 'Gtk3/'; }
    when Gdk3 { $dir= SKIMTOOLDATA ~ 'Gdk3/'; }
    when Gtk4 { $dir = SKIMTOOLDATA ~ 'Gtk4/'; }
    when Gdk4 { $dir = SKIMTOOLDATA ~ 'Gdk4/'; }
    when Glib { $dir = SKIMTOOLDATA ~ 'Glib/'; }
    when Gio { $dir = SKIMTOOLDATA ~ 'Gio/'; }
    when GObject { $dir = SKIMTOOLDATA ~ 'GObject/'; }
    when Cairo { $dir = SKIMTOOLDATA ~ 'Cairo/'; }
    when Pango { $dir = SKIMTOOLDATA ~ 'Pango/'; }
#    when  { $dir = SKIMTOOLDATA ~ ''; }
  }

  mkdir $dir, 0o700 unless $dir.IO.e;

  note "Skim result file: $dir$file.yaml" if $*verbose;

  "$dir$file.yaml"
}

#-------------------------------------------------------------------------------
method generate-gtkdoc ( ) {

  my Str $gd = self.set-gtkdoc-dir;
  my Str $mod-name = $*use-doc-source.key.lc;

  my $curr-dir = $*CWD;
  chdir $gd;

  # Generate a few files using gtkdoc-scan. See also gtkdoc.md.
  my Str $out1 = "--output-dir .";
  my Str $src = '--source-dir ' ~ self.set-source-dir;
  my Str $mod = "--module $mod-name";
  note "Run: /usr/bin/gtkdoc-scan $out1 $src $mod" if $*verbose;
  shell "/usr/bin/gtkdoc-scan $out1 $src $mod";

  # The next step is using gtkdoc-scangobj which wil generate a program. There
  # are however errors when looking at the gtk3 sources. We need to filter
  # the types list to get rid of those
  with $*use-doc-source {
    when Gtk3 {
      note "Filter types from $gd/{$mod-name}.types" if $*verbose;
      my @list = ();
      # read the types list
      for "$gd/{$mod-name}.types".IO.slurp.lines -> $l {
        # Filter out following functions from types list.
        next if $l ~~ any(<
          gtk_action_muxer_get_type
          gtk_action_helper_get_type
          gtk_action_observable_get_type
          gtk_action_observer_get_type
          gtk_application_accels_get_type
          gtk_application_impl_dbus_get_type
          gtk_application_impl_get_type
          gtk_application_impl_quartz_get_type
          gtk_application_impl_wayland_get_type
          gtk_application_impl_x11_get_type
          gtk_box_gadget_get_type
          gtk_builtin_icon_get_type
          gtk_color_editor_get_type
          gtk_color_picker_kwin_get_type
          gtk_color_picker_portal_get_type
          gtk_color_picker_shell_get_type
          gtk_color_plane_get_type
          gtk_color_scale_get_type
          gtk_color_swatch_get_type
          gtk_css_animated_style_get_type
          gtk_css_custom_gadget_get_type
          gtk_css_gadget_get_type
          gtk_css_image_builtin_get_type
          gtk_css_node_get_type
          gtk_css_path_node_get_type
          gtk_css_static_style_get_type
          gtk_css_style_get_type
          gtk_css_transient_node_get_type
          gtk_css_widget_node_get_type
          gtk_emoji_chooser_get_type
          gtk_emoji_completion_get_type
          gtk_graph_data_get_type
          gtk_icon_get_type
          gtk_icon_helper_get_type
          gtk_inspector_action_editor_get_type
          gtk_inspector_actions_get_type
          gtk_inspector_css_editor_get_type
          gtk_inspector_css_node_tree_get_type
          gtk_inspector_data_list_get_type
          gtk_inspector_general_get_type
          gtk_inspector_gestures_get_type
          gtk_inspector_magnifier_get_type
          gtk_inspector_menu_get_type
          gtk_inspector_misc_info_get_type
          gtk_inspector_object_hierarchy_get_type
          gtk_inspector_object_tree_get_type
          gtk_inspector_prop_editor_get_type
          gtk_inspector_prop_list_get_type
          gtk_inspector_resource_list_get_type
          gtk_inspector_selector_get_type
          gtk_inspector_signals_list_get_type
          gtk_inspector_size_groups_get_type
          gtk_inspector_statistics_get_type
          gtk_inspector_strv_editor_get_type
          gtk_inspector_visual_get_type
          gtk_inspector_window_get_type
          gtk_menu_section_box_get_type
          gtk_menu_tracker_item_get_type
          gtk_menu_tracker_item_role_get_type
          gtk_model_menu_item_get_type
          gtk_places_view_get_type
          gtk_places_view_row_get_type
          gtk_query_get_type
          gtk_search_engine_tracker3_get_type
          gtk_search_engine_tracker3_get_type
          gtk_sidebar_row_get_type
          gtk_stack_combo_get_type
          gtk_tooltip_window_get_type
          gtk_tree_model_css_node_get_type
          gtk_win32_embed_widget_get_type
        >);

        @list.push: $l;
      }

      # Write filtered list
      "$gd/{$mod-name}.types".IO.spurt(@list.join("\n"));
    }
  }

  my $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my $glib0 = [~] $source-root, 'glib-', VGlib;
  my $gbuild = [~] $glib0, '/build';
  my $glib = [~] $glib0, '/glib';
  my $gobject = [~] $glib0, '/gobject';

  my $other-lib = '';
  with $*use-doc-source {
    when Gtk3 { $other-lib = '-lgtk-3'; }
    when Gdk3 { $other-lib = '-lgdk-3'; }
    when Gtk4 { $other-lib = '-lgtk-4'; }
    #when Gdk4 { $other-lib = ''; }

    when Cairo { $other-lib = '-lcairo'; }
    when Pango { $other-lib = '-lpango'; }
  }

  my Str $cf = '-fPIC';
  my Str $lf = ''; #'-Wl,--no-undefined -Wl,-z,relro -Wl,--as-needed -Wl,-z,now';

  note "Run: /usr/bin/gtkdoc-scangobj … " if $*verbose;
  shell "/usr/bin/gtkdoc-scangobj $mod --verbose --cflags '$cf -I$glib -I$gobject -I$glib0 -I$gbuild/glib -I$gbuild' --ldflags '$lf -L$gbuild/gobject -L$gbuild/glib -L/usr/lib64 -lgobject-2.0 -lglib-2.0 $other-lib' >compile1.log";

  my Str $out2 = "--output-dir $gd/docs";
  note "Run: /usr/bin/gtkdoc-mkdb $out2 $src $mod --xml-mode" if $*verbose;
  shell "/usr/bin/gtkdoc-mkdb $out2 $src $mod --xml-mode >compile2.log";
  chdir $curr-dir;
}








=finish
sources from https://www.gtk.org/docs/installations/linux/

Make gtk and gdk libs
> ./configure
> make


Make glib, gio and gobject libs
Beyond Linux® From Scratch;
https://www.linuxfromscratch.org/blfs/view/svn/general/glib2.html

download glib-2.74.5.tar.xz and glib-2.74.5-skip_warnings-1.patch

> tar xvf glib-2.74.5.tar.xz
> cd glib-2.74.5
> patch -Np1 -i ../glib-2.74.5-skip_warnings-1.patch
> mkdir build
> cd build
> meson --prefix=/usr --buildtype=release -Dman=true ..
> ninja
> setenv LC_ALL C
> ninja test




make docs with GtkDoc tools
in Gnome source code at /home/marcel/Software/Packages/Sources/Gnome do
following command to get glibconfig.h
> autoconf --output=glib/glibconfig.h glib/glibconfig.h.in

V3
in GtkDoc/Gtk3
> gtkdoc-scan --module gtk3 --output-dir . --source-dir ../../Gnome/gtk+-3.24.24/gtk
> gtkdoc-scangobj --module gtk3 --verbose --cflags '\-fPIC -I../../Gnome/glib-2.74.5/glib -I../../Gnome/glib-2.74.5/gobject -I../../Gnome/glib-2.74.5 -I../../Gnome/glib-2.74.5/build/glib -I../../Gnome/glib-2.74.5/build/' --ldflags '\-Wl,--no-undefined -Wl,-z,relro -Wl,--as-needed -Wl,-z,now -L../../Gnome/glib-2.74.5/build/gobject -L../../Gnome/glib-2.74.5/build/glib -L/usr/lib64 -lgobject-2.0 -lglib-2.0 -lgtk-3 -lgobject-2.0 -lglib-2.0 -lgtk-3'

not found refs

gtk_action_muxer_get_type
gtk_action_observable_get_type
gtk_action_observer_get_type
gtk_application_accels_get_type
gtk_application_impl_dbus_get_type
gtk_application_impl_get_type
gtk_application_impl_quartz_get_type
gtk_application_impl_wayland_get_type
gtk_application_impl_x11_get_type
gtk_box_gadget_get_type
gtk_builtin_icon_get_type
gtk_color_editor_get_type
gtk_color_picker_kwin_get_type
gtk_color_picker_portal_get_type
gtk_color_picker_shell_get_type
gtk_color_plane_get_type
gtk_color_scale_get_type
gtk_color_swatch_get_type
gtk_css_animated_style_get_type
gtk_css_custom_gadget_get_type
gtk_css_gadget_get_type
gtk_css_image_builtin_get_type
gtk_css_node_get_type
gtk_css_path_node_get_type
gtk_css_static_style_get_type
gtk_css_style_get_type
gtk_css_transient_node_get_type
gtk_css_widget_node_get_type
gtk_emoji_chooser_get_type
gtk_emoji_completion_get_type
gtk_graph_data_get_type
gtk_icon_get_type
gtk_icon_helper_get_type
gtk_inspector_action_editor_get_type
gtk_inspector_actions_get_type
gtk_inspector_css_editor_get_type
gtk_inspector_css_node_tree_get_type
gtk_inspector_data_list_get_type
gtk_inspector_general_get_type
gtk_inspector_gestures_get_type
gtk_inspector_magnifier_get_type
gtk_inspector_menu_get_type
gtk_inspector_misc_info_get_type
gtk_inspector_object_hierarchy_get_type
gtk_inspector_object_tree_get_type
gtk_inspector_prop_editor_get_type
gtk_inspector_prop_list_get_type
gtk_inspector_resource_list_get_type
gtk_inspector_selector_get_type
gtk_inspector_signals_list_get_type
gtk_inspector_size_groups_get_type
gtk_inspector_statistics_get_type
gtk_inspector_strv_editor_get_type
gtk_inspector_visual_get_type
gtk_inspector_window_get_type
gtk_menu_section_box_get_type
gtk_menu_tracker_item_get_type
gtk_menu_tracker_item_role_get_type
gtk_model_menu_item_get_type
gtk_places_view_get_type
gtk_places_view_row_get_type
gtk_query_get_type
gtk_search_engine_tracker3_get_type
gtk_search_engine_tracker3_get_type
gtk_sidebar_row_get_type
gtk_stack_combo_get_type
gtk_tooltip_window_get_type
gtk_tree_model_css_node_get_type
gtk_win32_embed_widget_get_type


> gtkdoc-mkdb --module gtk3 --source-dir ../../Gnome/gtk+-3.24.24/gtk --output-dir docs --xml-mode

V4
> gtkdoc-scan --output-dir d --source-dir Gnome/gtk-4.9.3/gtk --module gtk4
> gtkdoc-scangobj --module gtk4 --verbose --cflags '\-I../../Gnome/glib-2.74.5/glib -I../../Gnome/glib-2.74.5/gobject'
> gtkdoc-mkdb --module gtk3 --source-dir ../Gnome/gtk+-3.24.24/gtk --output-dir e --xml-mode
