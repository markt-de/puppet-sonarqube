# @summary Install and configure SonarQube Runner
#
# @param distribution_name
#   Specifies the basename of the installation archive.
#
# @param download_url
#   The URL from which the installation archive should be downloaded.
#
# @param installroot
#   Specifies the base directory where it should be installed. A new
#   subdirectory for each version will be created.
#
# @param jdbc
#   Specifies the database configuration.
#
# @param sonarqube_server
#   The URL for the default SonarQube server.
#
# @param version
#   Specifies the version that should be installed/updated.
#
class sonarqube::runner (
  String $download_url,
  Stdlib::Absolutepath $installroot,
  Hash $jdbc,
  String $distribution_name,
  String $sonarqube_server,
  String $version,
) {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  include(['sonarqube::runner::install', 'sonarqube::runner::config'])
}
