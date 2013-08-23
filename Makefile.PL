use ExtUtils::MakeMaker;
WriteMakefile(
    'NAME'			=> 'WWW::Scraper::ISBN::ORA_Driver',
    'VERSION_FROM'	=> 'lib/WWW/Scraper/ISBN/ORA_Driver.pm',
    'PREREQ_PM'		=> {
		Test::More					=> 0.45,	# for testing
		WWW::Scraper::ISBN			=> 0.25,
		WWW::Scraper::ISBN::Driver	=> 0.18,
		WWW::Mechanize				=> 0,
		Template::Extract			=> 0,
	},
	NO_META			=> 1,

    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => q|Search driver for O'Reilly & Associates's online catalog|,
       AUTHOR     => 'Barbie <barbie@cpan.org>') : ()),
);
