#!/usr/bin/perl

use lib '../perl';
use strict;
use utf8;
use warnings;

use CGI qw(-utf8);
use Encode;
use HTML::Template;

use catgraph;

my $q = CGI->new;

my $template = HTML::Template->new(
		filename => '../perl/catgraph-convert.template.html',
		strict => 0
	);

my $lang = $q->param('lang');
unless ($lang) {
	$lang = 'en';
}

if ($q->param('doConvert')) {
	my $inputUrl = $q->param('inputUrl');
	my ($inputParameterString) = ($inputUrl =~ /\?(.*)$/);

	my @templateInputParameters;
	for my $part (split("&",$inputParameterString)) {
		my ($key, $value);
		if ($part !~ /=/) {
			$key = $part;
			$value = undef;
		} else {
			($key, $value) = ($part =~ /^(.*)=(.*)$/);
		}
		push @templateInputParameters, {
				key => $key,
				value => $value,
				hasValue => defined $value
			};
	}
	
	my $result = catgraph::convertCatgraphParameters(@templateInputParameters);
	my %allOutputParameters = %$result;
	
	my @sortList = qw(wiki category title ns rel depth limit showhidden algorithm format links);
	
	my $outputUrl = '//tools.wmflabs.org/vcat/render?';
	if ($inputUrl =~ /^https:/) {
		$outputUrl = 'https:' . $outputUrl;
	} else {
		$outputUrl = 'http:' . $outputUrl;
	}
	my @templateOutputParameters;
	for my $key (@sortList) {
		if (exists $allOutputParameters{$key}) {
			my $valueArrayRef = $allOutputParameters{$key};
			for my $value (@$valueArrayRef) {
				if (@templateOutputParameters) {
					$outputUrl .= '&';
				}
				if ($value eq '') {
					$outputUrl .= $key;
				} else {
					$outputUrl .= $key . '=' . $value;
				}
				push @templateOutputParameters, {
						key => $key,
						value => $value,
						hasValue => defined $value
					};
			}
			delete $allOutputParameters{$key};
		}
	}
	
	$template->param(
			hasResult => 1,
			inputUrl => $inputUrl,
			inputParameters => \@templateInputParameters,
			outputParameters => \@templateOutputParameters,
			outputUrl => $outputUrl
		);
	
} else {
	$template->param(hasResult => 0);
}

$template->param(
		lang => $lang,
		languages => catgraph::getLanguages()
	);
my $translations = catgraph::getTranslations($lang);
while (my ($key, $value) = each $translations) {
	$template->param(
		't_'.$key => $value
	);
}

print $q->header('Content-type' => 'text/html');
print $template->output;
