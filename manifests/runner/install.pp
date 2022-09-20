# @summary Installation of SonarQube Runner
# @api private
class sonarqube::runner::install {
  assert_private()

  if ! defined(Package[unzip]) {
    package { 'unzip':
      ensure => present,
      before => Exec['unzip-sonar-runner'],
    }
  }

  $tmpzip = "/usr/local/src/${sonarqube::runner::distribution_name}-dist-${sonarqube::runner::version}.zip"

  archive { 'download-sonar-runner':
    ensure => present,
    path   => $tmpzip,
    source => "${sonarqube::runner::download_url}/${sonarqube::runner::version}/sonar-runner-dist-${sonarqube::runner::version}.zip",
  }

  -> file { "${sonarqube::runner::installroot}/${sonarqube::runner::distribution_name}-${sonarqube::runner::version}":
    ensure => directory,
  }

  -> file { "${sonarqube::runner::installroot}/${sonarqube::runner::distribution_name}":
    ensure => link,
    target => "${sonarqube::runner::installroot}/${sonarqube::runner::distribution_name}-${sonarqube::runner::version}",
  }

  -> exec { 'unzip-sonar-runner':
    command => "unzip -o ${tmpzip} -d ${sonarqube::runner::installroot}",
    creates => "${sonarqube::runner::installroot}/sonar-runner-${sonarqube::runner::version}/bin",
    require => [Package['unzip'], Archive['download-sonar-runner']],
  }

  # Sonar settings for terminal sessions.
  file { '/etc/profile.d/sonarhome.sh':
    content => "export SONAR_RUNNER_HOME=${sonarqube::runner::installroot}/${sonarqube::runner::distribution_name}-${sonarqube::runner::version}", # lint:ignore:140chars
  }

  file { '/usr/bin/sonar-runner':
    ensure => link,
    target => "${sonarqube::runner::installroot}/${sonarqube::runner::distribution_name}-${sonarqube::runner::version}/bin/sonar-runner",
  }
}
