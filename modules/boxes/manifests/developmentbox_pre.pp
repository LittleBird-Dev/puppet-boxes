class boxes::developmentbox {

    include littlebird::params
    $projectname = "phoenix-dev"

    # the update
    Exec { path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'], logoutput => true }
    include apt::update
    #Package [require => Exec['apt_update']]
    Exec["apt_update"] -> Package <| |>

    # put here your tools
    $package_list = ['vim', 'aptitude', 'sudo', 'mc', 'screen', 'zsh']

    package {$package_list:
        ensure => present
    }

    # your stuff here
    
    # download composer
    class {"composer":
        targetdir => "$littlebird::params::install_dir/$projectname",
    }
      
    # führe composer install aus
	exec { "install composer":
        command => "php composer.phar",
        require =>[ 
            Class["composer"],
        ],
        user => root,
        logoutput => 'on_failure',
        cwd => "$littlebird::params::install_dir/$projectname",
        timeout => 0,
	}
    
    package {"php5-xdebug":
        ensure => present,
    }
    
    $version = "stable"
    class{ 'nodejs':
        version => $version,
    }
    
    $packages = ["zombie"]
    # install nodejs packages
    installnodejspackage{$packages:}
    
    package {"rubygems1.8":
        ensure => present,
    }
    
    $gems = ['compass','sass']
    installgems{$gems:}
    
#    define ssh::user($user = "${name}", $home = "/home/${name}") {
#    
#      User[$user] -> File[$home] -> file { "$home/.ssh/":
#        ensure => directory,
#      } -> file {
#        ensure => present,
#        content => templates("ssh/user/known_hosts.erb"),
#        owner => $user,
#        mode => "0420"
#      }
#    }

    Class["composer"] -> Exec["install composer"] 
}

define installnodejspackage($log = 'on_failure'){
    exec { "install $name":
        command     => "npm install $name",
        require     => Class["nodejs"],
        user        => root,
        logoutput   => $log,
        creates     => "/usr/local/bin/node_modules/$name",
        cwd         => "/usr/local/bin/",
    }
}

define installgems($log = 'on_failure'){
    exec { "install $name":
		command     => "gem install $name",
        user        => root,
        logoutput   => $log,
        creates     => "/var/lib/gems/1.8/bin/$name",
        cwd         => "/usr/bin/",
        require     => Package["rubygems1.8"],
	}
}