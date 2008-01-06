# autolatex - OS.pm
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

OS.pm - Operating System

=head1 DESCRIPTION

Identify the current operating system.

To use this library, type C<use AutoLaTeX::OS;>.

=head1 FUNCTIONS

The provided functions are:

=over 4

=cut
package AutoLaTeX::OS;

$VERSION = '5.0';
@ISA = ('Exporter');
@EXPORT = qw( &getPathListSeparator &getOperatingSystem &getSupportedOperatingSystems ) ;
@EXPORT_OK = qw();

use strict;
use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);
use Config; # Perl configuration

my %operatingsystem = 
             (MacOS   => 'Mac',
              MSWin32 => 'Win32',
              os2     => 'OS2',
              VMS     => 'VMS',
              epoc    => 'Epoc',
              NetWare => 'Win32',
              symbian => 'Win32',
              dos     => 'OS2',
              cygwin  => 'Cygwin');

=pod

=item B<getPathListSeparator()>

Replies the separator of paths inside a path list.

I<Returns:> the separator.

=cut
sub getPathListSeparator() {
	return $Config{'path_sep'} || ':';
}

=pod

=item B<getOperatingSystem()>

Replies the name of the current operating system.

I<Returns:> the name.

=cut
sub getOperatingSystem() {
	return $operatingsystem{$^O} || 'Unix';
}

=pod

=item B<getSupportedOperatingSystems()>

Replies all the names of the supported operating systems.

I<Returns:> the list of operating system's names.

=cut
sub getSupportedOperatingSystems() {
	my %list = ();
	foreach my $v (values %operatingsystem) {
		$list{"$v"} = 1;
	}
	return keys %list;
}

sub expandShellCharsOnUnix(@) {
	my $t = shift;
	if ($t) {
		my @parts = File::Spec->splitdir("$t");
		foreach my $e (@parts) {
			if ($e eq '~') {
				$e = $ENV{'HOME'};
			}
			elsif ($e =~ /^~([a-zA-Z_][a-zA-Z_0-9]*)$/) {
				my @p = File::Spec->split($ENV{'HOME'});
				pop @p;
				$e = File::Spec->catdir(@p);
			}
		}
		$t = File::Spec->catfile(@parts);
		$t =~ s/\$([a-zA-Z_][a-zA-Z_0-9]*)/$ENV{$1}/g;
		$t =~ s/\$\{([a-zA-Z_][a-zA-Z_0-9]*)\}/$ENV{$1}/g;
		$t =~ s/\$\(([a-zA-Z_][a-zA-Z_0-9]*)\)/$ENV{$1}/g;
	}
	return $t;
}

sub expandShellCharsOnWindows(@) {
	my $t = shift;
	if ($t) {
		$t =~ s/\%{1,2}([a-zA-Z_][a-zA-Z_0-9]*)/$ENV{$1}/g;
		$t =~ s/\%{1,2}\{([a-zA-Z_][a-zA-Z_0-9]*)\}/$ENV{$1}/g;
		$t =~ s/\%{1,2}\(([a-zA-Z_][a-zA-Z_0-9]*)\)/$ENV{$1}/g;
	}
	return $t;
}

=pod

=item B<expandShellChars($)>

Expand the specified value with the Shell metacommands.

I<Parameters:>

=over 8

=item * the string to expand.

=back

I<Returns:> the result of the epxansion.

=cut
sub expandShellChars($) {
	my $operatingsystem = getOperatingSystem();
	if (("$operatingsystem" eq 'Unix')||(("$operatingsystem" eq 'Cygwin'))) {
		return expandShellCharsOnUnix(@_);
	}
	else {
		return expandShellCharsOnWindows(@_);
	}
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
