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
  $site_name = "${title}",
  $java_version,
  $db_endpoint= "dspacepuppet.crmamqzflhj7.eu-west-1.rds.amazonaws.com",
  $PGPASSWORD="${db_passwd}",
  $owner,
  $username,
  $src_dir= "/home/${owner}/dspace-src",
  $version,
  $git_branch,
  $dir_mode = 0750,
  $catalina_base,
  $catalina_home,
  $tomcat_port = undef,
  $tomcat_shutdown_port = undef,
  $tomcat_ajp_port = undef,
  $db_name,
  $db_user,
  $db_passwd,
  $db_port,
  $git_repo  = "https://github.com/DSpace/DSpace.git",
  $git_src_tag = "dspace-${version}",
  $source_url,
  $group = $owner,
  $service_name = undef,
  $url = $name,
  $ajp_port = undef,
  #$site_name = "DSpaceDirect",
  $tomcat_opts = "-server -Xms768M -Xmx1024M -XX:PermSize=96M -XX:MaxPermSize=192M -XX:+UseConcMarkSweepGC -XX:+CMSParallelRemarkEnabled -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/var/tmp/${username}-tomcat.hprof -Dfile.encoding=UTF-8",
 # DSpace Admin Account settings
  $admin_firstname = undef,
  $admin_lastname = undef,
  $admin_email = undef,
  $admin_passwd = undef,
  $admin_language = 'en',

)
  {
    
  ######################
  # . Acccount owner . #
  #######################
  dspace::owner { "${owner}":
  gid    => $owner,  # Primary OS group name / ID
  groups => [root,$username], # Additional OS groups
  sudoer => true,  # Whether to add acct as a sudoer
  }
  
  ##########################
  # . CREATE DATABASE .    #
  ##########################
  
 exec { 'create database':
   #user   => "dspacepuppet",
   environment => ["PGPASSWORD=${db_passwd}"],
   command => "psql --host=${db_endpoint} --port=5432  --username=${db_user} --command='CREATE DATABASE ${db_name}'",
   path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
 }

 
  #####################
  #   DSPACE install .#
  #####################
  dspace::install { "/home/${owner}/dspace":
  src_dir    => $src_dir,
  git_branch => $git_branch,
  }
  
 #} 
  

  #########################
  # Setup Tomcat Instance
  ##########################
  #Create a new Tomcat instance owned by this user
  # (NOTE: Tomcat ports are defined in ~/setenv.sh below)
         tomcat::instance { $url :
           #ensure   => present,
           catalina_home => $catalina_home,
           source_url   => $source_url,
           #user    => "${username}",
           #dir      => $tomcat_dir,
           #webapps  => $tomcat_webapps,
         }
         
  #######################################
  # . Set Dspace WebApps on Tomcat .    #
  #######################################
 #Default 
 tomcat::config::server::context {"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/xmlui",
        parent_host => "localhost",
        additional_attributes => {'path'=>'/'},
      }
  /*    
   #2
  tomcat::config::server::context{"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/oai",
        parent_host => "localhost",
        additional_attributes => {'path'=>'oai'},
      }
 
  #3
 tomcat::config::server::context{"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/jspui",
        parent_host => "localhost",
        additional_attributes => {'path'=>'jspui'},
      }
 
  #4
  tomcat::config::server::context{"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/rdf",
        parent_host => "localhost",
        additional_attributes => {'path'=>'rdf'},
      }
  #5
  tomcat::config::server::context{"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/rest",
        parent_host => "localhost",
        additional_attributes => {'path'=>'rest'},
      }
  #6
  tomcat::config::server::context{"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/solr",
        parent_host => "localhost",
        additional_attributes => {'path'=>'solr'},
      }
  #7
  tomcat::config::server::context{"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/sword",
        parent_host => "localhost",
        additional_attributes => {'path'=>'sword'},
      }
  #8
  tomcat::config::server::context{"${title}":
        catalina_base => $catalina_base,
        context_ensure => 'present',
        doc_base => "/home/${owner}/dspace/webapps/swordv2",
        parent_host => "localhost",
        additional_attributes => {'path'=>'swordv2'},
      }
 
  ######################################################
  #  SET/Change tomcat's server and HTTP/AJP connectors
  #######################################################
  tomcat::config::server { "${owner}":
   catalina_base => $catalina_base,
   port          => $tomcat_shutdown_port,
  }

  tomcat::config::server::connector { "${owner}-http":
   catalina_base         => $catalina_base,
   port                  => $tomcat_port,
   protocol              => 'HTTP/1.1',
   purge_connectors      => true,
   additional_attributes => {
    'redirectPort' => '8443'
   },
  }

  tomcat::config::server::connector { "${owner}-ajp":
   catalina_base         => $catalina_base,
   port                  => $tomcat_ajp_port,
   protocol              => 'AJP/1.3',
   purge_connectors      => true,
   additional_attributes => {
    'redirectPort' => '8443'
  },
  } */
  
  ####################################
  # Setup Apache Redirect to Tomcat  #
  ####################################
  notify { "The Hash values are: ${site_name}": }
         # Create a new Apache vhost (site) which will redirect (via AJP)
         # requests to the Tomcat instance created above.
         # Also installs/configures mod_shib when Shibboleth is enabled. 
         dspace::apache_site { $site_name :
           ensure           => present,
           tomcat_ajp_port         => $tomcat_ajp_port,
           #ssl_cert_file    => $ssl_cert_file,
           #ssl_key_file     => $ssl_key_file,
           #ssl_chain_file   => $ssl_chain_file,
           #shibboleth       => $shibboleth,
           #shibboleth_appId => $shibboleth_appId,
         }
         
         
  
  #################################
  # Create / Enable Service Script
  ##################################
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
  
