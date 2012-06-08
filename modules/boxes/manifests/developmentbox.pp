class boxes::developmentbox {

    # the update
    Exec { path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'], logoutput => true }
    include apt::update
    #Package [require => Exec['apt_update']]
    Exec["apt_update"] -> Package <| |>

    # put here your tools
    $package_list = ['git-flow']

    package {$package_list:
        ensure => present
    }

    # your stuff here
    
}