
use Gnome::SourceSkimTool::ConstEnumType;
use YAMLish;


my $fname = SKIMTOOLDATA ~ 'Gtk3/repo-object-map.yaml';
my Hash $h = load-yaml($fname.IO.slurp);

#note $h.gist;

my Hash $fc = %();
for $h.kv -> $k, $v {
  $fc{$v<source-filename>}{$v<gir-type>}{$k} = $v;
}

my Int $class-count;
my Int $class-count-max = 0;
my Str $classes = '';

for $fc.keys.sort -> $source-filename {
  say "\n$source-filename";
  
  $class-count = 0;
  for $fc{$source-filename}.keys.sort -> $gir-type {
    $class-count++ if $gir-type ~~ / class || interface /;
    say "  $gir-type";
    say "    ", $fc{$source-filename}{$gir-type}.keys.sort.join(', ');
  }
  $classes ~= " $source-filename" if $class-count > 1;
  $class-count-max = max( $class-count-max, $class-count);
}

say "Max classes or interfaces per source file: $class-count-max";
say "Classes: $classes";


