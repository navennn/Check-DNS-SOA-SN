# Check-Soa
A perl script used to batch compare serial numbers for SOA records in DNS.
Background for this script was some customers moving DNS zones outside of my company. It is used for quick verification by comparing SOA serial numbers of DNS zones.

You can also use this script to quickly check if increased SN has propagated to all the slave DNS servers.

Usage:

perl checksoas.pl

	-i, --interactive		provide list in interactive prompt. Confirm with CTRL+D.
	-f, --file [FILENAME]		provide file with domains. One domain per line.
	-s, --servers [SERVERS]		provide list of servers (IP or domain names)

Examples:

	perl checksoas.pl --servers 8.8.8.8 --file check_soa_domain_list.txt

	perl checksoas.pl --servers 8.8.8.8  ns.example.org 8.8.4.4 --file check_soa_domain_list.txt

	perl checksoas.pl --servers 8.8.8.8 8.8.4.4 --interactive
	
	perl checksoas.pl --servers 8.8.8.8 ns.example.org 8.8.4.4 --interactive

--file expects one domain name per line in a file.

You can specify as many DNS servers as you like.

Sample output:


	perl checksoas.pl --server 8.8.8.8 b.iana-servers.net --interactive
	Please provide interactive of domains to be checked. One domain per line. Confirm with Ctrl +D after newline(enter)
	example.org
	example.com
	Started at Tue Sep 24 20:50:04 2019
	
	Domain                                  DNS server          Status              SOA SN              DNS server          Status              SOA SN              Same SOA SN
	example.org                             8.8.8.8             NOERROR             2019090512          b.iana-servers.net  NOERROR             2019090512          Yes       
	example.com                             8.8.8.8             NOERROR             2019090512          b.iana-servers.net  NOERROR             2019090512          Yes       

	Finished at Tue Sep 24 20:50:04 2019
	Duration: 0s

Returns NOERROR on success, ERROR on response REFUSED (possibly zone doesn't exist on server).
