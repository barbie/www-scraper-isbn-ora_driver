package WWW::Scraper::ISBN::ORA_Driver;

use strict;
use warnings;

use vars qw($VERSION @ISA);
$VERSION = '0.12';

#--------------------------------------------------------------------------

=head1 NAME

WWW::Scraper::ISBN::ORA_Driver - Search driver for O'Reilly Media's online catalog.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 DESCRIPTION

Searches for book information from the O'Reilly Media's online catalog.

=cut

#--------------------------------------------------------------------------

###########################################################################
# Inheritence

use base qw(WWW::Scraper::ISBN::Driver);

###########################################################################
# Modules

use WWW::Mechanize;

###########################################################################
# Constants

use constant	ORA		=> 'http://www.oreilly.com';
use constant	SEARCH	=> 'http://search.oreilly.com';
use constant	QUERY	=> '?submit.x=17&submit.y=8&q=%s';

#--------------------------------------------------------------------------

###########################################################################
# Public Interface

=head1 METHODS

=over 4

=item C<search()>

Creates a query string, then passes the appropriate form fields to the ORM
server.

The returned page should be the correct catalog page for that ISBN. If not the
function returns zero and allows the next driver in the chain to have a go. If
a valid page is returned, the following fields are returned via the book hash:

  isbn          (now returns isbn13)
  isbn10        
  isbn13
  ean13         (industry name)
  author
  title
  book_link
  image_link
  description
  pubdate
  publisher
  binding       (if known)
  pages         (if known)
  weight        (if known) (in grammes)
  width         (if known) (in millimetres)
  height        (if known) (in millimetres)

The book_link and image_link refer back to the O'Reilly US website.

=back

=cut

sub search {
	my $self = shift;
	my $isbn = shift;
	$self->found(0);
	$self->book(undef);

	my $url = SEARCH . sprintf(QUERY,$isbn);
	my $mech = WWW::Mechanize->new();
    $mech->agent_alias( 'Linux Mozilla' );
	$mech->get( $url );
    return $self->handler("O'Reilly Media website appears to be unavailable.")
	    unless($mech->success());

	# The Search Results page
    my $content = $mech->content();
    my ($book) = $content =~ m!<div class="book_text">\s*<p class="title">\s*<a href="([^"]+)"!;

	unless(defined $book) {
        print STDERR "\n#url=$url\n";
        print STDERR "\n#content=".$mech->content();
	    return $self->handler("Could not extract data from the O'Reilly Media search page [".($mech->uri())."].");
    }

	$mech->get( $book );
    my $html = $mech->content();
    my $data = {};

    for my $name ('book.isbn','ean','target','reference','isbn','graphic','graphic_medium','graphic_large','book_title','author','keywords','description','date') {
        next    unless($html =~ m!<meta name="$name" content="([^"]+)" />!i);
        $data->{$name} = $1;
    }

    ($data->{isbn13},$data->{isbn10}) = $html =~ m!<dt>(?:Print )?ISBN:</dt><dd[^>]+>([\d-]+)</dd>\s*<dt class="isbn-10"> \| ISBN 10:</dt> <dd>([\d-]+)</dd>!;
    ($data->{pages}) = $html =~ m!<dt>Pages:</dt> <dd[^>]+>\s*(\d+)\s*</dd>!;

    $data->{graphic} ||= $data->{$_}    for('graphic_medium','graphic_large');  # alternative graphic fields
    $data->{$_} =~ s!\D+!!g             for('isbn13','isbn10');

	unless(defined $data) {
        print STDERR "\n#url=$url\n";
        print STDERR "\n#content=".$mech->content();
	    return $self->handler("Could not extract data from the O'Reilly Media result page [".($mech->uri())."].");
    }

	my $bk = {
		'ean13'		    => $data->{ean},
		'isbn13'		=> $data->{ean},
		'isbn10'		=> $data->{isbn10},
		'isbn'			=> $data->{ean},
		'author'		=> $data->{author},
		'title'			=> $data->{book_title},
		'book_link'		=> $mech->uri(),
		'image_link'	=> ($data->{graphic} !~ /^http/ ? ORA : '') . $data->{graphic},
		'description'	=> $data->{description},
		'pubdate'		=> $data->{date},
		'publisher'		=> q!O'Reilly Media!,
		'binding'	    => $data->{binding},
		'pages'		    => $data->{pages},
		'weight'		=> $data->{weight},
		'width'		    => $data->{width},
		'height'		=> $data->{height}
	};
	$self->book($bk);
	$self->found(1);
	return $self->book;
}

1;
__END__

=head1 REQUIRES

Requires the following modules be installed:

L<WWW::Scraper::ISBN::Driver>,
L<WWW::Mechanize>,
L<Template::Extract>

=head1 SEE ALSO

L<WWW::Scraper::ISBN>,
L<WWW::Scraper::ISBN::Record>,
L<WWW::Scraper::ISBN::Driver>

=head1 AUTHOR

  Barbie, <barbie@cpan.org>
  Miss Barbell Productions, <http://www.missbarbell.co.uk/>

=head1 COPYRIGHT & LICENSE

  Copyright (C) 2004-2010 Barbie for Miss Barbell Productions

  This module is free software; you can redistribute it and/or
  modify it under the Artistic Licence v2.

=cut
