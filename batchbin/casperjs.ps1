#Get location of scripts execution
$currentLocation = split-path -parent $MyInvocation.MyCommand.Definition;
#Set casper location to be the parent of the scripts executing folder
#This assumes that the script will be in a folder such as batchbin
$casperLocation = "$currentLocation\..";
#A path to the bin folder
$casperBin = "$currentLocation\..\bin\";

#Set an environment variable
$env:CASPER_PATH = $casperBin;
#Get the command that invoked the script
$command = $MyInvocation.Line;
#Get each individual 'word'
$commands = $command.split(" ");
#A list of phantomjs commands
$phantomReservedArgs = "--cookies-file","--config","--debug","--disk-cache","--ignore-ssl-errors","--load-images","--load-plugins","--local-storage-path","--local-storage-quota","--local-to-remote-url-access","--max-disk-cache-size","--output-encoding","--proxy","--proxy-auth","--proxy-type","--remote-debugger-port","--remote-debugger-autorun","--script-encoding","--web-security"
#Create two empty arrays
$phantomArgs = @()
$casperArgs = @()
$i = 1;
#For each command
foreach($cmd in $commands) {
	
	if($cmd.StartsWith("--")) {
		#If it is a phantomjs reserved command
		if($phantomReservedArgs -contains $cmd) {
			#Append it to the array of phantom commands
			$phantomArgs += $cmd;
		} else {
			#Otherwise append it to the list of casper args
			$casperArgs += $cmd;
		}
	} else {
		#If it isn't a --Command but isn't the script name, assume it is a casper command and let casperjs bomb out
		if($i -gt 2) {
			$casperArgs += $cmd;
		}
	}
	$i++;
}

#Start phantomjs bootstrapping casperjs with our arguments
Invoke-Expression "phantomjs $phantomArgs $casperBin\bootstrap.js --casper-path=$casperLocation --cli $casperArgs"

