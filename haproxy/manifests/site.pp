Exec {
    path => '/bin/:/usr/bin:/sbin:/usr/sbin'
}

exec { 'apt-get update':
    #refreshonly => true
}

package { 'bind9':
    ensure  => latest,
    require => Exec['apt-get update']
}
->
package { 'bind9utils':
    ensure => latest,
    require => Exec['apt-get update']
}
->
file { '/etc/default/bind9':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    source  => '/etc/puppet/files/bind9'
}
->
file { '/etc/bind/zones':
    ensure  => directory
}
->
file { '/etc/bind/named.conf':
# need to use our own config file as bind9 does not start with the installed one
    ensure  => present,
    owner   => 'root',
    group   => 'bind',
    mode    => 0644,
    source  => '/etc/puppet/files/named.conf'
}
->
file { '/etc/bind/named.conf.options':
    ensure  => present,
    owner   => 'root',
    group   => 'bind',
    mode    => 0644,
    source  => '/etc/puppet/files/named.conf.options'
}
->
file { '/etc/bind/named.conf.local':
    ensure  => present,
    owner   => 'root',
    group   => 'bind',
    mode    => 0644,
    source  => '/etc/puppet/files/named.conf.local'
}
->
file { '/etc/bind/zones/db.chatexample.com':
    ensure  => present,
    owner   => 'root',
    group   => 'bind',
    mode    => 0644,
    source  => '/etc/puppet/files/db.chatexample.com',
}
~>
service { 'bind9':
    ensure  => running,
    require => Package['bind9']
}

package { 'haproxy':
    ensure => latest,
    require => Exec['apt-get update']
}
->
file { '/etc/haproxy/haproxy.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    source  => '/etc/puppet/files/haproxy.cfg',
}
->
file { '/etc/default/haproxy':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    source  => '/etc/puppet/files/haproxy',
}
->
file { '/etc/sysctl.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    source  => '/etc/puppet/files/sysctl.conf',
}
~>
exec { 'sysctl':
    command => 'sysctl -p'
    }
~>
service { 'haproxy':
    ensure  => running,
    require => [
                Package['haproxy'],
                File['/etc/haproxy/haproxy.cfg']
               ]
}

file { '/run/resolvconf/resolv.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => '/etc/puppet/files/resolv.conf',
    require => Service['bind9']
}
