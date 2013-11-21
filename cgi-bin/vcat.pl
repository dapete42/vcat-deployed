#!/usr/bin/perl

use strict;
use warnings;

use CGI qw(-utf8);
use Encode;
use JSON;
use Redis;

my $CONFIG = '/data/project/vcat/work/vcat.properties';

our $q = CGI->new;

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
	$json{decode utf8=>$name} = \@values;
}

my $now = `date +%Y%m%d%H%M%S`;
chomp $now;
my $pid = $$;
our $key = "$now-$pid"; 

my $redis_server_hostname = $config{'redis.server.hostname'};
my $redis_server_port = $config{'redis.server.port'};
$redis_server_port = 6379 unless $redis_server_port;

my $r;
eval { $r = Redis->new(server => "$redis_server_hostname:$redis_server_port", reconnect => 10) };
error($@) if $@;

my $redis_secret = $config{'redis.secret'};

my $redis_channel_request = $redis_secret . $config{'redis.channel.request.suffix'};
my $redis_channel_response = $redis_secret . $config{'redis.channel.response.suffix'};

my $redis_key_request = $redis_secret . '-' . $key . $config{'redis.key.request.suffix'};
my $redis_key_response = $redis_secret . '-' . $key . $config{'redis.key.response.suffix'};
my $redis_key_response_error = $redis_secret . '-' . $key . $config{'redis.key.response.error.suffix'};
my $redis_key_response_headers = $redis_secret . '-' . $key . $config{'redis.key.response.headers.suffix'};

our $json_encoded = to_json(\%json, {ascii=>1});
$r->set($redis_key_request => $json_encoded);;
my $listeners = $r->publish($redis_channel_request, $key);

if ($listeners == 0) {
	error("Control deamon not listening for requests on Redis");
}

our $keep_going = 1;
my $r2 = Redis->new(server => "$redis_server_hostname:$redis_server_port");
$r2->subscribe(
	$redis_channel_response,
	sub {
		my ($message, $channel, $subscribed_channel) = @_;
		if ($message eq $key) {
			$keep_going = 0;
		}
	}
);

my $wait = 60;
while ($keep_going && $wait > 0) {
	$r2->wait_for_messages(0.5) while $keep_going;
	$wait--;
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
	my $message = shift;
	print $q->header('Content-type' => 'text/plain');
	print "Error: $message";
	print STDERR "Request: $json_encoded\n";
	print STDERR "$message\n";
	exit;
}
