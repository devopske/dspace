# Class: dspace
#
# This class does the following:
# - installs pre-requisites for DSpace (Java, Maven, Ant, Tomcat)
#
# Tested on:
# - Ubuntu 16.04
#
# Parameters:
# - $java_version       => Version of OpenJDK to install (default '8')
# - $owner              => OS Owner of DSpace (account must exist or be created by dspace::owner)
# - $group              => OS Group of DSpace owner
# - $src_dir            => Location where DSpace source should be kept (defaults to the home directory of $owner at ~/dspace-src)
# - $install_dir        => Location where DSpace instance should be installed (defaults to $name)
# - $installer_dir_name => Name of directory where the Ant installer is built to (via Maven).
# - $git_repo           => Git repository to pull DSpace source from. Defaults to DSpace/DSpace in GitHub
# - $git_branch         => Git branch to build DSpace from. Defaults to "master".
# - $mvn_params         => Any build params passed to Maven.
# - $postgresql_version => Version of PostgreSQL to install (e.g. '9.5', etc)
# - $db_name            => Name of database to create for DSpace (default=$name)
# - $db_admin_passwd    => Password for the 'postgres' user who owns Postgres (default=undef, i.e. no password)
# - $db_owner           => Name of database user to create for DSpace (default='dspace')
# - $db_owner_passwd    => Password of DSpace database user (default='dspace')
# - $db_port            => PostgreSQL port (default=5432)
# - $db_locale          => Locale for PostgreSQL (default='en_US.UTF-8')
# - $tomcat_package     => Tomcat package to install/use (e.g. 'tomcat8', etc)
# - $tomcat_port        => Port this Tomcat instance runs on
# - $tomcat_ajp_port    => AJP port for Tomcat. Only useful to set if using Apache webserver + Tomcat (see apache_site.pp)
# - $catalina_opts      => Options to pass to Tomcat (default='-Djava.awt.headless=true -Dfile.encoding=UTF-8 -Xmx2048m -Xms1024m -XX:MaxPermSize=256m -XX:+UseConcMarkSweepGC')
# - $admin_firstname    => First Name of the created default DSpace Administrator account.
# - $admin_lastname     => Last Name of the created default DSpace Administrator account.
# - $admin_email        => Email of the created default DSpace Administrator account.
# - $admin_passwd       => Initial Password of the created default DSpace Administrator account.
# - $admin_language     => Language of the created default DSpace Administrator account.
# - $handle_prefix      => Handle Prefix to use for this site (default = 123456789)
#
# Sample Usage:
# include dspace
#
#include tomcat
define dspace::setup (
  $java_version,
  $owner,
  $username,
  $src_dir= "/home/${owner}/dspace-src",
  $version,
  $git_branch,
  $dir_mode = 0750,
  $catalina_base,
  $catalina_home,
  $db_name,
  $db_owner,
  $db_owner_passwd,
  $git_repo  = "git@github.com:duraspace/dspacedirect.git",
  $git_src_tag = "dspace-${version}",
  $source_url,
  $group = $owner,
  $service_name = undef,
  $url = $name,
  $tomcat_port,
  $tomcat_port = undef,
  $tomcat_shutdown_port = undef,
  $tomcat_ajp_port = undef,
  #$site_name = "DSpaceDirect",
  $tomcat_opts = "-server -Xms768M -Xmx1024M -XX:PermSize=96M -XX:MaxPermSize=192M -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/tmp/${username}-tomcat.hprof -Dfile.encoding=UTF-8",
  $tomcat_webapps       = {
                           "/home/${username}/dspace/webapps/xmlui"   => { path => 'ROOT' },
                           "/home/${username}/dspace/webapps/oai"     => { path => 'oai' },
                           "/home/${username}/dspace/webapps/rest"    => { path => 'rest' },
                           "/home/${username}/dspace/webapps/solr"    => { path => 'solr' },
                           "/home/${username}/dspace/webapps/sword"   => { path => 'sword' },
                           "/home/${username}/dspace/webapps/swordv2" => { path => 'swordv2' },
                           }

)
{
    
  #owner
  dspace::owner { "${owner}":
  gid    => $owner,  # Primary OS group name / ID
  groups => [root,$username], # Additional OS groups
  sudoer => true,  # Whether to add acct as a sudoer
  }


   ##dspace1 install
  dspace::install { "/home/${owner}/dspace":
  src_dir    => $src_dir,
  }
  
 #} 
  ##########
  # Setup Tomcat Instance
  ##########
 # Create a new Tomcat instance owned by this user
         # (NOTE: Tomcat ports are defined in ~/setenv.sh below)
         tomcat::instance { $url :
           #ensure   => present,
           catalina_home => $catalina_home,
           source_url   => $source_url,
           #user    => "${username}",
           #dir      => $tomcat_dir,
           #webapps  => $tomcat_webapps,
         }
  
  #########
  # Create / Enable Service Script
  #########
  # Create DSpaceDirect service script to start/stop Tomcat & PostgreSQL
     /* ==
      file { "/home/${username}/dspacedirect":
           ensure  => 'file',
           mode    => 0755,
           owner   => $username,
           group   => $username,
           content => template("dspace/tomcat-systemd.erb"),
           #require => File["/home/${username}/setenv.sh"],
         }
          notify { "username is: ${username}":}
         # Link to above service script from /etc/init.d
         file { "/etc/systemd/system/${username}.service":
           ensure  => 'link',
           target  => "/home/${username}/dspacedirect",
           owner   => root,
           group   => root,
           require => File["/home/${username}/dspacedirect"],
         }
         =====*/
         
         
         #####################
         file { "/etc/systemd/system/${username}.service":
            ensure  => 'file',
            owner   => root,
            group   => root,
            content => template("dspace/tomcat-systemd.erb"),
            mode    => 0644,
         }

         #####################
         # . USING INITD .   #
         # . UBUNTU 14.04    #
         #####################
         # Enable this new service script and ensure it starts on boot
         #service { "${username}" :
         #  ensure     => running,
         #  enable     => true,		# start service on boot
         #  hasstatus  => false,		# service has a 'status' command
         #  hasrestart => true,		# service has a 'restart' command
         #  #use_jsvc => false,
         #  #use_init => true,
         #  name => $username,
         #  require    => File["/etc/systemd/system/${username}.service"],
         #}
         
         #####################
         # . USING SYSTEMD . #
         # . UBUNTU 16.04    #
         #####################
         # Enable this new service script and ensure it starts on boot
         tomcat::service { "${username}":
            service_name  => $username,
            #service_enable     => true,
            catalina_home => $catalina_home,
            catalina_base => $catalina_base,
            use_init      => true,
        }
      
  
 
}
  
