
use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
unit class Gnome::SourceSkimTool::GetFileList;

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

  # test for generated code dump directory 'xt/NewModules'
  $*dump-result-dir = 'xt/NewModules';
  mkdir( $*dump-result-dir, 0o766) unless 'xt/NewModules'.IO.e;
}

#-------------------------------------------------------------------------------
method set-source-dir ( --> Str ) {
  my $source-root = SKIMTOOLROOT ~ 'Gnome/';
  my $source-dir = '';

  with $*use-doc-source {
    when Gtk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gtk'; }
    when Gdk3 { $source-dir = [~] $source-root, 'gtk+-', VGtk3, '/gdk'; }
    when Gtk4 { $source-dir = [~] $source-root, 'gtk-', VGtk4, '/gtk'; }
    when Gdk4 { $source-dir = [~] $source-root, 'gtk-', VGtk4, '/gdk'; }
#    when  { $source-dir = [~] $source-root, '', , ''; }
  }

  $source-dir
}

#-------------------------------------------------------------------------------
method set-gtkdoc-dir ( --> Str ) {
  my $dir = '';

  with $*use-doc-source {
    when Gtk3 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gtk3'; }
    when Gdk3 { $dir= SKIMTOOLROOT ~ 'Gtkdoc/Gdk3'; }
    when Gtk4 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gtk4'; }
    when Gdk4 { $dir = SKIMTOOLROOT ~ 'Gtkdoc/Gdk4'; }
#    when  { $dir = SKIMTOOLROOT ~ 'Gtkdoc/'; }
  }

  mkdir $dir, 0o700 unless $dir.IO.e;

  $dir
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
  shell "/usr/bin/gtkdoc-scan $out1 $src $mod";

  # The next step is using gtkdoc-scangobj which wil generate a program. There
  # are however errors when looking at the gtk3 sources. We need to filter
  # the types list to get rid of those
  with $*use-doc-source {
    when Gtk3 {
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
    when Gtk3 {
      $other-lib = '-lgtk-3';
    }
  }

  my Str $cf = '-fPIC';
  my Str $lf = '-Wl,--no-undefined -Wl,-z,relro -Wl,--as-needed -Wl,-z,now';

  shell "/usr/bin/gtkdoc-scangobj $mod --verbose --cflags '$cf -I$glib -I$gobject -I$glib0 -I$gbuild/glib -I$gbuild' --ldflags '$lf -L$gbuild/gobject -L$gbuild/glib -L/usr/lib64 -lgobject-2.0 -lglib-2.0 $other-lib'";

  my Str $out2 = "--output-dir $gd/docs";
  shell "/usr/bin/gtkdoc-mkdb $out2 $src $mod --xml-mode";
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

#-------------------------------------------------------------------------------
method make-dir-list ( ) {
  my $source-dir = self.set-source-dir;
  my $sl-name = self.set-source-list-name;

  # get a sorted list of c code filenames from the source directory
  my Str $list-text = '';
  for (dir $source-dir).sort -> $f is copy {
    next unless $f.Str ~~ / \. c $/;
    $f .= basename;
    $f ~~ s/ \. c $//;
    $list-text ~= "$f\n";
  }

  # test for the programs config directory and write the list of names
  mkdir (SKIMTOOLROOT ~ 'Lists'), 0o700 unless (SKIMTOOLROOT ~ 'Lists').IO.e;
  ( [~] SKIMTOOLROOT, 'Lists/', $sl-name).IO.spurt($list-text);

  # test for dir 'xt/NewModules'
  $*dump-result-dir = 'xt/NewModules';
  mkdir( $*dump-result-dir, 0o766) unless 'xt/NewModules'.IO.e;
}

#-------------------------------------------------------------------------------
# load the list of source filenames
method load-dir-list ( --> List ) {
  my $source-dir = self.set-source-dir;
  my $sl-name = self.set-source-list-name;
  
  ( [~] SKIMTOOLROOT, 'Lists/', $sl-name).IO.slurp.lines.List;
}

#-------------------------------------------------------------------------------
method get-sources ( ) {
  my Str $src-fname = $*sub-prefix;

  with $*use-doc-source {
    when Pango { $src-fname ~~ s:g/ '_' /-/; }
    default { $src-fname ~~ s:g/ '_' //; }
  }

  my @parts = $*other-prefix.split(/<[_-]>/);
  $*lib-classname = @parts>>.tc.join;
  $*raku-classname = @parts[1..*-1]>>.tc.join;

  my $source-dir = self.set-source-dir;
#  my $source-root = SKIMTOOLROOT ~ 'Gnome/';

  $*include-content = "$source-dir/$src-fname.h".IO.slurp;
  $*source-content = "$source-dir/$src-fname.c".IO.slurp
    if "$source-dir/$src-fname.c".IO.r;

  with $*use-doc-source {
    when Gtk3 { $*library = '&gtk-lib'; $*raku-modname = 'Gtk3'; }
    when Gdk3 { $*library = '&gdk-lib'; $*raku-modname = 'Gdk3'; }
    when Gtk4 { $*library = '&gtk4-lib'; $*raku-modname = 'Gtk4'; }
    when Gdk4 { $*library = '&gdk4-lib'; $*raku-modname = 'Gtk4'; }
#    when  { $source-dir = [~] $source-root, '', , ''; }
  }
}

