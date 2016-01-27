
Exec {
    path => '/bin/:/usr/bin:/sbin:/usr/sbin'
}

exec { 'apt-get update':
    refreshonly => true
}
#exec { 'install_ejabberd':
#    command => '/etc/puppet/files/ejabberd-15.11-linux-x86_64-installer.run --mode unattended --admin admin --adminpw 12345 --ejabberddomain myejabberd --installdir /opt/ejabberd --hostname myejabberd'
#}
package { 'ejabberd':
    ensure      => installed,
    provider    => dpkg,
    # in a real world environment the package file should located on a package or at least a file server
    source      => '/etc/puppet/files/ejabberd-15.11.deb'
}
->
file { 'ejabberd.init':
    # The init file is provided by ejabberd but has to be copied to /etc/init.d manually
    name    => '/etc/init.d/ejabberd',
    owner   => 'root',
    group   => 'root',
    mode    => 0755,
    source  => '/etc/puppet/files/ejabberd.init',
}
->
file { 'ejabberd.yml':
    name    => '/opt/ejabberd-15.11/conf/ejabberd.yml',
    owner   => 'ejabberd',
    group   => 'ejabberd',
    mode    => '0660',
    source  => '/etc/puppet/files/ejabberd.yml',
    notify  => Service['ejabberd']
}
->
file { 'ejabberdctl.cfg':
    name => '/opt/ejabberd-15.11/conf/ejabberdctl.cfg',
    owner   => 'ejabberd',
    group   => 'ejabberd',
    mode    => '0660',
    source  => '/etc/puppet/files/ejabberdctl.cfg',
    notify  => Service['ejabberd']
}

service { 'ejabberd':
    ensure  => running,
    require => [
                Package['ejabberd'],
                File['ejabberd.init'],
                File['ejabberd.yml']
               ]
}
#->
#exec { 'add_users':
#    command => '/opt/ejabberd-15.11/bin/ejabberdctl register alice myejabberd 12345 && /opt/ejabberd-15.11/bin/ejabberdctl register bob myejabberd 12345',
#    creates => '/tmp/.userscreated'
#}
#->
#file { '/tmp/.userscreated':
#    ensure => present
#}
file { '/run/resolvconf/resolv.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => '/etc/puppet/files/resolv.conf'
}

file { '/opt/ejabberd-15.11/.erlang.cookie':
    ensure  => present,
    owner   => 'ejabberd',
    group   => 'ejabberd',
    mode    => 0400,
    source  => '/vagrant/.erlang.cookie',
    require => Package['ejabberd']
}

exec { 'sudo su ejabberd /opt/ejabberd-15.11/bin/ejabberdctl join_cluster ejabberd@myejabberd1.chatexample.com':
    require => [
                File['/opt/ejabberd-15.11/.erlang.cookie'],
                File['/run/resolvconf/resolv.conf'],
                Service['ejabberd']
                ]
}

