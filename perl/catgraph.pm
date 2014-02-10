package catgraph;

use strict;

sub convertCatgraphParameters {
	my @templateInputParameters = @_;
	
	my %outputParameters;
	my @cats;
	for my $data (@templateInputParameters) {
		
		if ($data->{'key'} eq 'cat') {
			push @cats, $data->{'value'};
		} else {
			$outputParameters{$data->{'key'}} = $data->{'value'};
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
	
	if (exists $outputParameters{'wiki'}) {
		my $wiki = $outputParameters{'wiki'};
		my $lang = exists $outputParameters{'lang'} ? $outputParameters{'lang'} : '';
		if ($wiki eq 'wikipedia') {
			if ($lang ne '') {
				$wiki = $lang . 'wiki';
				delete $outputParameters{'lang'};
			}
		} elsif ($wiki =~ /^(wiki(books|news|quote|wikiversity)|wiktionary)$/) {
			if ($lang ne '') {
				$wiki = $lang . $wiki;
				delete $outputParameters{'lang'};
			}
		} elsif ($wiki =~ /^commons|meta$/) {
			$wiki = $wiki . 'wiki';
		}
		$outputParameters{'wiki'} = $wiki;
	}
	
	# Set ns to 0 if sub=article is used
	if ($outputParameters{'sub'} eq 'article') {
		unless (exists $outputParameters{'ns'}) {
			$outputParameters{'ns'} = '0';
		}
		delete $outputParameters{'sub'};
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
		delete $outputParameters{'fdp'};
	}

	# format=png is redundant
	if (exists $outputParameters{'format'} and
		$outputParameters{'format'} eq 'png'
	) {
		delete $outputParameters{'format'};
	}
	
	# showhidden is disabled if ignorehidden was explicitly set to false
	if (
		exists $outputParameters{'ignorehidden'} and
		isPhpFalse($outputParameters{'ignorehidden'})
	) {
		$outputParameters{'showhidden'} = '1';
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
	
	return \%allOutputParameters;
	
}

sub isPhpTrue {
	my $s = shift;
	return !isPhpFalse($s);
}

sub isPhpFalse {
	my $s = shift;
	return 1 if !(defined $s) or ($s eq '') or ($s eq '0') or ($s eq 'false');
	return 0;
}

sub getLanguages {
	return [
		{ lang => '', name => 'English' },
		{ lang => 'de', name => 'Deutsch' }
	];
}

sub getTranslations {
	my $lang = shift;
	my $t;
	if ($lang eq 'de') {
		return {
			title => 'Catgraph-zu-vCat-Parameterkonvertierung',
			menu_languages => 'Sprachen',
			heading_convert => 'URL konvertieren',
			label_url => 'Ursprüngliche Catgraph-URL',
			warning_url => 'Achtung: Dieses Tool prüft nicht, ob die Parameter sinnvoll sind. Es wird sie so gut wie möglich konvertieren, aber wenn die ursprüngliche URL nicht funktionierte oder nicht korrent war, könnte die konvertierte URL genauso nicht funktionieren oder sich anders verhalten.',
			button_convert => 'Konvertieren',
			heading_result => 'Ergebnis der URL-Konvertierung',
			th_input_url => 'Eingabe-URL',
			th_input_parameters => 'Eingabeparameter',
			th_output_parameters => 'Ausgabeparameter',
			th_output_url => 'Ausgabe-URL'
		};
	} else {
		return {
			title => 'Catgraph to vCat parameter converter',
			menu_languages => 'Languages',
			heading_convert => 'Convert a URL',
			label_url => 'Original Catgraph URL',
			warning_url => 'Warning: This tool does not check if the parameters make any sense. It will try its best to convert them, but if the original URL did not work correctly or was inconsistent, the converted URL may also not work correctly or work differently from before.',
			button_convert => 'Convert',
			heading_result => 'Converted URL result',
			th_input_url => 'Input URL',
			th_input_parameters => 'Input parameters',
			th_output_parameters => 'Output parameters',
			th_output_url => 'Output URL'
		};
	}
}

1;
