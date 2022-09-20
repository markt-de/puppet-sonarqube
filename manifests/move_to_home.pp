# @summary Symlink a folder to SonarQube's installation directory
#
# @param home
#   SonarQube's data directory.
define sonarqube::move_to_home (
  Stdlib::Absolutepath $home,
) {
  file { "${home}/${name}":
    ensure => directory,
  }
  -> file { "${sonarqube::installdir}/${name}":
    ensure => link,
    target => "${home}/${name}",
  }
}
