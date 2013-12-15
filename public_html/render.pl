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
	errorWithLog("Configuration file '$CONFIG' not found");
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
my %jsonParameters;
for my $name (@names) {
	my @values = split("\0",$vars{$name});
	$jsonParameters{decode utf8=>$name} = \@values;
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
errorWithLog($@) if $@;

my $redis_secret = $config{'redis.secret'};

my $redis_channel_request = $redis_secret . $config{'redis.channel.request.suffix'};
my $redis_channel_response = $redis_secret . $config{'redis.channel.response.suffix'};

my $jsonRequest = {
	"key" => $key,
	"parameters" => \%jsonParameters
};

our $json_encoded = to_json($jsonRequest, {ascii=>1});
my $listeners = $r->publish($redis_channel_request, $json_encoded);

if ($listeners == 0) {
	errorWithLog("Control deamon not listening for requests on Redis");
}

our $keep_going = 1;
my $jsonResponse;
my $r2 = Redis->new(server => "$redis_server_hostname:$redis_server_port");
$r2->subscribe(
	$redis_channel_response,
	sub {
		my ($message, $channel, $subscribed_channel) = @_;
		$jsonResponse = decode_json($message);
		if ($jsonResponse->{'key'} eq $key) {
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

if (exists $jsonResponse->{'error'}) {
	error ($jsonResponse->{'error'});
} else {
	my $headers = $jsonResponse->{'headers'};
	my $response_file = $jsonResponse->{'filename'};
	
	binmode STDOUT;
	
	print $q->header($headers);
	
	open RESPONSEFILE, '<', $response_file;
	binmode RESPONSEFILE;
	my $buffer;
	while (read(RESPONSEFILE, $buffer, 10240)) {
		print $buffer;
	}
	close RESPONSEFILE;
}

sub error {
	my $message = shift;
	print $q->header('Content-type' => 'text/plain');
	print "Error: $message";
	exit;
}

sub errorWithLog {
	my $message = shift;
	my $date = `date +'%Y-%m-%d %H:%M:%S'`;
	chomp $date;
	print STDERR "$date: (render.pl) $message\n";
	error($message);
}
