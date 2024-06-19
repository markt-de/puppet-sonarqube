# @summary Installation of SonarQube Scanner
# @api private
class sonarqube::scanner::install {
  assert_private()

  stdlib::ensure_packages('unzip')

  $tmpzip = "/usr/local/src/${sonarqube::scanner::distribution_name}-cli-${sonarqube::scanner::version}.zip"

  archive { 'download-sonar-scanner':
    ensure => present,
    path   => $tmpzip,
    source => "${sonarqube::scanner::download_url}/sonar-scanner-cli-${sonarqube::scanner::version}.zip",
  }

  file { "${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}-${sonarqube::scanner::version}":
    ensure => directory,
  }

  file { "${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}":
    ensure  => link,
    target  => "${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}-${sonarqube::scanner::version}",
    require => File["${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}-${sonarqube::scanner::version}"],
  }

  exec { 'unzip-sonar-scanner':
    command => "unzip -o ${tmpzip} -d ${sonarqube::scanner::installroot}",
    creates => "${sonarqube::scanner::installroot}/sonar-scanner-${sonarqube::scanner::version}/bin",
    require => [Package['unzip'], Archive['download-sonar-scanner'], File["${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}-${sonarqube::scanner::version}"]], # lint:ignore:140chars
  }

  file { '/usr/bin/sonar-scanner':
    ensure  => link,
    target  => "${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}-${sonarqube::scanner::version}/bin/sonar-scanner", # lint:ignore:140chars
    require => Exec['unzip-sonar-scanner'],
  }

  # Sonar settings for terminal sessions.
  file { '/etc/profile.d/sonarhome.sh':
    content => "export SONAR_SCANNER_HOME=${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}-${sonarqube::scanner::version}", # lint:ignore:140chars
  }
}
