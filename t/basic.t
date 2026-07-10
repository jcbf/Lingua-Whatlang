use strict;
use warnings;
use Test::More tests => 5;

use_ok('Lingua::Whatlang');

my $res_en = Lingua::Whatlang->detect("The quick brown fox jumps over the lazy dog.");
is($res_en->{lang}, "eng", "Detects English ISO key");
is($res_en->{script}, "Latin", "Detects Latin alphabet signature");

my $res_ru = Lingua::Whatlang->detect("Привет, как дела?");
is($res_ru->{lang}, "rus", "Detects Russian ISO key");
is($res_ru->{script}, "Cyrillic", "Detects Cyrillic alphabet signature");

