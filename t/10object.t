#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 11;

###########################################################

use WWW::Scraper::ISBN;
my $scraper = WWW::Scraper::ISBN->new();
isa_ok($scraper,'WWW::Scraper::ISBN');

SKIP: {
	skip "Can't see a network connection", 10   if(pingtest());

	$scraper->drivers("ORA");
	my $isbn = "9780596001735";
	my $record = $scraper->search($isbn);
    diag($record->error)    unless($record->found);

    unless($record->found) {
		diag($record->error);
    } else {
		is($record->found,1);
		is($record->found_in,'ORA');

		my $book = $record->book;
		is($book->{'isbn'},'9780596001735');
		is($book->{'title'},'Perl Best Practices');
		is($book->{'author'},'Damian Conway');
		is($book->{'book_link'},'http://oreilly.com/catalog/9780596001735/');
		is($book->{'image_link'},'http://covers.oreilly.com/images/9780596001735/sm.gif');
		like($book->{'description'},qr/^Perl Best Practices offers a collection of 256 guidelines/);
		like($book->{'pubdate'},qr/Jul. \d{2}, 2005/);
		is($book->{'publisher'},q!O'Reilly Media!);

        #use Data::Dumper;
        #diag("book=[".Dumper($book)."]");
	}
}

###########################################################

# crude, but it'll hopefully do ;)
sub pingtest {
  system("ping -q -c 1 www.google.com >/dev/null 2>&1");
  my $retcode = $? >> 8;
  # ping returns 1 if unable to connect
  return $retcode;
}
