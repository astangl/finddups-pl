#!/usr/bin/perl -w
# Finddups - Find duplicate files across an arbitrary number of
#            directories, recursively searched
#
# Created:       1998/11/01 Alex Stangl
# Last modified: 2008/01/07 Alex Stangl

use File::Find;
use File::Compare;
use strict;

die "Usage: finddups dir1 [dir2 ... [dirN] ...]\n" unless @ARGV;

# Recursively fetch all non-directory filenames according to cmdline args,
# and store in $fileHash, organized into buckets by file size.
my %fileHash;
find(\&wanted, @ARGV);

# Iterate thru each bucket of same-sized files,
# reporting groups w/ identical contents.
my $size;
foreach $size (sort {$a <=> $b} keys %fileHash) {
	my $names = $fileHash{$size};
	my ($i, $j);
	for ($i = 0; $i < $#{$names}; ++$i) {
		next if $$names[$i] eq "";
		my $needHeader = 1;
		for ($j = $i + 1; $j <= $#{$names}; ++$j) {
			next if $$names[$j] eq "" or compare($$names[$i], $$names[$j]);
			print "Identical $size byte files\n    $$names[$i]\n" if $needHeader;
			$needHeader = 0;
			print "    $$names[$j]\n";
			$$names[$j] = "";	# Clear name so it's only shown once
		}
	}
}

sub wanted {
	return 0 if -d;
	my $size = -s;
	$fileHash{$size} = () if ! $fileHash{$size};
	push @{ $fileHash{$size} }, $File::Find::name;
}
