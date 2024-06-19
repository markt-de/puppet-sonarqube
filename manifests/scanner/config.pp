# @summary Configuration of SonarQube Scanner
# @api private
class sonarqube::scanner::config {
  assert_private()

  require('sonarqube::scanner::install')

  # Sonar Scanner configuration file
  file { "${sonarqube::scanner::installroot}/${sonarqube::scanner::distribution_name}-${sonarqube::scanner::version}/conf/sonar-scanner.properties": # lint:ignore:140chars
    content => epp("${module_name}/sonar-scanner.properties.epp"),
  }
}
