

Exec {
    path => '/bin:/usr/bin:/sbin:/usr/sbin'
}


exec { 'apt-get update':
    refreshonly => true;
}

package { 'mysql-client':
    ensure  => installed,
    require => Exec['apt-get update'],

}

package { 'mysql-server':
    ensure  => installed,
    require => Exec['apt-get update'],
}

service { 'mysql':
    ensure  => running,
    require => Package['mysql-server']
}

package {
# Install some recommended packages
# - lua-dbi-mysql: enables mysql as data storafe
# - lua-zlib: enables compression of the xmpp streams
    'lua-dbi-mysql':;
    'lua-zlib':;
}
->
package { 'prosody':
    ensure      => latest,
    require     => Exec['apt-get update'],
}
->
file {'prosody_config':
    name    => '/etc/prosody/prosody.cfg.lua',
    owner   => 'root',
    group   => 'prosody',
    mode    => 0644,
    source  => '/etc/puppet/files/prosody.cfg.lua',
    require => Package['prosody'],
}
->
exec { 'initDBforChatServer':
# execute a small sql script creating database and a user for prosody, granting the user all required rights
    command => 'mysql -u root < /etc/puppet/files/initDBforChatServer.sql',
    creates => '/etc/prosody/.databaseSetUp',
    require =>  [
                    Service['mysql'],
                    Package['mysql-client']
                ],
    before  => File['/etc/prosody/.databaseSetUp'],
}
->
file { '/etc/prosody/.databaseSetUp':
# create a file to prevent second execution of sql script. trying to create a user if it already exist throws an error. latest version of mysql supports "create user if not exists", which would solve this problem more elegantly.
    ensure  => present,
    require => Package['prosody']
}
->
exec { 'add_users':
    command => 'prosodyctl register kevin myprosody.chatexample.com 12345 && prosodyctl register stuart myprosody.chatexample.com 12345',
    creates => '/etc/prosody/.userscreated',
    require => File['/run/resolvconf/resolv.conf']
}
->
file { '/etc/prosody/.userscreated':
    ensure => present,
}
~>
service { 'prosody':
    ensure      => running,
    enable      => true,
    hasstatus   => false,
    require     => [
                    Package['prosody'],
                    File['prosody_config']
                    ]
}

file { '/run/resolvconf/resolv.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => '/etc/puppet/files/resolv.conf'
}
