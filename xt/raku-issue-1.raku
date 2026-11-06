use v6.d;
my $v = 2;
my Hash $vs = %(:$v);

my $doc = qq:to/EODOC/;

    =head1 V
    \$v = $vs<v>

    \=begin code
    method handler \(
    EODOC

say $doc;
for ^$v { .say; }
