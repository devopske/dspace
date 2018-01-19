##
# site.pp for DSpaceDirect
#
# This Puppet script does the following:
#  * Initializes the server (with default settings in Hiera)
#  * Installs all prerequisites
#  * Creates the Staff user accounts (configured in Hiera)
#  * Creates/Installs the DSpaceDirect sites (configured in Hiera)
#
# How does it work?
# -----------------
# 1. When this site.pp script is run, Puppet loads the proper Hiera Datastore config file(s)
#    from /etc/puppet/hieradata/ (as specified by /etc/puppet/hiera.yaml)
#      * hiera.yaml is configured to load the following (in order):
#           * [fqdn].yaml (hiera data matching FQDN of server)
#           * common.yaml (common/shared data)
#           * staff.yaml  (staff acct info)
# 2. Using that loaded Hiera data, Puppet will initialize the Server using the below code
#
# How to Run (i.e. tell Puppet to setup/install instances):
# ----------
#
#  sudo puppet apply site.pp -v [-l /path/to/logfile]
#
# How to Test (by overriding the "hostname" value that Puppet sees)
# -----------
#  sudo FACTER_hostname=testing puppet apply site.pp -v
#
#  # The above "FACTER_hostname=testing" setting tells Puppet to use the hostname of 'testing' 
#  # and therefore the 'hieradata/testing.yaml' config file would be used.
##

###################
# Initialize Server
###################
# Initialize server with all any Puppet classes
# This does an auto "include" of any classes listed under "classes" in the hieradata/*.yaml file(s)
# See: http://docs.puppetlabs.com/references/latest/function.html#hierainclude
hiera_include('classes')


# For Ubuntu 14.04, installing Java 8 requires a custom PPA
exec { "Add JDK 8 PPA Repository":
  command => "add-apt-repository ppa:openjdk-r/ppa && apt-get update",
  path    => "/usr/bin:/usr/sbin:/bin",
  unless  => "grep -o '^deb .*/openjdk-r/ppa/.*' /etc/apt/sources.list /etc/apt/sources.list.d/*",
}

->

# Tell puppet-server to install OpenJDK 8
###class {'java':
###  version => '8',
###}

###->

# DSpace needs prerequisites before it can be installed, so 'server' class needs loading first
Class['dspace']

# Ensure the Apache Proxy / Proxy AJP modules are present & enabled
# (DSpaceDirect will use these modules to forward requests from Apache to Tomcat)
#apache::module { ["proxy", "proxy_ajp"] :
#  ensure => "present",
#}

##########################
# Setup all Staff Accounts 
# (based on Hiera data configuration)
##########################
# Create the 'staff' group for our staff users (should exist by default on Ubuntu)
group { "staff":
  ensure => present,	
  gid    => 50,      # On Ubuntu, this is the default gid for this "staff" group
}

# These next few lines load the Hiera data configs and creates a new "server::user"
# for every site defined under "User_Accts" in the 'hieradata/staff.yaml' file.
# Concept borrowed from http://drewblessing.com/blog/-/blogs/puppet-hiera-implement-defined-resource-types-in-hiera

###$user_accts = hiera('User_Accts', {})         # First read the site configs under "User_Accts" (default to doing nothing, {}, if nothing is defined under "User_Accts")
###create_resources('server::user', $user_accts) # Then, create a new "server::user" for each account

# The above lines are the equivalent of having a separate "server::user" defined for EACH acct under "User_Accts" in the 
# hieradata/staff.yaml file, similar to this:
#
# server::user { $username:
#   email  => $email,
#   gid    => $gid,
#   uid    => $uid,
#   sudoer => $sudoer,
#   sshkey => $sshkey
# }


##############################
# Setup all DSpaceDirect sites 
# (based on Hiera data configuration)
##############################
# These next few lines load the Hiera data configs and creates a new "dspace::site"
# for every site defined under "DSpaceDirect_Sites" in the 'hieradata/[fqdn].yaml' file.

$dspacedirect_sites = hiera('DSpaceDirect_Sites', {})   # First read the site configs under "DSpaceDirect_Sites" (default to doing nothing, {}, if nothing is defined under "DSpaceDirect_Sites") 
create_resources('dspace::install', $dspacedirect_sites)   # Then, create a new "dspace::site" for each one


#owner
	dspace::owner { '$owner':
	  #gid    => 'dspace1',  # Primary OS group name / ID
	  groups => 'root', # Additional OS groups
	  sudoer => true,  # Whether to add acct as a sudoer
	}




	####dspace1 install
	dspace::install { "/home/${dspace::owner}/dspace" :


	}
