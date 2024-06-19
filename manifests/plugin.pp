# @summary Manage SonarQube plugins: download, install, remove.
#
# @param artifactid
#   Namevar. Specifies the name of the plugin.
#
# @param ensure
#   Specifies the ensure state for the plugin.
#   Default: `present`
#
# @param ghid
#   Specifies a combination of a GitHub username and project name,
#   for example `myuser/sonar-exampleplugin`. This is used to generate
#   the download URL.
#
# @param groupid
#   Specifies the groupid to use with maven.
#
# @param legacy
#   Install plugin using Maven. May not work with recent versions.
#
# @param url
#   A direct download URL that points to the .jar file for the specified plugin.
#   The filename must match the values of `$name` and `$version`, otherwise the
#   cleanup script may malfunction.
#
# @param version
#   Specifies the version of the plugin. This is also required to find
#   and purge old plugin versions.
#
define sonarqube::plugin (
  String[1] $version,
  String[1] $artifactid = $name,
  Enum['present','absent'] $ensure = present,
  Boolean $legacy = false,
  String[1] $groupid = 'org.codehaus.sonar-plugins',
  Optional[String[1]] $ghid = undef,
  Optional[String[1]] $url = undef,
) {
  include 'sonarqube'

  $plugin_name = "${artifactid}-${version}.jar"
  $plugin_tmp  = "${sonarqube::plugin_tmpdir}/${plugin_name}"
  $plugin      = "${sonarqube::plugin_dir}/${plugin_name}"

  # Install plugin
  if $ensure == present {
    if $url !~ Undef {
      # Use direct download URL for installation

      archive { "download plugin ${plugin_name}":
        ensure => present,
        path   => $plugin_tmp,
        source => $url,
        notify => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    } elsif $ghid !~ Undef {
      # Use GitHub project URL for installation

      # Compose GitHub download URL. If the project does not use this
      # pattern, then the direct download method should be used.
      $_ghurl = "https://github.com/${ghid}/releases/download/${version}/${artifactid}-${version}.jar"

      archive { "download plugin ${plugin_name} from GitHub":
        ensure => present,
        path   => $plugin_tmp,
        source => $_ghurl,
        notify => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    } elsif !$legacy {
      # Install from SonarSource
      # NOTE: This feature is deprecated since SonarQube 8.5, see:
      # https://community.sonarsource.com/t/sonarqube-v8-5-and-beyond-where-did-all-the-plugins-go/32792

      # Compose SonarSource download URL. Let's hope that they stick to
      # this pattern for years to come.
      $_sonarurl = "https://binaries.sonarsource.com/Distribution/${artifactid}/${artifactid}-${version}.jar"

      archive { "download plugin ${plugin_name} from SonarSource":
        ensure => present,
        path   => $plugin_tmp,
        source => $_sonarurl,
        notify => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    } elsif $legacy {
      # Legacy method: install using Maven. May not work with recent versions.

      maven { "/tmp/${plugin_name}":
        groupid    => $groupid,
        artifactid => $artifactid,
        version    => $version,
        require    => File[$sonarqube::plugin_dir],
        notify     => [
          File[$plugin],
          Exec["remove old versions of ${artifactid}"],
        ],
      }
    } else {
      fail("Unable to install plugin ${artifactid}: usage error. Missing parameters") # lint:ignore:check_i18n
    }

    # Copy plugin from tmp location to plugin directory.
    file { $plugin:
      ensure => $ensure,
      source => $plugin_tmp,
      owner  => $sonarqube::user,
      group  => $sonarqube::group,
      notify => [
        Class['sonarqube::service'],
        Exec["remove old versions of ${artifactid}"],
      ],
    }
    # Cleanup old version of this plugin
    exec { "remove old versions of ${artifactid}":
      command     => "${sonarqube::helper_dir}/cleanup-old-plugin-versions.sh ${sonarqube::plugin_dir} ${artifactid} ${version}",
      path        => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/usr/local/bin', '/usr/local/sbin'],
      refreshonly => true,
    }
  } else {
    # Uninstall plugin
    file { $plugin:
      ensure => $ensure,
      notify => Class['sonarqube::service'],
    }
  }
}
