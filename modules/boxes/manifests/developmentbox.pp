class boxes::developmentbox {

    # the update
    Exec { path => ['/usr/local/bin', '/opt/local/bin', '/usr/bin', '/usr/sbin', '/bin', '/sbin'], logoutput => true }
    include apt::update
    #Package [require => Exec['apt_update']]
    Exec["apt_update"] -> Package <| |>

    # put here your tools
    # git-flow comes from squeeze-backports
    $package_list = ['vim', 'aptitude', 'sudo', 'mc', 'screen', 'git-flow']

    package {$package_list:
        ensure => present
    }

    # your stuff here
}
