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
        	owner => 'postfix',
        	group => 'postfix',
		require => [Package['postfix']],
	}

	file { 'conf-saslpassword':
		path    => '/etc/postfix/sasl_passwd',
    		ensure  => present,
    		mode => 0400,
        	owner => 'postfix',
        	group => 'postfix',
		content => template('postfix-gmail/sasl_passwd.erb'),
		require => [Package['postfix'],File['postfix-directory']],
	}





       exec { 'run_postmap':
	      path => "/usr/sbin/:/usr/bin/",
	      command => "postmap /etc/postfix/sasl_passwd",
	      returns => [0],
	      require => File['conf-saslpassword'],
	  }
  
	
	file { 'conf-postfix':
		path    => '/etc/postfix/main.cf',
    		ensure  => present,
		content => template('postfix-gmail/main.cf.erb'),
		notify	=> Service['service-postfix'],
		require => [Package['postfix'], File['conf-saslpassword']],
	}

	service { 'service-postfix':
		name    => 'postfix',
		ensure  => running,
		require => File['conf-postfix'],
	}
}
