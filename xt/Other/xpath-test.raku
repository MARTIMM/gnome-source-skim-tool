use XML;
use XML::XPath;

my Str $file = '/usr/share/gir-1.0/Gtk-3.0.gir';

my XML::XPath $xp .= new(:$file);
#my @r = ($xp.find( '//class[@name="Label"]/doc', :to-list));
#note @r[0].Str;

my @r = ($xp.find( '//namespace/*', :to-list));
for @r -> $rs2 {
  my $attrs = $rs2.attribs;
  my $name = $attrs<name> // '-';
  my $cid = $attrs<c:identifier> // '-';
  note "$rs2.name(): $name, $cid";
}


#`{{
$file = '/home/marcel/.config/io.github.martimm.source-skim-tool/Gtkdoc/Gtk3/docs/gtklabel.xml';

$xp .= new(:$file);
@r = ($xp.find( '//refsect2', :to-list));

for @r -> $rs2 {
  my $attrs = $rs2.attribs;
  if $attrs<role>:exists and $attrs<id>:exists {
    note "$attrs<role>, $attrs<id>";
  }

  else {
    note $attrs.keys.join(', ');
  }
}


$file = '/home/marcel/.config/io.github.martimm.source-skim-tool/Gtkdoc/Glib/docs/error_reporting.xml';

my XML::Document $d = from-xml-file($file.IO);

$xp .= new(:$file);
@r = ($xp.find( '//refsect2', :to-list));

for @r -> $rs2 {
  my $attrs = $rs2.attribs;
  if $attrs<role>:exists and $attrs<id>:exists {
    note "$attrs<role>, $attrs<id>";
  }

  else {
    note $attrs.keys.join(', ');
  }
}
}}