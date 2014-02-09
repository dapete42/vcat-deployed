#!/usr/bin/perl

use lib '../perl';
use strict;
use utf8;
use warnings;

use CGI qw(-utf8);
use Encode;
use URI::Encode qw(uri_encode);

use convert;

my $q = CGI->new;

my %vars = $q->Vars;
my @names = keys %vars;
my @parameters;
for my $name (@names) {
	my @values = split("\0",$vars{$name});
	for my $value (@values) {
		push @parameters, {
			key => (decode utf8=>$name),
			value => $value
		};
	}
}

my $result = convert::convertGraphvizParameters(@parameters);
my %allOutputParameters = %$result;

my @sortList = qw(wiki category title ns rel depth limit showhidden algorithm format);

my $outputParams = '';

my @templateOutputParameters;
while (my ($key, $valueArrayRef) = each %allOutputParameters) {
	for my $value (@$valueArrayRef) {
		if ($outputParams) {
			$outputParams .= '&';
		}
		if ($value eq '') {
			$outputParams .= uri_encode($key);
		} else {
			$outputParams .= uri_encode($key . '=' . $value);
		}
	}
}

my $outputUrl = 'http://tools.wmflabs.org/vcat/render?' . $outputParams;
# if ($inputUrl =~ /^https$/) {
# 	$outputUrl = 'https' . $outputUrl;
# } else {
# 	$outputUrl = 'http' . $outputUrl;
# }

# print $q->header('Content-type' => 'text/html');
# print "$outputUrl\n";

print $q->redirect($outputUrl);
