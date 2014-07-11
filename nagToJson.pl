#!/usr/bin/perl
#
# Script to convert hosts and services in Nagios' status.dat file to JSON object suitable for MacMon.
# Written sloppily by Gary Locke

use strict;
use warnings;
use JSON;
use Data::Dumper;

# Script options.
my $outputFile = "/etc/nagios/share/rss/rss.json"; ### JSON file to output data.
my $logFile = "/var/log/nagiosToJSON.log"; ### Log file.
my $debug = 0;  ### Enable debugging output.
                # 0 = Off
                # 1 = Print final hosts output before JSON conversion.
                # 2 = Print details at every script action. Very chatty.

# Open log file.
open(LOG,">>",$logFile) or exit 1;

# Must be run as root.
if ($> ne 0)
{
    &logPrint("Script was not run as root, and was killed for this.");
    die("You are not root.\n");
}

# Set date. TODO: Add time.
my($day, $month, $year) = (localtime)[3,4,5];
$month = sprintf '%02d', $month+1;
$day = sprintf '%02d', $day;
$year = $year+1900;

# Date format for logs.
my $logDate = $day . '-' . $month . '-' . $year;

# Vars
my $statusFile;

# If file location is given and it exists, use it as the status file.
if(@ARGV ge 1 && -e $ARGV[0])
{
    print LOG $logFile . " User provided file argument. Using it as status file path.\n";
    $statusFile = $ARGV[0];

}

# Otherwise, try to find the file automatically.
else
{

    # Default status file locations to check if none was provided.
    my @statusFileLocations = (
        "/etc/nagios/var/status.dat",
        "/usr/local/nagios/var/status.dat"
    );
    
    # Open status.dat file.
    foreach my $file (@statusFileLocations)
    {
        $statusFile = $file if(-e $file);
    }
    
    # If we find a status file, carry on. Otherwise, exit.
    if(defined($statusFile))
    {
        &logPrint("Status file set to " . $statusFile);
    }
    else
    {
        &logPrint("No status file set. Exiting script.");
        exit 1;
    }
}

# Open status file.
open(STAT,"<",$statusFile);

# Empty arrays to store all host and service hashes.
my @hosts;
my @services;

# Flag to signal when temporary hash should be cleared.
my $clearTmp = 1;

# Vars for tracking position in status blocks.
my $inHost = 0;
my $inService = 0;

# Read status file.
while(my $line = <STAT>){

    # Clear temporary hash if needed.
    my %tmp if $clearTmp;
    
    # Also do this stuff.
    if($clearTmp){

        &debugPrint(2,"Replacing temporary hash to store the next set of data.");

        # Reset flag.
        $clearTmp = 0;
    }
        
    # Trim whitespace and trailing newlines from $line.
    $line =~ s/^\s+|\s+$//g;
    chomp($line);
    
    &debugPrint(2,"H:$inHost S:$inService L:$line");

    # Set var for tracking hostname of current block.
    my $hostName;

    # Start looking for individual hosts and services.
    #
    # If we haven't found one yet, check for the start of a block.
    if(!$inHost && !$inService)
    {
        
        # Does the line match the open block syntax (e.g. "hoststatus {" or "servicestatus {")?
        if($line =~ /^\s*hoststatus\s*{\s*$/i)
        {
            # We've found a host block!
            &debugPrint(2,"Entering host block.");
            $inHost = 1;
        }
        elsif($line =~ /^\s*servicestatus\s*{\s*$/i)
        {
            # We've found a service block!
            &debugPrint(2,"Entering service block.");
            $inService = 1;
        }
        
        # Nothing else to do with this line.
        next;
    }

    # If we get here, we're somewhere in some kind of a block. Let's see if we've reached the end.
    if(($inHost || $inService) && $line =~ /^\s*}\s*$/)
    {
        
        # If in a host block, push the current host data to the hosts array and clear the host array.
        if($inHost)
        {
            &debugPrint(2,"Reached end of host.");

            &debugPrint(2,"Here is our temporary host:");
            print Dumper(\%tmp) if $debug eq 2;

            &debugPrint(2,"Adding temporary host hash reference to parent hosts array.");
            push(@hosts,\%tmp);

        }

        # Or do the same for services.
        elsif($inService)
        {
            &debugPrint(2,"Reached end of service.");

            &debugPrint(2,"Here is our temporary service:");
            print Dumper(\%tmp) if $debug eq 2;

            &debugPrint(2,"Adding temporary service hash reference to parent services array.");
            push(@services,\%tmp);

        }

        # Mark the end of the block.
        &debugPrint(2,"Resetting state variables.");
        $inHost = 0;
        $inService = 0;

        # Set flag to clear the temporary array on the next iteration.
        $clearTmp = 1;
        next;
    }

    # If we get here, we've not reached the end of the current block, so let's add the current line as a key/value pair to the temporary hash.
    if($inHost||$inService)
    {
        if($line =~ /([^=]*)=(.*)/)
        {
            my $key = $1;
            my $val = $2;
    
            &debugPrint(2,"Adding line to temporary host hash as shown below:");
            &debugPrint(2,"Key: $key");
            &debugPrint(2,"Val: $val");
            $tmp{$key} = $val;
        }
        next;
    }

}

# Now that we're done processing the file, let's add all the services to the appropriate host hashes.
foreach my $host (@hosts){

    # Temporary array to store service hashrefs for each host.
    my @tmp;

    # Find the hostname we're working with.
    my $hostname = $host->{"host_name"};

    # Loop through all of the services and look for matching host names.
    foreach my $service (@services){

        # If the hostname matches, add a reference to this service hash to the temporary array.
        if(exists($service->{"host_name"})){
            if($service->{"host_name"} eq $hostname){
                &debugPrint(2,"Found matching service for $hostname. Updating temporary array.");
                push(@tmp,\%$service);
            }
        }
    }

    # Store reference to temporary array of hashrefs in "services" field of host hash.
    $host->{"services"} = \@tmp;

}

# Open output JSON file.
open(OUT,">",$outputFile);

# Finally, let's create the .json file for the nagios client to retrieve.
my $jh = new JSON;
print OUT $jh->convert_blessed->encode(\@hosts);

# Printing final array data for debugging.
&debugPrint(1,"Printing final hosts array data:");
print Dumper(@hosts) if $debug eq 1;
&debugPrint(2,"Printing final services array data:");
print Dumper(@services) if $debug eq 2;

# Close output file.
close(OUT);

# Close status file handle.
close(STAT);

# Close file handle for logging and exit.
close(LOG);

exit 0;

sub logPrint
{
    print LOG $logDate . ' ' . $_[0] . "\n";
}

sub debugPrint
{
    if($debug ge $_[0])
    {
        print $_[1] . "\n";
    }
}
