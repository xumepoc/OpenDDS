eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    & eval 'exec perl -S $0 $argv:q'
    if 0;

# -*- perl -*-

my @original_ARGV = @ARGV;

use Env (DDS_ROOT);
use lib "$DDS_ROOT/bin";
use Env (ACE_ROOT);
use lib "$ACE_ROOT/bin";
use PerlDDS::Run_Test;
use strict;

PerlDDS::add_lib_path('../ConsolidatedMessengerIdl');

my $status = 0;

my $test = new PerlDDS::TestFramework();

$test->{dcps_debug_level} = 1;
$test->{dcps_transport_debug_level} = 1;
# will manually set -DCPSConfigFile
$test->{add_transport_config} = 0;

my $sconfig = 0; # local

my $ini = " rtps.ini";

my $relay_security_opts;

$test->process("relay", "$ENV{DDS_ROOT}/bin/RtpsRelay", "-DCPSConfigFile relay.ini -ApplicationDomain 42 -VerticalAddress 4444 -HorizontalAddress 127.0.0.1:11444 ");

$test->process("publisher", "publisher", "-ORBDebugLevel 1 -DCPSConfigFile". $ini);
$test->process("subscriber", "subscriber", "-ORBDebugLevel 1 -DCPSConfigFile" . $ini);

$test->start_process("relay");

$test->start_process("publisher");
sleep 3;
$test->start_process("subscriber");

$test->stop_process(180, "subscriber");
$test->stop_process(5, "publisher");

if ($sconfig != 0) {
    $test->kill_process(5, "relay");
}

exit $test->finish();