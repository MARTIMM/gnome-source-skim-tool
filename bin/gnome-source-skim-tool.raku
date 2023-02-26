#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
constant \Prepare = Gnome::SourceSkimTool::Prepare:auth<github:MARTIMM>;

my Bool $*class-is-leaf;
my Bool $*class-is-role; # is leaf implicitly
my Bool $*class-is-top;

my SkimSource $*use-doc-source;

# $sub-prefix is the name of gnome class. Sometimes another class is defined
# within the same file. To generate that part, add the $other-prefix.
my Str $*sub-prefix;            # provided sub prefix is the name of gnome class
my Str $*library;               # native lib sub from Gnome::N

my Bool $*verbose;

#my Str $source
my @source-dir-list = ();

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $sub-prefix,
  Bool :$leaf = False, Bool :$role = False, Bool :$top = False,
  :$verbose = False
) {
  # Gtk interfaces (roles) are always leaf classes but need to cast their
  # object types, so leaf get False if role is True.
  $*class-is-leaf = ($leaf and not $role);
  $*class-is-role = $role;
  $*class-is-top = $top;
  
  $*verbose = $verbose;

  # Make a list of C source files if requested and load the list
  my Prepare $gfl .= new;
  $gfl.generate-gtkdoc if $gtkdoc;
}








=finish
