#!/usr/bin/perl

use Mail::Sender ;

my ($To, $subJect, $mesg) ;

chomp($To = $ARGV[0]) ;
chomp($subJect = $ARGV[1]) ;
chomp($mesg = $ARGV[2]) ;


my $from_address = "VNETMonitoring<emea.bgd.employees.MIS\@sungard.com>" ;
my $smtp_address = "10.244.176.2" ;

my $sender = new Mail::Sender
{smtp => "$smtp_address", from => "$from_address", debug => "/tmp/debug.txt"};

	$sender->MailMsg({to => "$To",
	                 subject => "$subJect",
			                  msg => "$mesg"});
					  $sender->Close ;
