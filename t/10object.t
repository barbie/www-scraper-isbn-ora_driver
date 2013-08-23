#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 20;
use WWW::Scraper::ISBN;

###########################################################

my $DRIVER          = 'ORA';
my $CHECK_DOMAIN    = 'www.google.com';

my %tests = (
    '9780596001735' => [
        [ 'is',     'isbn',         '9780596001735'     ],
        [ 'is',     'isbn10',       '0596001738'        ],
        [ 'is',     'isbn13',       '9780596001735'     ],
        [ 'is',     'ean13',        '9780596001735'     ],
        [ 'is',     'title',        'Perl Best Practices'            ],
        [ 'is',     'author',       'Damian Conway'   ],
        [ 'is',     'publisher',    q!O'Reilly Media!    ],
        [ 'like',     'pubdate',      qr/Jul. \d{2}, 2005/ ],
        [ 'is',     'binding',      undef         ],
        [ 'is',     'pages',        '544'               ],
        [ 'is',     'width',        undef               ],
        [ 'is',     'height',       undef               ],
        [ 'is',     'weight',       undef               ],
        [ 'is',     'image_link',   'http://covers.oreilly.com/images/9780596001735/sm.gif' ],
        [ 'is',     'thumb_link',   'http://covers.oreilly.com/images/9780596001735/sm.gif' ],
        [ 'like',   'description',  qr|Perl Best Practices offers a collection of 256 guidelines| ],
        [ 'like',   'book_link',    qr|http://oreilly.com/catalog/9780596001735/| ]
    ],
);

my $tests = 0;
for my $isbn (keys %tests) { $tests += scalar( @{ $tests{$isbn} } ) + 2 }


###########################################################

my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", $tests+1   if(pingtest($CHECK_DOMAIN));

	$scraper->drivers($DRIVER);

    for my $isbn (keys %tests) {
        my $record = $scraper->search($isbn);
        my $error  = $record->error || '';

        SKIP: {
            skip "Website unavailable", scalar(@{ $tests{$isbn} }) + 2   
                if($error =~ /website appears to be unavailable/);

            unless($record->found) {
                diag($record->error);
            }

            is($record->found,1);
            is($record->found_in,$DRIVER);

            my $book = $record->book;
            for my $test (@{ $tests{$isbn} }) {
                if($test->[0] eq 'ok')          { ok(       $book->{$test->[1]},             ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'is')       { is(       $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'isnt')     { isnt(     $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'like')     { like(     $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); } 
                elsif($test->[0] eq 'unlike')   { unlike(   $book->{$test->[1]}, $test->[2], ".. '$test->[1]' found [$isbn]"); }

            }

            #use Data::Dumper;
            #diag("book=[".Dumper($book)."]");
        }
    }
}

###########################################################

# crude, but it'll hopefully do ;)
sub pingtest {
    my $domain = shift or return 0;
    my $cmd =   $^O =~ /solaris/i                           ? "ping -s $domain 56 1" :
                $^O =~ /dos|os2|mswin32|netware|cygwin/i    ? "ping -n 1 $domain "
                                                            : "ping -c 1 $domain >/dev/null 2>&1";

    system($cmd);
    my $retcode = $? >> 8;
    # ping returns 1 if unable to connect
    return $retcode;
}
