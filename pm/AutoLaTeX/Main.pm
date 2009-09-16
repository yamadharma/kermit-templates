# autolatex - Main.pm
# Copyright (C) 1998-09  Stephane Galland <galland@arakhne.org>
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

=pod

=head1 NAME

Main.pm - Main program

=head1 FUNCTIONS

The provided functions are:

=over 4

=cut
package AutoLaTeX::Main;

$VERSION = '6.0';
@ISA = ('Exporter');
@EXPORT = qw( &analyzeCommandLineOptions &mainProgram &detectMainTeXFile ) ;
@EXPORT_OK = qw();

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

use Getopt::Long;
use File::Basename;
use AutoLaTeX::Util;
use AutoLaTeX::Config;
use AutoLaTeX::Makefile;
use AutoLaTeX::OS;
use AutoLaTeX::Locale;

#------------------------------------------------------
#
# FUNCTION: analyze the command line options and update the configuration accordingly
#
#------------------------------------------------------
sub analyzeCommandLineOptions(\%) {
	locDbg("Reading command line options");

	$_[0]->{'__private__'}{'config.command line'} = {};
	my $realcfg = $_[0];
	my $cfg = \%{$_[0]->{'__private__'}{'config.command line'}};
	my $debugLevel = 0;

	Getopt::Long::Configure ("bundling");
	if (!GetOptions(

		'auto!' => sub { $cfg->{'generation.generate images'} = ($_[1] ? 'yes' : 'no'); },

		'imgdirectory=s' => sub { $cfg->{'generation.image directory'} = $_[1]; },

		'createconfig:s' => \$realcfg->{'__private__'}{'action.create config file'},

		'createist' => \$realcfg->{'__private__'}{'action.create ist file'},

		'createmakefile' => \$realcfg->{'__private__'}{'action.create makefile'},

		'defaultist' => sub { 
					$cfg->{'generation.makeindex style'} = '@system';
				},

		'dvi' => sub { $cfg->{'generation.generation type'} = 'dvi'; },

		'exclude=s' =>	sub { 
					foreach my $module (split /\s*,\s*/,$_[1]) {
						$module =~ s/[^a-zA-Z0-9_+-]+//g;
						$cfg->{lc("$module").".include module"} = 'no';
					}
				},

		'file=s' => \$realcfg->{'__private__'}{'input.latex file'},

		'fixconfig:s' =>  sub	{
				$realcfg->{'__private__'}{'action.fix config file'} = $_[1];
				$realcfg->{'__private__'}{'action.fix config file'} = File::Spec->rel2abs($realcfg->{'__private__'}{'action.fix config file'}) if ($realcfg->{'__private__'}{'action.fix config file'});
			},

		'help|?' => sub { showManual(getAutoLaTeXDir(),"pod","autolatex.pod"); },

		'I=s@' => sub	{
					if (!$cfg->{'generation.translator include path'}) {
						$cfg->{'generation.translator include path'} = [];
					}
					push @{$cfg->{'generation.translator include path'}}, $_[1];
				},

		'include=s' =>	sub { 
					my $sep = getPathListSeparator();
					foreach my $module (split /\s*$sep\s*/,$_[1]) {
						$module =~ s/[^a-zA-Z0-9_+-]+//g;
						$cfg->{lc("$module").".include module"} = 'yes';
					}
				},

		'index:s' => sub	{ 
					if ($_[1]) {
						$cfg->{'generation.makeindex style'} = $_[1];
					}
					else {
						$cfg->{'generation.makeindex style'} = ['@detect','@none'];
					}
				},

		'noindex' => 	sub { 
					delete $cfg->{'generation.ignore ist detection'};
				},

		'noview' => sub { $cfg->{'viewer.view'} = 'no'; },

		'output=s' => \$realcfg->{'__private__'}{'output.makefile directory'},

		'pdf' => sub { $cfg->{'generation.generation type'} = 'pdf'; },

		'ps' => sub { $cfg->{'generation.generation type'} = 'ps'; },

		'pspdf' => sub { $cfg->{'generation.generation type'} = 'pspdf'; },

		'set=s%'  => sub { $cfg->{'generation.set'}{$_[1]} = $_[2]; },

		'v+' => \$debugLevel,

		'version' => sub { if (getAutoLaTeXLaunchingName() ne getAutoLaTeXName()) {
					locPrint("{} {} ({}) - {} plateform\n(c) 1998-2009 Stephane GALLAND <galland\@arakhne.org> (under GPL)\n",
						getAutoLaTeXLaunchingName(),
						getAutoLaTeXVersion(),
						getAutoLaTeXName(),
						getOperatingSystem());
				   }
				   else {
					locPrint("{} {} - {} plateform\n(c) 1998-2009 Stephane GALLAND <galland\@arakhne.org> (under GPL)\n",
						getAutoLaTeXLaunchingName(),
						getAutoLaTeXVersion(),
						getOperatingSystem());
				   }
				   exit(0); },

		'view:s' => sub { 
					$cfg->{'viewer.view'} = 'yes';
					if ($_[1]) {
						$cfg->{'viewer.viewer'} = $_[1];
					}
				},

		)) {
	  exit(1);
	}

	setDebugLevel($debugLevel);
}

#------------------------------------------------------
#
# FUNCTION: Seach for a TeX main file in the current directory
# 
# Requires $_[0]->{__private__}{output.directory}
# Set $_[0]->{__private__}{input.latex file}
#
#------------------------------------------------------
sub detectMainTeXFile(\%) {
	my $configuration = shift;
	local *DIR;
	opendir(*DIR,$configuration->{'__private__'}{'output.directory'}) or printErr($configuration->{'__private__'}{'output.directory'}.":","$!");
	my @texfiles = ();
	while (my $subfile = readdir(*DIR)) {
		if ($subfile =~ /\.tex$/i) {
			push @texfiles, "$subfile";
		}
	}
	closedir(*DIR);
	if (@texfiles==1) {
		my $basename = pop @texfiles;
		$configuration->{'__private__'}{'input.latex file'} = 
			File::Spec->catfile(
				$configuration->{'__private__'}{'output.directory'},
				$basename);
		locDbg("Detecting TeX file '{}'", $basename);
	}
	else {
		locDbg("Detecting several TeX files: {}",join(' ',@texfiles));
	}
}

#------------------------------------------------------
#
# FUNCTION: Main program
#
#------------------------------------------------------
sub mainProgram(;$) {
	my $exitOnError = shift;
	$exitOnError = 1 if (!defined($exitOnError));
	# Get system and user configurations
	my %configuration = readConfiguration();

	# Analyze and apply the command line
	analyzeCommandLineOptions(%configuration);
	# -- Bug fix: avoid the "No TeX file found" error message to be
	#             displayed when a non-generation action was requested
	#             on the command line
	if (($exitOnError)&&
	    ((exists $configuration{'__private__'}{'action.fix config file'})||
	     (exists $configuration{'__private__'}{'action.create config file'})||
	     (exists $configuration{'__private__'}{'action.create ist file'}))) {
		$exitOnError = 0;
	}

	# detect main TeX file
	$configuration{'__private__'}{'output.directory'} = File::Spec->curdir();
	$configuration{'__private__'}{'output.latex basename'} = undef;

	if (!$configuration{'__private__'}{'input.latex file'}) {
		detectMainTeXFile(%configuration);
	}

	# read project's configuration
	{
		my $projectConfigFilename = getProjectConfigFilename($configuration{'__private__'}{'output.directory'});
		if ( -f "$projectConfigFilename") {
			readConfigFile("$projectConfigFilename",%configuration);
			# Remove the main intput filename
			if (exists $configuration{'generation.main file'}) {
				if (!$configuration{'__private__'}{'input.latex file'}) {
					$configuration{'__private__'}{'input.latex file'} = basename($configuration{'generation.main file'});
					locDbg("Detecting TeX file from project's configuration: '{}'",$configuration{'__private__'}{'input.latex file'});
				}
				delete $configuration{'generation.main file'};
			}
			$configuration{'__private__'}{'input.project directory'} = dirname("$projectConfigFilename");
		}
	}

	# final project main file management
	if ($configuration{'__private__'}{'input.latex file'}) {
		# check its value
		if (-f $configuration{'__private__'}{'input.latex file'}) {
			$configuration{'__private__'}{'output.directory'} = dirname($configuration{'__private__'}{'input.latex file'});
			$configuration{'__private__'}{'output.latex basename'} = basename($configuration{'__private__'}{'input.latex file'});
			$configuration{'__private__'}{'output.latex basename'} =~ s/\.tex$//i;
		}
		elsif (-f $configuration{'__private__'}{'input.latex file'}.".tex") {
			$configuration{'__private__'}{'input.latex file'} .= ".tex";
			$configuration{'__private__'}{'output.directory'} = dirname($configuration{'__private__'}{'input.latex file'});
			$configuration{'__private__'}{'output.latex basename'} = basename($configuration{'__private__'}{'input.latex file'});
		}
		else {
			printErr($configuration{'__private__'}{'input.latex file'}.":", "$!");
		}
	}
	elsif ($exitOnError) {
		printErr(locGet("No LaTeX file found nor specified for the directory '{}'", $configuration{'__private__'}{'output.directory'}));
	}

	if ($configuration{'__private__'}{'input.latex file'}) {
		locDbg("Using TeX file '{}'",$configuration{'__private__'}{'input.latex file'});
	}

	# now apply the command line options into the configuration
	{
		printDbg("Applying command line options");
		if ($configuration{'__private__'}{'config.command line'}) {
			while (my ($k,$v) = each(%{$configuration{'__private__'}{'config.command line'}})) {
				if (isArray($v)) {
					if (!$configuration{"$k"}) {
						$configuration{"$k"} = $v;
					}
					elsif (isHash($configuration{"$k"})) {
						for(my $i=0; $i<$#{$v}; $i=$i+2) {
							$configuration{"$k"}{$v->[$i]} = $v->[$i+1];
						}
					}
					elsif (isArray($configuration{"$k"})) {
						push @{$configuration{"$k"}}, @{$v};
					}
					else {
						unshift @{$v}, $configuration{"$k"};
						$configuration{"$k"} = $v;
					}
				}
				elsif (isHash($v)) {
					if (!$configuration{"$k"}) {
						$configuration{"$k"} = $v;
					}
					elsif (isArray($configuration{"$k"})) {
						push @{$configuration{"$k"}}, @{$v};
					}
					elsif (isHash($configuration{"$k"})) {
						while (my ($key,$val) = each(%{$v})) {
							$configuration{"$k"}{$key} = $val;
						}
					}
					else {
						$v->{$configuration{"$k"}} = undef;
						$configuration{"$k"} = $v;
					}
				}
				else {
					$configuration{"$k"} = $v;
				}
			}		
			delete $configuration{'__private__'}{'config.command line'};
		}
	}

	# detect Makefile to write (if necessary)
	AutoLaTeX::Makefile::selectMakefileToOutput(%configuration);

	# check MakeIndex parameters
	if ($configuration{'generation.makeindex style'}) {
		if (!isArray($configuration{'generation.makeindex style'})) {
			$configuration{'generation.makeindex style'} = [$configuration{'generation.makeindex style'}];
		}
		foreach my $isttype (@{$configuration{'generation.makeindex style'}}) {
			if ($isttype) {
				if ($isttype eq '@detect') {
					# Seach for a MakeIndex style file in the current directory
					local *DIR;
					opendir(*DIR,$configuration{'__private__'}{'output.directory'}) or printErr($configuration{'__private__'}{'output.directory'}.":","$!");
					my @istfiles = ();
					while (my $subfile = readdir(*DIR)) {
						if ($subfile =~ /\.ist$/i) {
							push @istfiles, File::Spec->catfile(
							$configuration{'__private__'}{'output.directory'},
							"$subfile");
						}
					}
					closedir(*DIR);
					if (@istfiles==1) {
						$configuration{'__private__'}{'ouput.ist file'} = File::Spec->rel2abs(pop @istfiles);
						locDbg("Selecting project's style for MakeIndex: {}", $configuration{'__private__'}{'ouput.ist file'});
					}
					else {
						delete $configuration{'__private__'}{'ouput.ist file'};
						locDbg("Unable to selected a project's style for MakeIndex:", "no file or too many .ist files in directory", $configuration{'__private__'}{'output.directory'});
					}
				}
				elsif ($isttype eq '@system') {
					$configuration{'__private__'}{'ouput.ist file'} = getSystemISTFilename();
					locDbg("Selecting the system default style for MakeIndex");
				}
				elsif ($isttype eq '@none') {
					delete $configuration{'__private__'}{'ouput.ist file'};
					locDbg("Unselecting any style for MakeIndex");
				}

				if (($configuration{'__private__'}{'ouput.ist file'})&&
				    (-r $configuration{'__private__'}{'ouput.ist file'})) {
					last;
				}
				else {
					delete $configuration{'__private__'}{'ouput.ist file'};
				}
			}
		}
	}

	# Move the --set make in the private configuration
	if (exists $configuration{'generation.set'}{'make'}) {
		$configuration{'__private__'}{'gnu make'} = $configuration{'generation.set'}{'make'};
		delete $configuration{'generation.set'}{'make'};
	}
	removeUnsupportedMakefileVariables(%configuration);

	return %configuration;
}

1;
__END__
=back

=head1 BUG REPORT AND FEEDBACK

To report bugs, provide feedback, suggest new features, etc. visit the AutoLaTeX Project management page at <http://www.arakhne.org/autolatex/> or send email to the author at L<galland@arakhne.org>.

=head1 LICENSE

S<GNU Public License (GPL)>

=head1 COPYRIGHT

S<Copyright (c) 1998-07 Stéphane Galland E<lt>galland@arakhne.orgE<gt>>

=head1 SEE ALSO

L<autolatex-dev>
