#!/usr/bin/perl -w
# Copyright 2019; Provided as-is

use strict;

use IO::Socket::SSL qw( SSL_VERIFY_NONE );
use XML::LibXML::SAX;
use XML::Simple;
use XML::SAX;
use XML::SAX::Expat;
use XML::SAX::PurePerl;
use LWP::UserAgent;
use LWP::Protocol::https;
use Data::Dumper;
use HTTP::Request;
use URI::Escape;
#use JSON;
#use Term::ReadKey;
#use Excel::Writer::XLSX;
use Getopt::Long;
# use Log::Log4perl;

print STDERR "IBM ILMT Actions Generator\n";
print STDERR "Version 1.3\n";

my $worksheet = undef;
my $config = XMLin();
die "No configuration XML file. Must have same name as program with .xml extension.\n" unless ( defined $config );
	
if ( scalar @ARGV > 0 ) {
	if ( $ARGV[0] =~ /^config$/i ) {
		$config = XMLin( $ARGV[1] );
		## Allow password prompting for safety!
		if ( !defined( $config->{bespassword} ) ) {
			print STDERR
			  "No password set for user [$config->{besuser}]. Please type\n";
			print STDERR "that password here (it will not echo):";
			ReadMode("noecho");
			$config->{bespassword} = ReadLine(0);
			chomp $config->{bespassword};
			print STDERR "\nThank you.\n\n";
		}
	}
	else {
		die "Only valid argument is: [config] <configXMLfilename>\n";
	}
}
else {
	## Allow password prompting for safety!
	if ( !defined( $config->{bespassword} ) ) {
		print STDERR
		  "No password set for user [$config->{besuser}]. Please type\n";
		print STDERR "that password here (it will not echo):";
		ReadMode("noecho");
		$config->{bespassword} = ReadLine(0);
		chomp $config->{bespassword};
		print STDERR "\nThank you.\n\n";
		ReadMode("restore");
	}
}


#MAIN
my $lwp = LWP::UserAgent->new( keep_alive => 1 );

## Remove the SSL cert and name validation
$lwp->{ssl_opts}->{SSL_verify_mode} = SSL_VERIFY_NONE;
$lwp->{ssl_opts}->{verify_hostname} = 0;

# Recherche le site courant ILMT ou BFI ?
my $siteID = "13013";
runOneSite ($siteID);
$siteID = "13014";	
runOneSite ($siteID);
# That's all folks !
print "\n";
exit 0;



sub runOneSite {
my ( $localSiteID) = @_ ;

my $resultSite = queryRelevance("names of bes sites whose (id of it equals " . $localSiteID . ")");
my $comp = XMLin( $resultSite->decoded_content , ForceArray=>['content']);
if ( defined $comp->{Query}->{Result}->{Answer} ) {
	my $localSite = $comp->{Query}->{Result}->{Answer}->{content};
	print "\nSite found:" . $localSite;

	my $actionSettings = "";

	#ID 1002,  Upgrade to the latest version of IBM License Metric Tool 
	suppressActiveAction ("1002",$localSiteID);
$actionSettings = $config->{actionsettingspattern};
$actionSettings =~ s#<HasReapplyInterval></HasReapplyInterval>#<HasReapplyInterval>false</HasReapplyInterval># ;
$actionSettings =~ s#<HasEndTime>false</HasEndTime>#<HasEndTime>true</HasEndTime> <EndDateTimeOffset>P1D</EndDateTimeOffset> #;
$actionSettings =~ s#<Reapply>true</Reapply>#<Reapply>false</Reapply> #;
$actionSettings =~ s#<HasRetry>true</HasRetry>#<HasRetry>false</HasRetry> #;
createNewAction($actionSettings, "1002", $localSite);

	#id 85, Update VM Manager Tool to version
suppressActiveAction ("85",$localSiteID);
$actionSettings = $config->{actionsettingspattern};
$actionSettings =~ s#<HasReapplyInterval></HasReapplyInterval>#<HasReapplyInterval>false</HasReapplyInterval># ;
createNewAction($actionSettings, "85", $localSite);


	#id 20, Run Capacity Scan and Upload Results
suppressActiveAction ("20",$localSiteID);
$actionSettings = $config->{actionsettingspattern};
$actionSettings =~ s#<HasReapplyInterval></HasReapplyInterval>#<HasReapplyInterval>true</HasReapplyInterval> <ReapplyInterval>PT30M</ReapplyInterval># ;
createNewAction($actionSettings, "20", $localSite);

	#id 3, Upload Software Scan Results 
suppressActiveAction ("3",$localSiteID);
$actionSettings = $config->{actionsettingspattern};
$actionSettings =~ s#<HasReapplyInterval></HasReapplyInterval>#<HasReapplyInterval>false</HasReapplyInterval># ;
createNewAction($actionSettings, "3", $localSite);

	#id 80, Schedule VM Manager Tool Scan Results Upload
suppressActiveAction ("80",$localSiteID);
$actionSettings = $config->{actionsettingspattern};
$actionSettings =~ s#<HasReapplyInterval></HasReapplyInterval>#<HasReapplyInterval>true</HasReapplyInterval> <ReapplyInterval>PT30M</ReapplyInterval># ;
createNewAction($actionSettings, "80", $localSite);

	#id 1, Install or Upgrade Scanner
suppressActiveAction ("1",$localSiteID);
$actionSettings = $config->{actionsettingspattern};
$actionSettings =~ s#<Settings>#<Parameter Name="citAltInstallDir">true</Parameter> <Parameter Name="removeBzip">true</Parameter> <Settings>#;
$actionSettings =~ s#<HasReapplyInterval></HasReapplyInterval>#<HasReapplyInterval>false</HasReapplyInterval># ;
$actionSettings =~s#<HasTemporalDistribution>false</HasTemporalDistribution>#<HasTemporalDistribution>true</HasTemporalDistribution> <TemporalDistribution>PT2H</TemporalDistribution>#;
createNewAction($actionSettings, "1", $localSite);

	#id 2, Initiate Software Scan
suppressActiveAction ("2",$localSiteID);
$actionSettings = $config->{actionsettingspattern};
if ( defined( $config->{inventorycputhreshold} ) ) {$actionSettings =~ s#<Settings>#$config->{inventorycputhreshold} <Settings>#; }

if ( defined( $config->{inventoryperiod} ) ) {	$actionSettings =~ s#<HasTimeRange>false</HasTimeRange>#$config->{inventoryperiod} #; }

if ( defined( $config->{inventorywhose} ) ) {	$actionSettings =~ s#<HasWhose>false</HasWhose>#$config->{inventorywhose} #; }

if ( defined( $config->{inventorydayofweek} ) ) {$actionSettings =~ s#<HasDayOfWeekConstraint>false</HasDayOfWeekConstraint>#$config->{inventorydayofweek}#;}
			
$actionSettings =~ s#<HasReapplyInterval></HasReapplyInterval>#<HasReapplyInterval>true</HasReapplyInterval> <ReapplyInterval>P1D</ReapplyInterval> # ;
$actionSettings =~s#<HasTemporalDistribution>false</HasTemporalDistribution>#<HasTemporalDistribution>true</HasTemporalDistribution> <TemporalDistribution>PT2H</TemporalDistribution>#;
createNewAction($actionSettings, "2", $localSite);
}

# print Dumper ($resultSite);

}

sub queryRelevance {
	my ( $queryToRun, $compListResult) = @_;
	my $compListUrl = "https://" . $config->{server} . ":" . $config->{port} . "/api/query";
	my $postQuery = "relevance=" . $queryToRun;
	my $clistreq = HTTP::Request->new( POST => $compListUrl );
	$clistreq->header( 'content-type' => 'application/x-www-form-urlencoded' );
	$clistreq->content($postQuery);
	$clistreq->authorization_basic( $config->{besuser}, $config->{bespassword} );
	$compListResult = $lwp->request($clistreq);
	if ( !$compListResult->is_success ) {
		print STDERR "HTTP POST Error code: [" . $compListResult->code . "]\n";
		print STDERR "HTTP POST Error msg:  [" . $compListResult->message . "]\n";
		exit 1;
	}
	return $compListResult;
}

sub suppressActiveAction {
	my ( $FixletID, $siteID ) = @_;
#
# Récupération des ID des actions actuellement actives
#
my $query = "(id of it) of bes actions whose ( id of source fixlet of it equals " . $FixletID . " and state of it equals \"Open\" and (id of site of source fixlet of it equals " . $siteID . " ))";
my $resultActiveAction = queryRelevance ($query);


my $comp = XMLin( $resultActiveAction->decoded_content , ForceArray=>['content']);
#print Dumper($comp);
#
# Suppression des actions précédement lancées, à partir des IDs récupérés
#	
if ( defined $comp->{Query}->{Result}->{Answer} ) {
	if ( ref( $comp->{Query}->{Result}->{Answer} ) =~ /ARRAY/ ) {
		# plusieurs actions à traiter
		foreach my $ActionIDtoDelete ( @{ $comp->{Query}->{Result}->{Answer} } ) {
			deleteOneAction ($ActionIDtoDelete) }
		} else {
		# une seule action à traiter
		deleteOneAction ($comp->{Query}->{Result}->{Answer} );
		}
}		
else {
print "\nNo action to delete";
}
print "\n";
}

sub deleteOneAction {
	my ( $localActionIDtoDelete ) = @_;
	my $compListUrl = "https://" . $config->{server} . ":" . $config->{port} . "/api/action/" . $localActionIDtoDelete->{content} . "/stop";
	my $clistreq = HTTP::Request->new( POST => $compListUrl );
	$clistreq->header( 'content-type' => 'application/x-www-form-urlencoded' );
	$clistreq->authorization_basic( $config->{besuser}, $config->{bespassword} );
	my $compListResult = $lwp->request($clistreq);
	if ( !$compListResult->is_success ) {
		print  "\nCannot delete action ID " . $localActionIDtoDelete->{content};
		print "\nHTTP POST Error code: [" . $compListResult->code . "]";
		print "\nHTTP POST Error msg:  [" . $compListResult->message . "]";
	} else {
		print  "\nAction ID " . $localActionIDtoDelete->{content} . " deleted" ;
	}
	#print Dumper($compListResult);
}

sub createNewAction {
	my ( $actionsettings, $fixletID, $localsite ) = @_;
#
# Lancement de la nouvelle action
#	$config->{actionsettings}

	$actionsettings =~ s/<Sitename><\/Sitename>/<Sitename>$localsite<\/Sitename>/ ;
	$actionsettings =~ s/<FixletID><\/FixletID>/<FixletID>$fixletID<\/FixletID>/ ;
	# print $actionsettings ;

	my $compListUrlTakeAction = "https://" . $config->{server} . ":" . $config->{port} . "/api/actions";
	my $clistreqTakeAction = HTTP::Request->new( POST => $compListUrlTakeAction );
	$clistreqTakeAction->header( 'content-type' => 'application/x-www-form-urlencoded' );
	$clistreqTakeAction->authorization_basic( $config->{besuser}, $config->{bespassword} );
	$clistreqTakeAction->content($actionsettings);
	my $compListResultTakeAction = $lwp->request($clistreqTakeAction);
	# print Dumper ($compListResultTakeAction);
	my $compTakeAction = XMLin( $compListResultTakeAction->decoded_content );
	print "Action created \'" . $compTakeAction->{Action}->{Name} . "\',ID " . $compTakeAction->{Action}->{ID} ;


}