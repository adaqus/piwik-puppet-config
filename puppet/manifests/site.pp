node 'piwik.local' {
    
    file_line { 'append_restricted_src_1':
            path => '/etc/apt/sources.list',
            match => '^deb http\:\/\/archive.ubuntu.com/ubuntu trusty main$',
            line => 'deb http://archive.ubuntu.com/ubuntu trusty main multiverse'
    }
    file_line { 'append_restricted_src_2':
            path => '/etc/apt/sources.list',
            match => '^deb-src http\:\/\/archive.ubuntu.com/ubuntu trusty main$',
            line => 'deb-src http://archive.ubuntu.com/ubuntu trusty main multiverse'
    }
    file_line { 'append_restricted_src_3':
            path => '/etc/apt/sources.list',
            match => '^deb http\:\/\/archive.ubuntu.com/ubuntu trusty-updates main$',
            line => 'deb http://archive.ubuntu.com/ubuntu trusty-updates main multiverse'
    }
    file_line { 'append_restricted_src_4':
            path => '/etc/apt/sources.list',
            match => '^deb-src http\:\/\/archive.ubuntu.com/ubuntu trusty-updates main$',
            line => 'deb-src http://archive.ubuntu.com/ubuntu trusty-updates main multiverse'
    }

    exec { 'apt_update':
            command => 'apt-get update',
            path => '/usr/local/bin/:/usr/bin/:/bin/:/usr/local/sbin/:/usr/sbin/:/sbin/'
    }

    include git

    class { 'mysql::server':
            root_password => 'qwezxc123' 
    }
    include mysql::bindings::php

    class { 'apache':
            mpm_module => 'prefork',
            default_vhost => false,
            group => 'vagrant',
            user => 'vagrant'
    }

    include apache
    include apache::mod::php

    class { 'php': }

    apache::vhost { 'piwik.local':
            port => '80',
            docroot => '/var/www/piwik',
    }
    apache::vhost { 'piwik.local8080':
            port => '8080',         
            docroot => '/var/www/piwik',
    }

    file { '/var/www':
            ensure => directory,
    }

    file { '/var/www/piwik':
            ensure => link,
            target => '/vagrant'
    }

    exec { 'corefonts_install':
            command => 'apt-get install --yes ttf-mscorefonts-installer',
            path => '/usr/local/bin/:/usr/bin/:/bin/:/usr/local/sbin/:/usr/sbin/:/sbin/'
    }
    exec { 'imagemagick_install':
            command => 'apt-get install --yes imagemagick',
            path => '/usr/local/bin/:/usr/bin/:/bin/:/usr/local/sbin/:/usr/sbin/:/sbin/'
    }

    php::module { "imagick": }
    php::module { "curl": }
    php::module { "mysql": }
    php::module { "gd": }
    
    file_line { 'always_populate_raw_post_data':
            path => '/etc/php5/apache2/php.ini',
            line => 'always_populate_raw_post_data=-1'
    }

    # na pewno się wywali na czymś innym niż debian
    php::module { "dev": }

    include composer

    class { '::phantomjs':
            package_update => true,
            install_dir => '/usr/local/bin',
            source_dir => '/opt',
            timeout => 300
    }

    # "Realize" the firewall rule
    #Firewall <| |>
}
