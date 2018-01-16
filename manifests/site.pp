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
#$dspacedirect_sites = hiera('DSpaceDirect_Sites',{})
#$dspacedirect_sites = hiera_hash('DSpaceDirect_Sites', {})   # First read the site configs under "DSpaceDirect_Sites" (default to doing nothing, {}, if nothing is defined under "DSpaceDirect_Sites") 
#create_resources('dspace', $dspacedirect_sites)   # Then, create a new "dspace::site" for each one


#class { 'dspace':}

#owner
dspace::owner { '$owner':
  #gid    => 'dspace1',  # Primary OS group name / ID
  groups => 'root', # Additional OS groups
  sudoer => true,  # Whether to add acct as a sudoer
}

define dspace::site(
    $site_name,
    $site,
    $version,
    $owner, 
    $db_name, 
    $db_owner,   
    $db_owner_passwd,
    $tomcat_port){

$dspacedirect_sites = hiera('DSpaceDirect_Sites',{})
#$dspacedirect_sites = hiera_hash('DSpaceDirect_Sites', {})   # First read the site configs under "DSpaceDirect_Sites" (default to doing nothing, {}, if nothing is defined under "DSpaceDirect_Sites") 
create_resources('dspace::site', $dspacedirect_sites)   # Then, create a new "dspace::site" for each one

# for debug output on the puppet master
  notice("--------------------------------------------------------------------------")
  notice("------------This is to notify us if there is something:$site_name---------")
  notice("--------------------------------------------------------------------------")
  

####dspace1 install
dspace::install { "/home/${dspace::owner}/dspace" :

}

}
