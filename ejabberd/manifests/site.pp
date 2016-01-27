
Exec {
    path => '/bin/:/usr/bin:/sbin:/usr/sbin'
}

exec { 'apt-get update':
    refreshonly => true
}

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
->
exec { 'add_users':
    command => '/opt/ejabberd-15.11/bin/ejabberdctl register alice myejabberd.chatexample.com 12345 && /opt/ejabberd-15.11/bin/ejabberdctl register bob myejabberd.chatexample.com 12345',
    creates => '/tmp/.userscreated',
    require => File['/run/resolvconf/resolv.conf']
}
->
file { '/tmp/.userscreated':
    ensure => present
}

file { '/run/resolvconf/resolv.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => '/etc/puppet/files/resolv.conf'
}

exec { 'copy_erlang_cookie':
# This is necessay if we want to cluster. This erlang cookie has to be copied to the later slave server
    command => 'cp -rf /opt/ejabberd-15.11/.erlang.cookie /vagrant/',
    require => [
                Package['ejabberd'],
                Service['ejabberd']
                ]
}
