# @summary Configuration of SonarQube Runner
# @api private
class sonarqube::runner::config {
  assert_private()

  require('sonarqube::runner::install')

  # Sonar Runner configuration file
  file { "${sonarqube::runner::installroot}/${sonarqube::runner::distribution_name}-${sonarqube::runner::version}/conf/sonar-runner.properties": # lint:ignore:140chars
    content => epp("${module_name}/sonar-runner.properties.epp"),
  }
}
