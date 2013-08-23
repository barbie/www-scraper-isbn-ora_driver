#!/usr/bin/perl -w
use strict;

use lib './t';
use Test::More tests => 10;

###########################################################

	use WWW::Scraper::ISBN;
	my $scraper = WWW::Scraper::ISBN->new();
	isa_ok($scraper,'WWW::Scraper::ISBN');

	$scraper->drivers("ORA");
	my $isbn = "1565926285";
	my $record = $scraper->search($isbn);

	is($record->found,1);
	is($record->found_in,'ORA');

	my $book = $record->book;
	is($book->{'isbn'},'1565926285');
	is($book->{'title'},'qmail');
	is($book->{'author'},'John Levine');
	is($book->{'book_link'},'http://www.oreilly.com/catalog/qmail/index.html');
	is($book->{'image_link'},'http://www.oreilly.com/catalog/covers/qmail_icon.gif');
	is($book->{'description'},'qmail concentrates on common tasks like moving a sendmail setup to qmail, or setting up a POP toaster, a system that provides mail service to a large number of users on other computers sending and retrieving mail remotely. The book fills crucial gaps...');
	is($book->{'pubdate'},'Mar. 25, 2004');

###########################################################

