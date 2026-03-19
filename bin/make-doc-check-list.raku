use v6.d;

use YAMLish;

use Gnome::SourceSkimTool::Prepare;
use Gnome::SourceSkimTool::ConstEnumType;


my Str $gnome-package = @*ARGS[0];

my $*gnome-package = SkimSource(SkimSource.enums{$gnome-package});
my $*generate-code = False;
my $*generate-test = False;
my $*external-modules = %();
my $*verbose = False;
my @*map-search-list = ();
my $*gnome-class = '';
my $*work-data;

my Gnome::SourceSkimTool::Prepare $prepare .= new;
$*work-data<finit>( $*work-data, :label<work-data>);

for dir($*work-data<gir-module-path>).sort -> $file {
  next if $file.Str ~~ m/^ repo '-' /;
  next if $file.Str ~~ m/ \. gir $/;

  my Hash $data = load-yaml($file.slurp);
note "$?LINE $data.keys()";
}



























=finish

my Gnome::SourceSkimTool::Prepare $prepare .= new;
$*work-data<finit>( $*work-data, :label<work-data>);

my Str $check-list = Q:qq:to/EOFCL/;
  # Documentation checklist for $*work-data<raku-package>

  EOFCL

my Proc $p = shell "ls -c1 $*work-data<result-mods>", :out;
for $p.out.lines.sort -> $l {
  $check-list ~= "* [ ] $l\n";
}

$p.out.close;

"doc/Doc Check Lists/{$gnome-package.lc}.md".IO.spurt($check-list);




