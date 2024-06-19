# @summary Install and configure SonarQube Scanner
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
class sonarqube::scanner (
  String[1] $download_url,
  Stdlib::Absolutepath $installroot,
  Hash $jdbc,
  String[1] $distribution_name,
  String[1] $sonarqube_server,
  String[1] $version,
) {
  Exec {
    path => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
  }

  include(['sonarqube::scanner::install', 'sonarqube::scanner::config'])
}
