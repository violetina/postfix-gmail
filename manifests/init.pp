class postfix-gmail($username, $userpassword) {
  $mydestination = "$fqdn, localhost.${domain}, localhost"
  $myhostname = "$fqdn"
  $relayhost = "[smtp.gmail.com]:587"
  package { 'package-postfix': 
   name   => 'postfix',
   ensure => present,	
  }
  file { 'postfix-directory':
    path    => '/etc/postfix',
    ensure  => directory,
    owner => 'root',
    group => 'root',
    require => [Package['postfix']],
  }
  file { 'conf-saslpassword':
    path    => '/etc/postfix/sasl_passwd',
    ensure  => present,
    mode    => 0400,
    owner   => 'root',
    group   => 'root',
    content => template('postfix-gmail/sasl_passwd.erb'),
    require => [Package['postfix'],File['postfix-directory']],
    notify  => Exec['run_postmap'],
  }
  exec { 'run_postmap':
    path        => "/usr/sbin/:/usr/bin/",
    command     => "postmap /etc/postfix/sasl_passwd",
    creates     => '/etc/postfix/sasl_passwd.db',
    subscribe   => [File['conf-postfix'],File['conf-saslpassword']],
    require     => File['conf-saslpassword'],
    refreshonly => true,
  }
  file { 'conf-postfix':
    path    => '/etc/postfix/main.cf',
    ensure  => present,
    content => template('postfix-gmail/main.cf.erb'),
    notify  => [Service['service-postfix'],Exec['run_postmap']],
    require => [Package['postfix'], File['conf-saslpassword']],
  }

  service { 'service-postfix':
    name    => 'postfix',
    ensure  => running,
    require => File['conf-postfix'],
  }
}
