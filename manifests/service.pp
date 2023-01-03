# @summary Setup SonarQube service
# @api private
class sonarqube::service {
  File {
    owner => $sonarqube::user,
    group => $sonarqube::group,
  }

  # SonarQube version 9.6 introduced breaking changes in the startup script.
  if (versioncmp($sonarqube::version, '9.6') >= 0) {
    file_line { 'set PIDFILE in startup script':
      ensure   => present,
      path     => $sonarqube::script,
      line     => "PIDFILE=${sonarqube::home}/${sonarqube::pidfile}",
      match    => '^PIDFILE=',
      multiple => true,
    }
  } else {
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
  }

  if ($sonarqube::manage_service) {
    # Remove legacy init script
    file { "/etc/init.d/${sonarqube::service}":
      ensure => absent,
    }

    # Add systemd service configuration
    -> file { "/etc/systemd/system/${sonarqube::service}.service":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => epp("${module_name}/sonar.service.epp"),
    }

    # Enable systemd service
    -> service { $sonarqube::service:
      ensure     => running,
      hasrestart => true,
      hasstatus  => true,
      enable     => true,
    }
  }
}
