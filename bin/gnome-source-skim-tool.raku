#!/usr/bin/env rakudo

use Gnome::SourceSkimTool::GetFileList;
use Gnome::SourceSkimTool::ConstEnumType;

#-------------------------------------------------------------------------------
constant \GetFileList = Gnome::SourceSkimTool::GetFileList;

my Bool $*class-is-leaf;
my Bool $*class-is-role; # is leaf implicitly
my Bool $*class-is-top;

my SkimSource $*use-doc-source;

# $sub-prefix is the name of gnome class. Sometimes another class is defined
# within the same file. To generate that part, add the $other-prefix.
my Str $*sub-prefix;            # provided sub prefix is the name of gnome class
#my Str $*other-prefix;          # prefix found within same doc as above prefix
my Str $*lib-classname;         # gnome sub-prefix
my Str $*raku-classname;        # its Raku counterpart
my Str $*raku-parent-classname; # the Raku parent class
my Str $*library;               # native lib sub from Gnome::N
my Str $*raku-modname;          # Rake module
my Str $*raku-parent-modname    # Raku parent module
my Str $*include-content;       # C-include file contents
my Str $*source-content;        # C-code file contents
my Str $*dump-result-dir;       # directory where result is dumped

#my Str $source
my @source-dir-list = ();

#-------------------------------------------------------------------------------
sub MAIN (
  Str:D $sub-prefix,
# Str $other-prefix? is copy,
#  Bool :$main = False, Bool :$sig = False, Bool :$prop = False,
#  Bool :$sub = False, Bool :$types = False, Bool :$test = False,
  Bool :$leaf = False, Bool :$role = False, Bool :$top = False,
  Bool :$make-dir-list
) {
  # Gtk interfaces (roles) are always leaf classes but need to cast their
  # object types, so leaf get False if role is True.
  $*class-is-leaf = ($leaf and not $role);
  $*class-is-role = $role;
  $*class-is-top = $top;

  # Make a list of C source files if requested and load the list
  my GetFileList $gfl .= new;
  $gfl.generate-gtkdoc if $gtkdoc;
}












=finish

  $*sub-prefix = $sub-prefix;
#  $*other-prefix = $other-prefix // $sub-prefix;


  # Make a list of C source files if requested and load the list
  my GetFileList $gfl .= new;
  $gfl.make-dir-list if $make-dir-list;
  @source-dir-list = $gfl.load-dir-list;

  # Get the C-source content and set some dynamic variables
  $gfl.get-sources;
}

