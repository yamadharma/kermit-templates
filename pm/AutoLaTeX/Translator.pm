# autolatex - Translator.pm
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

=pod

=head1 NAME

Translator.pm - Translator Utilities

=head1 DESCRIPTION

Permits to get translators and to resolve conflicts on them.

To use this library, type C<use AutoLaTeX::Translator;>.

=head1 FUNCTIONS

The provided functions are:

=over 4

=cut
package AutoLaTeX::Translator;

$VERSION = '5.1';
@ISA = ('Exporter');
@EXPORT = qw( &getLoadableTranslatorList &getTranslatorList &detectConflicts @ALL_LEVELS 
	      &makeTranslatorHumanReadable ) ;
@EXPORT_OK = qw();

use strict;

use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION @ALL_LEVELS);
use File::Spec;

use AutoLaTeX::Util;
use AutoLaTeX::Config;
use AutoLaTeX::Locale;

# Sorted list of the levels
our @ALL_LEVELS = ('system', 'user', 'project');

sub extractNameComponents($) {
	my $name = shift;
	if ($name =~ /^([a-zA-Z+-]+)2([a-zA-Z0-9-]+)(?:\+([a-zA-Z0-9+-]+))?(?:_(.*))?$/) {
		my $source = $1;
		my $target = $2;
		my $target2 = $3||'';
		my $variante = $4||'';
		my $osource = "$source";
		if ($target2) {
			if ($target2 ne 'tex') {
				$target .= "+$target2";
			}
			else {
				$source = "ltx.$source";
			}
		}
		return { 'name' => $name, 'full-source' => $source, 'source' => $osource, 'target' => $target, 'variante' => $variante };
	}
	return undef;
}

=pod

=item * makeTranslatorHumanReadable($)

Replies a human readable string that corresponds to the specified translator data

=cut
sub makeTranslatorHumanReadable($) {
	my $data = shift;
	if ($data->{'variante'}) {
		return locGet("Translate {} to {} with {} alternative",
					$data->{'full-source'},
					$data->{'target'},
					$data->{'variante'});
	}
	else {
		return locGet("Translate {} to {}",
					$data->{'full-source'},
					$data->{'target'});
	}
}

# $_[0]: Configuration
# $_[1]: Directory path
# $_[2]: List of included files
# $_[3]: boolean value that indicates if recursion if allowed
# $_[4]: boolean value that indicates the warning is allowed to be displayed
# $_[5]: boolean value that indicates if only included translators must be replied
# $_[6]: string that represents the configuration level
# Returns: nothing
sub getTranslatorFilesFrom(\%$\%$$$;$) {
	my $filename = $_[1];
	my $level = $_[6] || 'unknown';
	if (-d "$filename") {
		my @dirs = ( "$filename" );
		while (@dirs) {
			my $dirname = pop @dirs;
			locDbg("Get translator list from {}",$dirname);
			if (opendir(*DIR,"$dirname")) {
				while (my $file = readdir(*DIR)) {
					my $fullname = File::Spec->rel2abs(File::Spec->catfile("$dirname","$file"));
					if (($file ne File::Spec->curdir())&&
					    ($file ne File::Spec->updir())&&
					    (-d "$fullname")) {
						push @dirs, "$fullname" if ($_[3]);
					}
					elsif ($file =~ /^([a-zA-Z+-]+2[a-zA-Z0-9+-]+(?:_[a-zA-Z0-9_+-]+)?).*$/i) {
						my $scriptname = "$1";
						if ($_[5]) {
							$_[2]->{"$scriptname"} = extractNameComponents($scriptname);
							$_[2]->{"$scriptname"}{'human-readable'} = makeTranslatorHumanReadable($_[2]->{"$scriptname"});
							$_[2]->{"$scriptname"}{'file'} = "$fullname";
							$_[2]->{"$scriptname"}{'level'} = $level;
						}					
						else {
							$_[2]->{"$scriptname"} = "$fullname";
						}
					}
				}
				closedir(*DIR);
			}
			else {
				printWarn("$dirname:","$!");
			}
		}
	}
	elsif ($_[4]) {
		printWarn("$filename:","$!");
	}
	1;
}

# $_[0]: List of included files
# Returns: nothing
sub resolveConflicts(\%) {
	my %bysources = ();
	# The targets with "*+tex" are translated into sources "ltx.*"
	while (my ($trans,$transfile) = each (%{$_[0]})) {
		my $components = extractNameComponents($trans);
		if ($components) {
			if (!$bysources{$components->{'full-source'}}) {
				$bysources{$components->{'full-source'}} = [];
			}
			push @{$bysources{$components->{'full-source'}}}, { 
				'source' => $components->{'source'},
				'target' => $components->{'target'},
				'variante' => $components->{'variante'},
				'filename' => "$transfile" };
		}
	}

	while (my ($source,$trans) = each(%bysources)) {
		if (@{$trans}>1) {
			my $msg = '';
			my ($excludemsg,$excludename);
			foreach my $t (@{$trans}) {
				$msg .= ",\n" if ($msg);
				$msg .= makeTranslatorHumanReadable($t);
				if (!$excludename) {
					$excludename = $t->{'source'}."2".$t->{'target'};
					$excludename .= "_".$t->{'variante'} if ($t->{'variante'});
				}
				if (!$excludemsg) {
					$excludemsg = "[$excludename]\ninclude module = no\n";
				}
			}
			printErr(locGet("Several possibilities exist for generating a figure from a {} file:\n{}\n\nYou must specify which to include (resp. exclude) with --include (resp. --exclude).\n\nIt is recommended to update your {} file with the following configuration for each translator to exclude (example on the translator {}):\n\n{}\n",
				$source,
				$msg,
				getUserConfigFilename(),
				$excludename,
				$excludemsg));
		}
	}
	1;
}

=pod

=item B<detectConflicts(\%)>

Replies the list of the translators that are in conflict.

I<Parameters:>

=over 8

=item * List of translator pairs (translator name => hashtable)

=back

I<Returns:> a hashtable containing (level => hash of translator descriptions) pairs.

=cut
sub detectConflicts(\%) {
	die('first parameter of detectConflicts() is not a hash')
		unless (isHash($_[0]));
	my %bysources = ();
	# Build the list of included translators
	while (my ($name,$data) = each(%{$_[0]})) {
		# By default a module is included
		for(my $i=0; $i<@ALL_LEVELS; $i++) {
			my $level = $ALL_LEVELS[$i];
			if ($data->{'included'}{$level}) {
				$bysources{$level}{$data->{'full-source'}}{$data->{'name'}} = $data;
				# Propagate the inclusion to the following levels
				for(my $j=$i+1; $j<@ALL_LEVELS; $j++) {
					my $flevel = $ALL_LEVELS[$j];
					$bysources{$flevel}{$data->{'full-source'}}{$data->{'name'}} = $data;
				}
			}
			elsif (defined($data->{'included'}{$level})) {
				# Propagate the non inclusion to the following levels
				# This action cancels previous propagation of included translators
				for(my $j=$i; $j<@ALL_LEVELS; $j++) {
					my $flevel = $ALL_LEVELS[$j];
					if ($bysources{$flevel}{$data->{'full-source'}}) {
						delete $bysources{$flevel}{$data->{'full-source'}}{$data->{'name'}};
					}
				}
			}
			elsif ($i==0) {
				# By default a module is included
				# Propagate the inclusion to the following levels
				$bysources{$level}{$data->{'full-source'}}{$data->{'name'}} = $data;
				for(my $j=$i+1; $j<@ALL_LEVELS; $j++) {
					my $flevel = $ALL_LEVELS[$j];
					$bysources{$flevel}{$data->{'full-source'}}{$data->{'name'}} = $data;
				}
			}
		}
	}

	# Remove the translators that are not under conflict
	foreach my $level (@ALL_LEVELS) {
		foreach my $source (keys %{$bysources{$level}}) {
			my @keys = keys %{$bysources{$level}{$source}};
			if (@keys<=1) {
				delete $bysources{$level}{$source};
			}
		}
		unless ($bysources{$level}) {
			delete $bysources{$level};
		}
	}

	return %bysources;
}

=pod

=item B<getLoadableTranslatorList(\%)>

Replies the list of the translators that could be loaded.

I<Parameters:>

=over 8

=item * hashtable that contains the current configuration, and that will
be updating by this function.

=back

I<Returns:> a hashtable containing (translator name => translator file) pairs.

=cut
sub getLoadableTranslatorList(\%) {
	local *DIR;

	my %includes = ();

	# Load distribution modules
	my $filename = File::Spec->catfile(getAutoLaTeXDir(),"mkfiles");
	locDbg("Get translator list from {}",$filename);
	printDbgIndent();
	opendir(*DIR,"$filename")
		or printErr("$filename:","$!");
	while (my $file = readdir(*DIR)) {
		my $fullname = File::Spec->rel2abs(File::Spec->catfile("$filename","$file"));
		if (($file ne File::Spec->curdir())&&($file ne File::Spec->updir())&&
		    ($file ne 'MainVars.mk')&&($file ne 'MainRules.mk')&&($file =~ /^(.*)\.mk$/i)) {
			my $scriptname = "$1";
			if ((!exists $_[0]->{"$scriptname.include module"})||
			    (cfgBoolean($_[0]->{"$scriptname.include module"}))) {
				$includes{"$scriptname"} = "$fullname";
			}
			else {
				locDbg("Translator {} is ignored",$scriptname);
			}
		}
	}
	closedir(*DIR);
	printDbgUnindent();

	# Load user modules recursively from ~/.autolatex/translators
	getTranslatorFilesFrom(
		%{$_[0]},
		File::Spec->catfile(getUserConfigDirectory(),"translators"),
		%includes,
		1, # recursion
		0, # no warning
		0, # only included translators
		'user' # configuration level
		);

	# Load user modules non-recursively the paths specified inside the configurations
	if ($_[0]->{'generation.translator include path'}) {
		my @paths = ();
		if ((isArray($_[0]->{'generation.translator include path'}))||
		    (isHash($_[0]->{'generation.translator include path'}))) {
			@paths = @{$_[0]->{'generation.translator include path'}};
		}
		else  {
			push @paths, $_[0]->{'generation.translator include path'};
		}
		foreach my $path (@paths) {
			getTranslatorFilesFrom(
				%{$_[0]},
				"$path",
				%includes,
				0, # no recursion
				1, # warning
				0, # only included translators
				'user' # configuration level
			);
		}
	}

	resolveConflicts(%includes);

	return %includes;
}

=pod

=item B<getTranslatorList(\%;$)>

Replies the list of the translators and their status.

I<Parameters:>

=over 8

=item * hashtable that contains the configuration.

=item * recurse on user inclusion directories

=back

I<Returns:> a hashtable containing (translator name => { 'file' => translator file,
'level' => installation level } ) pairs.

=cut
sub getTranslatorList(\%;$) {
	local *DIR;
	die('first parameter of getTranslatorList() is not a hash')
		unless(isHash($_[0]));

	my $recurse = $_[1];
	$recurse = 1 unless (defined($recurse));

	my %translators = ();

	# Load distribution modules
	my $filename = File::Spec->catfile(getAutoLaTeXDir(),"mkfiles");
	locDbg("Get translator list from {}",$filename);
	printDbgIndent();
	opendir(*DIR,"$filename") or printErr("$filename:","$!");
	while (my $file = readdir(*DIR)) {
		my $fullname = File::Spec->rel2abs(File::Spec->catfile("$filename","$file"));
		if (($file ne File::Spec->curdir())&&($file ne File::Spec->updir())&&
		    ($file ne 'MainVars.mk')&&($file ne 'MainRules.mk')&&($file =~ /^(.*)\.mk$/i)) {
			my $scriptname = "$1";
			$translators{"$scriptname"} = extractNameComponents($scriptname);
			$translators{"$scriptname"}{'human-readable'} = makeTranslatorHumanReadable($translators{"$scriptname"});
			$translators{"$scriptname"}{'file'} = "$fullname";
			$translators{"$scriptname"}{'level'} = 'system';
		}
	}
	closedir(*DIR);
	printDbgUnindent();

	if ($recurse) {
		# Load user modules recursively from ~/.autolatex/translators
		getTranslatorFilesFrom(
			%{$_[0]},
			File::Spec->catfile(getUserConfigDirectory(),"translators"),
			%translators,
			1, # recursion
			0, # no warning
			1, # all included and not-included translators
			'user' # configuration level
			);

		# Load user modules non-recursively the paths specified inside the configurations
		if ($_[0]->{'generation.translator include path'}) {
			my @paths = ();
			if ((isArray($_[0]->{'generation.translator include path'}))||
			    (isHash($_[0]->{'generation.translator include path'}))) {
				@paths = @{$_[0]->{'generation.translator include path'}};
			}
			else  {
				push @paths, $_[0]->{'generation.translator include path'};
			}
			foreach my $path (@paths) {
				getTranslatorFilesFrom(
					%{$_[0]},
					"$path",
					%translators,
					0, # no recursion
					1, # warning
					1, # all included and not-included translators
					'user' # configuration level
				);
			}
		}
	} # if ($recurse)

	return %translators;
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
