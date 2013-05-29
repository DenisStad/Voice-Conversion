#!/usr/bin/perl

use strict;
use warnings;

my $inputFileName  = $ARGV[0];
my $outputFileName = $ARGV[1];

open(my $in, "<", $inputFileName) or die "can't open file: $!";
open(my $out, ">", $outputFileName) or die "can't open file: $!";

while (<$in>) {
	if(/t \[\d*\] = (\d|\.)*/) {
		s/\st \[\d*\] =\s//;
		print $out $_;
	}
}

close $in;
close $out;
