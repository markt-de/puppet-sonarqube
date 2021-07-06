# @summary Setup SonarQube service
# @api private
class sonarqube::service {
  File {
    owner => $sonarqube::user,
    group => $sonarqube::group,
  }

  file_line { 'set PIDDIR in startup script':
    ensure   => present,
    path     => $sonarqube::script,
    line     => "PIDDIR=${sonarqube::home}",
    match    => '^PIDDIR=',
    multiple => true,
  }
  -> file_line { 'set RUN_AS_USER in startup script':
    ensure   => present,
    path     => $sonarqube::script,
    line     => "RUN_AS_USER=${sonarqube::user}",
    match    => '^RUN_AS_USER=',
    # insert after PIDDIR of no match is found
    after    => '^PIDDIR=',
    multiple => true,
  }

  if ($sonarqube::manage_service) {
    file { "/etc/init.d/${sonarqube::service}":
      ensure => link,
      target => $sonarqube::script,
    }

    file { "/etc/systemd/system/${sonarqube::service}.service":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => epp("${module_name}/${sonarqube::service}.service.epp")
    }

    service { 'sonarqube':
      ensure     => running,
      name       => $sonarqube::service,
      hasrestart => true,
      hasstatus  => true,
      enable     => true,
      require    => [
        File["/etc/init.d/${sonarqube::service}"],
        File["/etc/systemd/system/${sonarqube::service}.service"]
      ]
    }
  }
}
