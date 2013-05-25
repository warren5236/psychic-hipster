
exec { 'apt-get update':
  command => 'apt-get update',
  path    => '/usr/bin/',
  timeout => 60,
  tries   => 3,
}

class { 'apt':
  always_apt_update => true,
}

package { ['python-software-properties']:
  ensure  => 'installed',
  require => Exec['apt-get update'],
}

file { '/home/vagrant/.bash_aliases':
  source => 'puppet:///modules/puphpet/dot/.bash_aliases',
  ensure => 'present',
}

package { ['build-essential', 'vim', 'curl']:
  ensure  => 'installed',
  require => Exec['apt-get update'],
}

class { 'apache': }

apache::dotconf { 'custom':
  content => 'EnableSendfile Off',
}

apache::module { 'rewrite': }
apache::module { 'headers': }

apache::vhost { 'www.192.168.56.101.xip.io':
  server_name   => 'www.192.168.56.101.xip.io',
  serveraliases => [],
  docroot       => '/var/www/public',
  port          => '80',
  env_variables => [],
  priority      => '1',
}

apt::ppa { 'ppa:ondrej/php5':
  before  => Class['php'],
}

class { 'php':
  service => 'apache',
  require => Package['apache'],
}

php::module { 'php5-cli': }
php::module { 'php5-curl': }
php::module { 'php5-intl': }
php::module { 'php5-mcrypt': }

class { 'php::devel':
  require => Class['php'],
}

class { 'php::pear':
  require => Class['php'],
}



class { 'xdebug':
  service => 'apache',
}

xdebug::config { 'cgi': }
xdebug::config { 'cli': }

class { 'php::composer': }

php::ini { 'custom':
  value  => ['display_errors = On', 'error_reporting = -1', 'date.timezone=America/Detroit'],
  target => 'custom.ini',
  service => 'apache',
}

class { 'mysql':
  root_password => 'zendpass',
}

mysql::grant { 'ph':
  mysql_privileges     => 'ALL',
  mysql_db             => 'ph',
  mysql_user           => 'zenduser',
  mysql_password       => 'zendpass',
  mysql_host           => 'localhost',
  mysql_grant_filepath => '/home/vagrant/puppet-mysql',
}

