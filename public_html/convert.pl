#!/usr/bin/perl

use strict;
use utf8;
use warnings;

use CGI qw(-utf8);
use Encode;
use HTML::Template;
use JSON;
use Redis;

my $q = CGI->new;

my $template = HTML::Template->new(
		filename => 'convert.template.html',
		strict => 0
	);

if ($q->param('doConvert')) {
	my @templateInputParameters;
	my $inputUrl = $q->param('inputUrl');
	my ($inputParameterString) = ($inputUrl =~ /\?(.*)$/);
	
	my @cats;
	my %outputParameters;
	
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
		
		if ($key eq 'cat') {
			push @cats, $value;
		} else {
			$outputParameters{$key} = $value;
		}
		
	}
	
	# These parameters have been renamed
	my %renameMap = (
			cat => 'title',
			d => 'depth',
			n => 'limit'
		);
	while (my ($keyInput, $keyOutput) = each %renameMap) {
		if (exists $outputParameters{$keyInput}) {
			$outputParameters{$keyOutput} = $outputParameters{$keyInput};
			delete $outputParameters{$keyInput};
		}
	}
	
	# Set ns to 14 by default if it is not supplied and sub=article is also not supplied
	if (
		!exists $outputParameters{'ns'} and
		(!exists $outputParameters{'sub'} or $outputParameters{'sub'} ne 'article')
	) {
		$outputParameters{'ns'} = '14';
	}
	
	# Set rel=subcategory if sub is set to a generic true value, but not 'article'
	if (
		exists $outputParameters{'sub'} and
		$outputParameters{'sub'} ne 'article' and
		isPhpTrue($outputParameters{'sub'})
	) {
		$outputParameters{'rel'} = 'subcategory';
		delete $outputParameters{'sub'};
	}
	
	# Set algorithm=fdp if the fdp parameter is a generic true value
	if (exists $outputParameters{'fdp'}) {
		if (isPhpTrue($outputParameters{'fdp'})) {
			$outputParameters{'algorithm'} = 'fdp';
		}
	}

	# format=png is redundant
	if (exists $outputParameters{'format'} and $outputParameters{'format'} eq 'png') {
		delete $outputParameters{'format'};
	}
	
	my %allOutputParameters;
	# Fill parmeters category or title
	if (exists $outputParameters{'ns'} and $outputParameters{'ns'} eq '14') {
		# If ns is not supplied or 14, use category for cat parameters and remove ns
		$allOutputParameters{'category'} = \@cats;
		delete $outputParameters{'ns'};
	} else {
		# If ns is not 14, we must use title
		$allOutputParameters{'title'} = \@cats;
	}
	# Fill in all other parameters
	while (my ($key, $value) = each %outputParameters) {
		$allOutputParameters{$key} = [$outputParameters{$key}];
	}
	
	my @sortList = qw(wiki category title ns rel depth limit showhidden algorithm format);
	
	my $outputUrl = 'https://tools-test/vcat/render?';
	my @templateOutputParameters;
	for my $key (@sortList) {
		if (exists $allOutputParameters{$key}) {
			my $valueArrayRef = $allOutputParameters{$key};
			for my $value (@$valueArrayRef) {
				if (@templateOutputParameters) {
					$outputUrl .= '&';
				}
				$outputUrl .= $key . '=' . $value;
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

print $q->header('Content-type' => 'text/html');
print $template->output;

sub isPhpTrue {
	my $s = shift;
	return !isPhpFalse($s);
}

sub isPhpFalse {
	my $s = shift;
	return 1 if !(defined $s) or ($s eq '') or ($s eq '0') or ($s eq 'false');
	return 0;
}