# Command to generate: generate.raku -v -c -t Gio menumodel
use v6.d;

#-------------------------------------------------------------------------------
#--[Class Declaration]----------------------------------------------------------
#-------------------------------------------------------------------------------

unit class Gnome::Gio::T-Menumodel:auth<github:MARTIMM>:api<2>;

#-------------------------------------------------------------------------------
#--[Constants]------------------------------------------------------------------
#-------------------------------------------------------------------------------
constant G_MENU_ATTRIBUTE_TARGET is export = 'target';
constant G_MENU_LINK_SECTION is export = 'section';
constant G_MENU_ATTRIBUTE_ICON is export = 'icon';
constant G_MENU_LINK_SUBMENU is export = 'submenu';
constant G_MENU_ATTRIBUTE_LABEL is export = 'label';
constant G_MENU_ATTRIBUTE_ACTION is export = 'action';
constant G_MENU_ATTRIBUTE_ACTION_NAMESPACE is export = 'action-namespace';


