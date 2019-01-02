use strict;
use warnings;
use Test::More tests => 7;
use XML::SAX::Expat;

my $ege = 'http://xml.org/sax/features/external-general-entities';
my $epe = 'http://xml.org/sax/features/external-parameter-entities';

my $doc1 = <<EOF;
<!DOCTYPE foo [
<!ENTITY bar SYSTEM "file:///path/to/nonexistent/file.xml">
]>
<foo>&bar;</foo>
EOF

my $xp = XML::SAX::Expat->new();

is($xp->get_feature($ege), 1, "$ege initial state");
is($xp->get_feature($epe), 0, "$epe initial state");

is(scalar(grep { $_ eq $ege } $xp->supported_features), 1,
   "$ege in supported_features");
is(scalar(grep { $_ eq $epe } $xp->supported_features), 1,
   "$epe in supported_features");

eval { $xp->parse_string($doc1) };
ok($@, "exception retrieving nonexistent external entity");

$xp = XML::SAX::Expat->new();
$xp->set_feature($ege, 0);
is($xp->get_feature($ege), 0, "$ege set state");

eval { $xp->parse_string($doc1) };
ok(!$@, "no exception for nonexistent external entity which isn't fetched");
