#########################################################################
#  OpenKore - Plugin system
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#########################################################################
##
# MODULE DESCRIPTION: Plugin system
#
# A plugin is a file with executable code. It is not part of Kore, and can
# be loaded by Kore at runtime. A plugin can add new features to Kore or
# modify existing behavior (using hooks).
#
# This module provides an interface for handling plugins.
#
# NOTE: Do not confuse plugins with modules! See Modules.pm for more information.

package Plugins;

use strict;
no strict 'refs';
use warnings;
use Exporter;
use Settings;
use Log;

our @ISA = qw(Exporter);
our @EXPORT_OK = qw(loadAll load unload register registered);

our @plugins;


##
# Plugins::loadAll()
#
# Loads all plugins from the plugins folder. Plugins must have the .pl extension.
sub loadAll {
	if (!opendir(DIR, $Settings::plugins_folder)) {
		Log::error("Unable to load plugins from folder $Settings::plugins_folder ($!)\n", "plugins");
		return 0;
	}
	my @plugins = grep { /\.pl$/ } readdir(DIR);
	closedir(DIR);

	foreach my $plugin (@plugins) {
		load("$Settings::plugins_folder/$plugin");
	}
	return 1;
}


##
# Plugins::load(file)
# file: The filename of a plugin.
# Returns: 1 on success, 0 on failure.
#
# Loads a plugin.
sub load {
	my $file = shift;
	Log::message("Loading plugin $file...\n", "plugins");
	if (! do $file) {
		Log::error("Unable to load plugin $file: $@\n", "plugins");
		return 0;
	}
	return 1;
}


##
# Plugins::unload(name)
# name: The name of the plugin to unload.
# Returns: 1 if the plugin has been successfully unloaded, 0 if the plugin isn't registered.
#
# Unloads a registered plugin.
sub unload {
	my $name = shift;
	my $i = 0;
	foreach my $plugin (@plugins) {
		if ($plugin->{'name'} eq $name) {
			$plugin->{'unload_callback'}->();
			undef %{$plugin};
			delete $plugins[$i];
			return 1;
		}
		$i++;
	}
	return 0;
}


##
# Plugins::register(name, description, unload_callback, reload_callback)
# name: The plugin's name.
# description: A short one-line description of the plugin.
# unload_callback: Reference to a function that will be called when the plugin is being unloaded.
# reload_callback: Reference to a function that will be called when the plugin is being reloaded.
# Returns: 1 if the plugin has been successfully registered, 0 if a plugin with the same name is already registered.
#
# Plugins should call this function when they are loaded. This function registers
# the plugin in the plugin database. Registered plugins can be unloaded by the user.
sub register {
	my %plugin_info = ();
	my $name = shift;

	return 0 if registered($name);

	$plugin_info{'name'} = $name;
	$plugin_info{'description'} = shift;
	$plugin_info{'unload_callback'} = shift;
	$plugin_info{'reload_callback'} = shift;
	push @plugins, \%plugin_info;
	return 1;
}


##
# Plugins::registered(name)
# name: The plugin's name.
# Returns: 1 if the plugin's registered, 0 if it isn't.
#
# Checks whether a plugin is registered.
sub registered {
	my $name = shift;
	foreach (@plugins) {
		return 1 if ($_->{'name'} eq $name);
	}
	return 0;
}


return 1;
