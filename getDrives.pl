#!/usr/bin/perl -w
#
#
# Copyright (C) 2013 Dominik Sigmund
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#
use strict;
use Getopt::Long;
use vars qw($PROGNAME);
use vars qw($VERSION);

my ( $opt_V, $opt_h, $opt_t, $opt_m, $opt_f, $cmd, $output);
$PROGNAME = "getDrives.pl";
$VERSION = "0.5";

sub print_usage () {
    print "Short syntax summary: \n";
    print "getDrives.pl -t /var/www/  \n\n";
    print "getDrives.pl -t /var/www/ -f xml -m Videos\n\n";
}

sub print_help () {
    print "Copyright (c) 2013 Dominik Sigmund";
    print_usage();
    print "\n";
    print " This output\n";
    print "\n";
}
# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

Getopt::Long::Configure('bundling');
GetOptions(
    "V"             => \$opt_V,
    "version"       => \$opt_V,
    "h"             => \$opt_h,
    "help"          => \$opt_h,
    "t=s"           => \$opt_t,
    "target"      	=> \$opt_t,
    "f=s"           => \$opt_f,
    "format"      	=> \$opt_f,
    "m=s"           => \$opt_m,
    "mount"      	=> \$opt_m
);

if ($opt_V) {
	print $VERSION;
    exit 0;
}

if ($opt_h) {
    print_help();
    exit 0;
}

if ( !$opt_t ) {
    print "No target for HTML specified\n\n";
    print_usage();
    exit 3;
}
if ( !$opt_m ) {
   $opt_m="a";
}
if ( !$opt_f ) {
   $opt_f="html";
}


# Step 0: Perform Command
if($opt_m eq "a"){
	open (DF, "df -h|") or die "$!\n";
}
else {
	open (DF, "df -h| grep ".$opt_m ."|") or die "$!\n";
}

# Step 1: und ausgeben

$output ="<html>";
$output .= "<head>";
$output .= "	<title>Drives</title>";
$output .= "	<style>";
$output .= "		#progress {
					 width: 500px;   
					 border: 1px solid black;
					 position: relative;
					 padding: 3px;
					}
					
					#percent {
					 position: absolute;   
					 left: 50%;
					}
					
					#bar {
					 height: 20px;
					}";
$output .= "	</style>";
$output .= "</head>";

$output .= "<body>";

$output .=  "<table border=1>\n";
$output .=  "<tr><th colspan=\"6\">Daten</th></tr>\n";
$output .=  "<tr><th>Dateisystem</th><th>Größe</th><th>Belegt</th><th>Verfügbar</th><th>Bel %</th><th>Belegt</th></tr>\n";
while (<DF>) {
	if($opt_m eq "a"){
  	next if $. == 1;
	}
  my @values = split(/ {1,}/, $_);
  $output .=  "<tr>";
  $output .= "<td>".$values[0]."</td>";
  $output .= "<td>".$values[1]."</td>";
  $output .= "<td>".$values[2]."</td>";
  $output .= "<td>".$values[3]."</td>";
  $output .= "<td>".$values[4]."</td>";
  $output .= "<td><div id=\"progress\">";
  $output .= "  <span id=\"percent\">".$values[4]."</span>";
  my $val_flat = $values[4];
  $val_flat =~ s/%//g;
  my $bg="green";
  if($val_flat lt 50){
  	$bg="green";
  }
  elsif($val_flat lt 90 && $val_flat gt 50){
  	$bg="orange";
  }
  else {
  	$bg="red";
  }
  $output .= "  <div id=\"bar\" style=\"width:".$values[4].";background-color: ".$bg.";\"></div>";
  $output .= "</div></td>";
  
  $output .= "</tr>\n";
}
$output .=  "</table>\n";
$output .= "</body>";
$output .= "</html>";
close(DF);

open (OUTPUT, '>'.$opt_t.'drives.html');
print OUTPUT $output;
close (OUTPUT); 
exit 0;