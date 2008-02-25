#!/usr/bin/perl -w

# autolatex - autolatex.pl
# Copyright (C) 1998-07  Stephane Galland <galland@arakhne.org>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; see the file COPYING.  If not, write to
# the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
# Boston, MA 02111-1307, USA.

require 5.004;

use strict ;

use File::Basename ;
use File::Spec ;
use File::Copy ;

#------------------------------------------------------
#
# Initialization code
#
#------------------------------------------------------
{
	my $PERLSCRIPTDIR ;
	my $PERLSCRIPTNAME ;
	my $LAUNCHINGNAME ;
	BEGIN{
	  # Where is this script?
	  $PERLSCRIPTDIR = "$0";
	  $LAUNCHINGNAME = basename("$0");
	  my $scriptdir = dirname( $PERLSCRIPTDIR );
	  while ( -e $PERLSCRIPTDIR && -l $PERLSCRIPTDIR ) {
	    $PERLSCRIPTDIR = readlink($PERLSCRIPTDIR);
	    if ( substr( $PERLSCRIPTDIR, 0, 1 ) eq '.' ) {
	      $PERLSCRIPTDIR = File::Spec->catfile( $scriptdir, "$PERLSCRIPTDIR" ) ;
	    }
	    $scriptdir = dirname( $PERLSCRIPTDIR );
	  }
	  $PERLSCRIPTNAME = basename( $PERLSCRIPTDIR ) ;
	  $PERLSCRIPTDIR = dirname( $PERLSCRIPTDIR ) ;
	  $PERLSCRIPTDIR = File::Spec->rel2abs( "$PERLSCRIPTDIR" );
	  # Push the path where the script is to retreive the arakhne.org packages
	  push(@INC,"$PERLSCRIPTDIR");
	  push(@INC,File::Spec->catfile("$PERLSCRIPTDIR","pm"));

	}
	use AutoLaTeX::Util;
	AutoLaTeX::Util::setAutoLaTeXInfo("$LAUNCHINGNAME","$PERLSCRIPTNAME","$PERLSCRIPTDIR");
}

use AutoLaTeX::Main;
use AutoLaTeX::Util;
use AutoLaTeX::OS;
use AutoLaTeX::Config;
use AutoLaTeX::Makefile;
use AutoLaTeX::Locale;

#------------------------------------------------------
#
# MAIN PROGRAM: Treat main program actions
#
#------------------------------------------------------

my %configuration = mainProgram();

if (getDebugLevel()>=6) {
	use Data::Dumper;
	die(Dumper(\%configuration));
}

#------------------------------------------------------
#
# MAIN PROGRAM: command line building
#
#------------------------------------------------------

# Soft to launch, GNU MAKE => make
my @commandLine = ( $configuration{'__private__'}{'gnu make'}||'make' );

# Default options usefull to pass to GNU MAKE
push @commandLine, '-e'; # Make command line macro definition prior to Makefile's definitions
push @commandLine, '-s'; # Be silent
push @commandLine, '-I', getAutoLaTeXDir(); # Include path for main files
push @commandLine, '-I', File::Spec->catfile(getAutoLaTeXDir(),"mkfiles");  # Include path for .mk files
push @commandLine, '-C', File::Spec->rel2abs($configuration{'__private__'}{'output.directory'});
					# Force to launch GNU MAKE in
					# the directory of the LaTeX project

# If a Makefile name was set, give it to GNU MAKE
if ($configuration{'__private__'}{'output.makefile name'}) {
	push @commandLine, '-f', File::Spec->rel2abs($configuration{'__private__'}{'output.makefile name'});
}

#
# The following variables are defined on the command line
# because they could not be put after the MainVars.mk inclusion
# inside the Makefile
#

# Force the PATH environment variable to point to the directories where
# autolatex scripts are stored
{
	my @PATH = File::Spec->path();
	push @PATH, File::Spec->catfile(getAutoLaTeXDir(),"scripts");
	if (@PATH) {
		push @commandLine, "PATH=".join(getPathListSeparator(),@PATH);
	}
}

# Be sure that auto generation flag was correctly set
if (exists $configuration{'generation.generate images'}) {
	my $active = cfgBoolean($configuration{'generation.generate images'});
	push @commandLine, "AUTO_GENERATE_IMAGES=".($active ? "yes" : "no");
}

# targets specified on the script command line should be directly passed to GNU MAKE
push @commandLine, @ARGV;

#------------------------------------------------------
#
# MAIN PROGRAM: DO THE ACTION
#
#------------------------------------------------------

# Fix the configuration file
if (defined($configuration{'__private__'}{'action.fix config file'})) {
	if (!$configuration{'__private__'}{'action.fix config file'}) {
		$configuration{'__private__'}{'action.fix config file'} = getProjectConfigFilename($configuration{'__private__'}{'output.directory'});
		$configuration{'__private__'}{'action.fix config file'} = undef unless (-r $configuration{'__private__'}{'action.fix config file'});
	}
	if (!$configuration{'__private__'}{'action.fix config file'}) {
		$configuration{'__private__'}{'action.fix config file'} = getUserConfigFile();
	}
	if (-r $configuration{'__private__'}{'action.fix config file'}) {
		print "Fixing configuration file '".$configuration{'__private__'}{'action.fix config file'}."'\n";
		doConfigurationFileFixing($configuration{'__private__'}{'action.fix config file'});
	}
	else {
		printErr($configuration{'__private__'}{'action.fix config file'},':',"$!\n");
	}
}
# Create the user configuration file
elsif (defined $configuration{'__private__'}{'action.create config file'}) {
	my $filename;
	if (($configuration{'__private__'}{'action.create config file'})&&
	    ($configuration{'__private__'}{'action.create config file'} eq 'project')) {
		locPrint("Creating default project configuration file...\n");
		$filename = getProjectConfigFilename($configuration{'__private__'}{'output.directory'});
	}
	else {
		locPrint("Creating default user configuration file...\n");
		$filename = getUserConfigFilename();
	}
	copy(getSystemConfigFilename(),"$filename") or printErr("$filename:", "$!");
}
# Create thedefault IST file
elsif ($configuration{'__private__'}{'action.create ist file'}) {
	locPrint("Creating default makeindex style file...\n");
	my $filename = File::Spec->catfile($configuration{'__private__'}{'output.directory'},"default.ist");
	copy(getSystemISTFilename(),"$filename") or printErr("$filename:","$!");
}
else {
	# Generating the makefile
	locDbg("Generating autolatex Makefile...");
	local *OUTPUTFILE;
	open(*OUTPUTFILE, "> ".$configuration{'__private__'}{'output.makefile name'})
		or printErr($configuration{'__private__'}{'output.makefile name'}.":","$!");
	print OUTPUTFILE getMakefileContent(%configuration);
	close(*OUTPUTFILE);

	# Launch GNU MAKE
	if (!$configuration{'__private__'}{'action.create makefile'}) {
		if (@ARGV) {
			locPrint("Launching compilation for {}...\n",join(',',@ARGV));
		}
		else {
			locPrint("Launching compilation...\n");
		}
		#print join(' ',@commandLine)."\n";
		exec @commandLine;
		die(join(' ',@commandLine,": $!\n"));
	}
}

exit(0);

__END__
