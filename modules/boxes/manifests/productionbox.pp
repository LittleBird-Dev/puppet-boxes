class boxes::productionbox {

    include littlebird::params

    # the update
    Exec { path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'], logoutput => true }
    include apt::update
    #Package [require => Exec['apt_update']]
    Exec["apt_update"] -> Package <| |>

    # your stuff here
    
    $projectname = "phoenix-dev"
    $owner = "vagrant"
    $group = "www-data"
    
    # download from git into tempdir
	class{ 'littlebird::download':
        projectname => $projectname,
        downloadurl => $littlebird::params::download_url,
    }
    
    # copy from tempdir to installdir and set appropriate fole rigths
    class{ 'littlebird::copy':
        projectname => $projectname,
        installdir => $littlebird::params::install_dir,
    }
    
    $timezone='Europe/Berlin'
    
    # update Timezone php apache
    augeas{"Set PHPTimezone_apache" :
        context => "/files/etc/php5/apache2/php.ini/DATE",
        changes => "set date.timezone $timezone",
    }
    
    # update Timezone php cli
    augeas{"Set PHPTimezone_phpcli" :
        context => "/files/etc/php5/cli/php.ini/DATE",
        changes => "set date.timezone $timezone",
    }
    
    # update short_open_tag php cli
    augeas{"Set PHPshort_open_tag_phpcli" :
        context => "/files/etc/php5/cli/php.ini/PHP",
        changes => "set short_open_tag Off",
    }
    
    # update short_open_tag php apache
    augeas{"Set PHPshort_open_tag_phpapache" :
        context => "/files/etc/php5/apache2/php.ini/PHP",
        changes => "set short_open_tag Off",
    }
    
    apache::vhost { "default":
      port => '80',
      #servername => 'littlebird',
      priority => '0',
      serveraliases => 'littlebird',
      configure_firewall => false,
      docroot => "$littlebird::params::install_dir/$projectname/web",
      template => 'apache/vhost-default.conf.erb',
      require => Class["littlebird::copy"],
      vhost_name => '*',
      options => "Indexes FollowSymLinks MultiViews"
    }
    
    # change owership of installdir to $owner
    exec { "set $projectname owner":
		command => "chown -R $owner:$group $littlebird::params::install_dir/$projectname",
        user => root,
        cwd => "$littlebird::params::install_dir/$projectname",
        logoutput => true,
	}
    
    # change group of installdir to $group
    exec { "set $projectname mod":
		command => "chmod -R 1775 $littlebird::params::install_dir/$projectname",
        user => root,
        cwd => "$littlebird::params::install_dir/$projectname",
        logoutput => true,
	}
    
    Class["littlebird::download"] -> Class["littlebird::copy"] -> Exec["set $projectname owner"] -> Exec["set $projectname mod"] -> Class["apache"]
}