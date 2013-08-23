#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 12;

###########################################################

	use WWW::Scraper::ISBN;
	my $scraper = WWW::Scraper::ISBN->new();
	isa_ok($scraper,'WWW::Scraper::ISBN');

	$scraper->drivers("ORA");
	my $isbn = "9780596001735";
	my $record = $scraper->search($isbn);
    diag($record->error)    unless($record->found);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

		is($record->found,1);
		is($record->found_in,'ORA');

		my $book = $record->book;
		is($book->{'isbn'},'0596001738');
		is($book->{'isbn13'},'9780596001735');
		is($book->{'title'},'Perl Best Practices');
		is($book->{'author'},'Damian Conway');
		is($book->{'book_link'},'http://oreilly.com/catalog/9780596001735/index.html');
		is($book->{'image_link'},'http://www.oreilly.com/catalog/covers/0596001738_sm.gif');
		like($book->{'description'},qr/^Perl Best Practices offers a collection of 256 guidelines/);
		like($book->{'pubdate'},qr/Jul. \d{2}, 2005/);
		is($book->{'publisher'},q!O'Reilly Media!);
	}

###########################################################

