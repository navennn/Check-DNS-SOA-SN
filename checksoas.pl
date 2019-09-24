#!/usr/bin/perl
use warnings;
use strict;
use Term::ANSIColor;
use Getopt::Long;

if(!@ARGV)
{
    print "You need to provide some parameters!\n";
    print "Usage: $0\n\n";
    print "\t-i, --interactive\t\tprovide list in interactive prompt. Confirm with CTRL+D.\n";
    print "\t-f, --file [FILENAME]\t\tprovide file with domains. One domain per line.\n";
    print "\t-s, --servers [SERVERS]\t\tprovide list of servers (IP or domain names)\n\n";
    print "Examples:\n";
    print "\tperl checksoas.pl --servers 8.8.8.8 --file check_soa_domain_list.txt\n";
    print "\tperl checksoas.pl --servers 8.8.8.8 ns.example.org 8.8.4.4 --file check_soa_domain_list.txt\n";
    print "\tperl checksoas.pl --servers 8.8.8.8 8.8.4.4 --interactive\n";
    print "\tperl checksoas.pl --servers 8.8.8.8 ns.example.org 8.8.4.4 --interactive\n";
    print "\t";
    print "\n";
    exit;
}

my @servers;
my $interactive;
my $input_file;
GetOptions ("servers=s{1,}"   => \@servers,
            "interactive"  => \$interactive,
            "file=s"  => \$input_file)
            or die("Error in command line arguments\n");

if (defined $interactive && defined $input_file)
{
    die "You must specify either --servers or --file, but not both";
}
if (!@servers)
{
    die "Make sure to specify --servers (-s parameter!)";
}
my @dns_zones;
if (defined $input_file)
{
    if (!open ZONES, $input_file)
    {
        die "error message: $!\n";
    }
    chomp(@dns_zones = <ZONES>);

}
if (defined $interactive)
{
    print "Please provide interactive of domains to be checked. One domain per line. Confirm with Ctrl +D\ after newline(enter)\n";
    chomp(@dns_zones = <STDIN>);
}
my $start_date = time;

print "Started at " . localtime($start_date) . "\n\n";

printf("%-40s","Domain");
foreach (@servers)
{
    printf("%-20s","DNS server");
    printf("%-20s","Status");
    printf("%-20s","SOA SN");
}
printf("%-10s","Same SOA SN");
print "\n"; 
    
my $current_soa;
my $soa_check;

foreach my $domain (@dns_zones)
{
    printf("%-40s","$domain");
    $current_soa = &get_soa($domain, $servers[0]);
    $soa_check = 1;
    foreach my $dns_server (@servers)
    {
        my $domain_status = &get_status($domain, $dns_server);
        my $domain_soa = &get_soa($domain, $dns_server);
        if($soa_check)
        {
            if($current_soa eq $domain_soa)
            {
                $soa_check = 1;
                $current_soa = $domain_soa;
            }
            else
            {
                $soa_check = 0;
                $current_soa = $domain_soa;
            }
        }

        if($domain_status eq "NOERROR")
        {
            printf("%-20s","$dns_server");
            printf("%-29s", colored("$domain_status",'green'));
            printf("%-20s","$domain_soa");
        }
        elsif($domain_status eq "NXDOMAIN")
        {
            printf("%-20s","$dns_server");
            printf("%-29s", colored("$domain_status", 'red'));
            printf("%-29s", colored("ERROR", 'red'));
        }
        elsif($domain_status eq "REFUSED")
        {
            printf("%-20s","$dns_server");
            printf("%-29s", colored("$domain_status", 'red'));
            printf("%-29s", colored("ERROR", 'red'));
        }
        else
        {
            printf("%-20s","$dns_server");
            printf("%-20s","$domain_status");
            printf("%-29s", colored("Unknown error", 'red'));
        }
           
    }
    if($soa_check)
    {
        printf("%-19s", colored("Yes", 'green'));
    }
    else
    {
        printf("%-19s", colored("No", 'red'));
    }
    print "\n";
    
}

my $end_date = time;
my $duration = $end_date - $start_date;
print "\nFinished at " . localtime($end_date) . "\nDuration: " . $duration . "s\n";

sub get_status
{
    my($domain, $dns_server) = @_;
    my $domain_status = `dig $domain \@$dns_server | grep status | awk \'{print \$6}\'`;
    $domain_status =~ s/,//g;
    chomp $domain_status;
    return $domain_status;
}
sub get_soa
{
    my($domain, $dns_server) = @_;
    my $soa = `dig +nocmd +nostats +short SOA $domain \@$dns_server | awk \'{print \$3}\'`;
    chomp $soa;
    return $soa;

}
