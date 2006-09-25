#########################################################################
#  OpenKore - RMD-160 hashing algorithm
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#########################################################################
##
# MODULE DESCRIPTION: RMD-160 hashing algorithm
#
# This is an implementation of
# <a href="http://en.wikipedia.org/wiki/RIPEMD-160">RMD-160</a>.
package Utils::RMD160;

use strict;
use XSTools;
use Exporter;
use base qw(Exporter);

our @EXPORT_OK = qw(rmd160 rmd160_hex);

XSTools::bootModule('Utils::RMD160');

##
# Bytes Utils::RMD160::rmd160(Bytes data)
# data: The data to calculate the hash for.
# Returns: An RMD-160 hash, in raw bytes.
# Ensures: defined(result)
#
# Calculate the RMD-160 hash for the given data.
#
# This symbol is exportable.
sub rmd160 {
	my $rmd = new Utils::RMD160();
	$rmd->add($_[0]);
	return $rmd->finalize();
}

##
# String Utils::RMD160::rmd160_hex(Bytes data)
# data: The data to calculate the hash for.
# Returns: An RMD-160 hash as hexadecimal string.
# Ensures: defined(result)
#
# Calculate the RMD-160 hash for the given data.
#
# This symbol is exportable.
sub rmd160_hex {
	return unpack("H*", &rmd160);
}

1;
