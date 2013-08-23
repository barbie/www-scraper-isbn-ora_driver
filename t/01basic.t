#!/usr/bin/perl -w
use strict;

#########################

use Test::More tests => 1;

eval "use WWW::Scraper::ISBN::ORA_Driver";
is($@,'');

#########################

