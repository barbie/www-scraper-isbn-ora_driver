#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 11;

###########################################################

	use WWW::Scraper::ISBN;
	my $scraper = WWW::Scraper::ISBN->new();
	isa_ok($scraper,'WWW::Scraper::ISBN');

	$scraper->drivers("ORA");
	my $isbn = "1565926285";
	my $record = $scraper->search($isbn);

	SKIP: {
		skip($record->error . "\n",10)	unless($record->found);

		is($record->found,1);
		is($record->found_in,'ORA');

		my $book = $record->book;
		is($book->{'isbn'},'1565926285');
		like($book->{'title'},qr/qmail/);
		is($book->{'author'},'John Levine');
		is($book->{'book_link'},'http://www.oreilly.com/catalog/qmail/index.html');
		is($book->{'image_link'},'http://www.oreilly.com/catalog/covers/1565926285_sm.gif');
		is($book->{'description'},'qmail concentrates on common tasks like moving a sendmail setup to qmail, or setting up a POP toaster, a system that provides mail service to a large number of users on other computers sending and retrieving mail remotely. The book fills crucial gaps...');
		like($book->{'pubdate'},qr/Mar. \d{2}, 2004/);
		is($book->{'publisher'},q!O'Reilly Media!);
	}

###########################################################

