#!/usr/bin/perl

use lib '../perl';
use strict;
use utf8;
use warnings;

use CGI qw(-utf8);
use Encode;
use URI::Encode qw(uri_encode);

use catgraph;

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

my $result = catgraph::convertCatgraphParameters(@parameters);
my %allOutputParameters = %$result;

my @sortList = qw(wiki category title ns rel depth limit showhidden algorithm format links);

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

my $outputUrl = '//tools.wmflabs.org/vcat/render?' . $outputParams;

print $q->redirect($outputUrl);
