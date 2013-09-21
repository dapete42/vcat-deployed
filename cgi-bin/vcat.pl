#!/usr/bin/perl

use strict;
use warnings;

use CGI;
use JSON;
use Redis;

my $CONFIG = '/data/project/vcat/work/vcat.properties';

my $q = CGI->new;

if (!-e $CONFIG) {
	error('config file not found');
}

my %config;
open CONFIG, '<', $CONFIG;
while (my $line = <CONFIG>) {
	chomp $line;
	if (my ($key, $value) = ($line =~ /^\s*([^#].*?)\s*=\s*(.*)$/)) {
		$key = $key;
		$value = $value;
		$config{$key} = $value;
	}
}
close CONFIG;

my %vars = $q->Vars;
my @names = keys %vars;
my %json;
for my $name (@names) {
	my @values = split("\0",$vars{$name});
	$json{$name} = \@values;
}

my $now = `date +%Y%m%d%H%M%S`;
chomp $now;
my $pid = $$;
our $key = "$now-$pid"; 

#our $key = 'test';

my $redis_server_hostname = $config{'redis.server.hostname'};
my $redis_server_port = $config{'redis.server.port'};
$redis_server_port = 6379 unless $redis_server_port;

my $r = Redis->new(server => "$redis_server_hostname:$redis_server_port");
#my $key = $r->randomkey;

my $redis_secret = $config{'redis.secret'};

my $redis_channel_request = $redis_secret . $config{'redis.channel.request.suffix'};
my $redis_channel_response = $redis_secret . $config{'redis.channel.response.suffix'};

my $redis_key_request = $redis_secret . '-' . $key . $config{'redis.key.request.suffix'};
my $redis_key_response = $redis_secret . '-' . $key . $config{'redis.key.response.suffix'};
my $redis_key_response_error = $redis_secret . '-' . $key . $config{'redis.key.response.error.suffix'};
my $redis_key_response_headers = $redis_secret . '-' . $key . $config{'redis.key.response.headers.suffix'};

$r->set($redis_key_request => encode_json(\%json));
$r->publish($redis_channel_request, $key);

our $keep_going = 1;
my $r2 = Redis->new(server => "$redis_server_hostname:$redis_server_port");
$r2->subscribe(
	$redis_channel_response,
	sub {
		my ($message, $channel, $subscribed_channel) = @_;
		$key;
		if ($message eq our $key) {
			$keep_going = 0;
		}
	}
);

while ($keep_going) {
	$r2->wait_for_messages(0.1) while $keep_going;
}
$r2->unsubscribe($redis_channel_response, sub {});

if ($r->exists($redis_key_response_error)) {
	error ($r->get($redis_key_response_error));
} else {
	my $headers_json = $r->get($redis_key_response_headers);
	my $response_file = $r->get($redis_key_response);
	
	binmode STDOUT;
	
	my $headers = decode_json($headers_json);
	print $q->header($headers);
	
	open RESPONSEFILE, '<', $response_file;
	binmode RESPONSEFILE;
	my $buffer;
	while (read(RESPONSEFILE, $buffer, 10240)) {
		print $buffer;
	}
	close RESPONSEFILE;
}

$r->del($redis_key_request);
$r->del($redis_key_response);
$r->del($redis_key_response_error);

sub error {
	print "Content-type: text/plain\n\nError: ";
	print shift;
	exit;
}