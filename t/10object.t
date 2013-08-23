#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 19;
use WWW::Scraper::ISBN;

###########################################################

my $CHECK_DOMAIN = 'www.google.com';

my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", 18   if(pingtest($CHECK_DOMAIN));

	$scraper->drivers("ORA");

	my $isbn   = "9780596001735";
	my $record = $scraper->search($isbn);
    my $error  = $record->error || '';

    SKIP: {
        skip "Website unavailable", 18   if($error =~ /website appears to be unavailable/);

        unless($record->found) {
            diag($record->error);
        } else {
            is($record->found,1);
            is($record->found_in,'ORA');

            my $book = $record->book;
            is($book->{'isbn'},         $isbn                   ,'.. isbn found');
            is($book->{'isbn10'},       '0596001738'            ,'.. isbn10 found');    # not provided by default
            is($book->{'isbn13'},       '9780596001735'         ,'.. isbn13 found');
            is($book->{'ean13'},        '9780596001735'         ,'.. ean13 found');
            is($book->{'title'},        'Perl Best Practices'   ,'.. title found');
            is($book->{'author'},       'Damian Conway'         ,'.. author found');
            is($book->{'publisher'},    q!O'Reilly Media!       ,'.. publisher found');
            like($book->{'pubdate'},    qr/Jul. \d{2}, 2005/    ,'.. pubdate found');
            like($book->{'description'},qr/^Perl Best Practices offers a collection of 256 guidelines/);
            is($book->{'book_link'},    'http://oreilly.com/catalog/9780596001735/');
            is($book->{'image_link'},   'http://covers.oreilly.com/images/9780596001735/sm.gif');
            is($book->{'binding'},      undef                   ,'.. binding found');
            is($book->{'pages'},        544                     ,'.. pages found');
            is($book->{'width'},        undef                   ,'.. width found');
            is($book->{'height'},       undef                   ,'.. height found');
            is($book->{'weight'},       undef                   ,'.. weight found');

            #use Data::Dumper;
            #diag("book=[".Dumper($book)."]");
        }
    }
}

###########################################################

# crude, but it'll hopefully do ;)
sub pingtest {
    my $domain = shift or return 0;
    system("ping -q -c 1 $domain >/dev/null 2>&1");
    my $retcode = $? >> 8;
    # ping returns 1 if unable to connect
    return $retcode;
}
