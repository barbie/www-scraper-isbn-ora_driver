package WWW::Scraper::ISBN::ORA_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.03';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::ORA_Driver - Search driver for O'Reilly & Associates's online catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the O'Reilly & Associates's online catalog.

=cut

### CHANGES ###############################################################
#   0.01	07/04/2004	Initial Release
#	0.02	19/04/2004	Test::More added as a prerequisites for PPMs
#	0.03	11/05/2004	Add publisher book attribute
###########################################################################

#--------------------------------------------------------------------------

###########################################################################
#Library Modules                                                          #
###########################################################################

use WWW::Scraper::ISBN::Driver;
use WWW::Mechanize;
use Template::Extract;

###########################################################################
#Constants                                                                #
###########################################################################

use constant	ORA		=> 'http://www.oreilly.com';
use constant	SEARCH	=> 'http://catsearch.atomz.com/search/catsearch';
use constant	QUERY	=> '?sp-a=sp1000a5a9&sp-f=ISO-8859-1&sp-t=cat_search&sp-q=%s';

#--------------------------------------------------------------------------

###########################################################################
#Inheritence		                                                      #
###########################################################################

@ISA = qw(WWW::Scraper::ISBN::Driver);

###########################################################################
#Interface Functions                                                      #
###########################################################################

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the ORA 
server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn
  author
  title
  book_link
  image_link
  description
  pubdate
  publisher

The book_link and image_link refer back to the O'Reilly US website. 

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $url = SEARCH . sprintf(QUERY,$isbn);
	my $mechanize = WWW::Mechanize->new();
	$mechanize->get( $url );
	return undef	unless($mechanize->success());

	# The Search Results page
	my $template = <<END;
<!-- BOOK COLLECTION -->[% ... %]<a href="[% book %]" target="_self">[% ... %]
END
		   
	my $extract = Template::Extract->new;
    my $data = $extract->extract($template, $mechanize->content());
	   
	unless(defined $data) {
		print "Error extracting data from ORA result page.\n"	if $self->verbosity;
		$self->error("Could not extract data from ORA result page.\n");
		$self->found(0);
		return 0;
	}

	my $book = $data->{book};
	
	# The Book page
	$template = <<END;
<meta name="target" content="[% target %]" />[% ... %]
<meta name="reference" content="[% reference %]" />[% ... %]
<meta name="isbn" content="[% isbn %]" />[% ... %]
<meta name="graphic" content="[% graphic %]" />[% ... %]
<meta name="safari" content="[% ... %]" />[% ... %]
<meta name="book_title" content="[% title %]" />[% ... %]
<meta name="author" content="[% author %]" />[% ... %]
<meta name="keywords" content="[% ... %]" />[% ... %]
<meta name="description" content="[% description %]" />[% ... %]
<meta name="date" content="[% pubdate %]" />[% ... %]
END

	$mechanize->get( $book );
    $data = $extract->extract($template, $mechanize->content());

	unless(defined $data) {
		print "Error extracting data from ORA result page.\n"	if $self->verbosity;
		$self->error("Could not extract data from ORA result page.\n");
		$self->found(0);
		return 0;
	}

	my $bk = {
		'isbn'			=> $data->{isbn},
		'author'		=> $data->{author},
		'title'			=> $data->{title},
		'book_link'		=> $book,	# ORA . "/catalog/" . $data->{reference},
		'image_link'	=> ORA . $data->{graphic},
		'description'	=> $data->{description},
		'pubdate'		=> $data->{pubdate},
		'publisher'		=> q!O'Reilly & Associates!,
	};
	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

=over 4

=item L<WWW::Scraper::ISBN::Driver>

=item L<WWW::Mechanize>

=item L<Template::Extract>

=back

=head1 SEE ALSO

=over 4

=item L<WWW::Scraper::ISBN>

=item L<WWW::Scraper::ISBN::Record>

=item L<WWW::Scraper::ISBN::Driver>

=back

=head1 AUTHOR

  Barbie, E<lt>barbie@cpan.orgE<gt>
  Miss Barbell Productions, L<http://www.missbarbell.co.uk/>

=head1 COPYRIGHT

  Copyright (C) 2002-2004 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

=cut

