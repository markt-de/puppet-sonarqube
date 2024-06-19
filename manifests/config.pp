# @summary Configure SonarQube
# @api private
class sonarqube::config {
  require('sonarqube::install')

  File {
    owner => $sonarqube::user,
    group => $sonarqube::group,
  }

  # Create configuration files
  if $sonarqube::config !~ Undef {
    # Create config from scratch, do not use the template.
    file { "${sonarqube::installdir}/conf/sonar.properties":
      source => $sonarqube::config,
      notify => Class['sonarqube::service'],
      mode   => '0600',
    }
  } else {
    # Create config from template.
    file { "${sonarqube::installdir}/conf/sonar.properties":
      content => epp("${module_name}/sonar.properties.epp"),
      notify  => Class['sonarqube::service'],
      mode    => '0600',
    }
  }
}
