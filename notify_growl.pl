#!/usr/bin/perl -w
#
# Created by Mathieu GagnÃ© 2009
#
 
use strict;
use warnings;
use Net::Growl;
use Getopt::Long qw(:config no_ignore_case bundling);
 
# Default values
my $application = 'Nagios';
my $title = 'Alert';
my $message = '';
my $priority = 2;
my $sticky = 0;
my $destination = 'localhost';
my $password = '';
 
my $help = 0;
 
my $pod2usage = sub {
  # Load Pod::Usage only if needed.
  require "Pod/Usage.pm";
  import Pod::Usage;
 
        pod2usage(@_);
};
 
# Declare and retreive options
GetOptions(
  'h|help'          => \$help,
  'a|application=s' => \$application,
  't|title=s'       => \$title,
  'm|message=s'     => \$message,
  'P|priority=i'    => \$priority,
  's|sticky'        => \$sticky,
  'H|host=s'        => \$destination,
  'p|password=s'    => \$password,
) or $pod2usage->(1);
 
# Print help
$pod2usage->(1) if $help;
 
# Validate options
if ( $application eq '' ) {
  die "Error: Missing mandatory option: application\n";
}
 
if ( $title eq '' ) {
  die "Error: Missing mandatory option: title\n";
}
 
if ( $message eq '' ) {
  die "Error: Missing mandatory option: message\n";
}
 
if ( $priority eq '' ) {
  die "Error: Missing mandatory option: priority\n";
}
 
if ( $password eq '' ) {
  die "Error: Missing mandatory option: password\n";
}
 
#
# Main program
#
 
# Set up the Socket
my %addr = (
  PeerAddr => $destination,
  PeerPort => Net::Growl::GROWL_UDP_PORT,
  Proto    => 'udp',
);
 
my $s = IO::Socket::INET->new ( %addr ) || die "Could not create socket: $!\n";
 
# Register the application
my $p = Net::Growl::RegistrationPacket->new(
  application => $application,
  password    => $password,
);
 
$p->addNotification();
 
print $s $p->payload();
 
# Send a notification
$p = Net::Growl::NotificationPacket->new(
  application => $application,
  title       => $title,
  description => $message,
  priority    => $priority,
  sticky      => $sticky,
  password    => $password,
);
 
print $s $p->payload();
 
close($s);
