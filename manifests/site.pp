hiera_include('classes')

# DSpace needs prerequisites before it can be installed, so 'server' class needs loading first
#Class['server'] -> Class['dspace']

##############################
# Setup all DSpaceDirect sites 
# (based on Hiera data configuration)
##############################
# These next few lines load the Hiera data configs and creates a new "dspace::site"
# for every site defined under "DSpaceDirect_Sites" in the 'hieradata/[fqdn].yaml' file.
# Create a hash from Hiera Data with variable values

#class { 'dspace':}
Class['dspace']

$dspacedirect_sites = hiera('DSpaceDirect_Sites', {})   # First read the site configs under "DSpaceDirect_Sites" (default to doing nothing,{}, if nothing is defined under "DSpaceDirect_Sites")
notify { "The Hash values are: ${dspacedirect_sites}": }
create_resources('dspace::init', $dspacedirect_sites)   # Then, create a new "dspace::site" for each one

