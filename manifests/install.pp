# @summary Install SonarQube package
# @api private
class sonarqube::install {
  Sonarqube::Move_to_home {
    home => $sonarqube::home,
  }

  # Evaluate download URL
  if $sonarqube::edition == 'community' {
    $source_url = "${sonarqube::download_url}/${sonarqube::distribution_name}-${sonarqube::version}.zip"
  } else {
    $source_url = "${sonarqube::download_url}/${sonarqube::distribution_name}-${sonarqube::edition}-${sonarqube::version}.zip"
  }

  if ! defined(Package[unzip]) {
    stdlib::ensure_packages(['unzip'], {
        ensure => present,
        before => Exec['install sonarqube distribution']
    })
  }

  # Create user and group
  user { $sonarqube::user:
    ensure     => present,
    home       => $sonarqube::home,
    managehome => false,
    system     => $sonarqube::user_system,
  }
  -> group { $sonarqube::group:
    ensure => present,
    system => $sonarqube::user_system,
  }

  # Download distribution archive
  -> archive { 'download sonarqube distribution':
    ensure => present,
    path   => $sonarqube::tmpzip,
    source => $source_url,
  }

  # Create folder structure
  -> file { $sonarqube::home:
    ensure => directory,
    mode   => '0700',
  }
  -> file { "${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version}":
    ensure => directory,
  }
  -> file { $sonarqube::installdir:
    ensure => link,
    target => "${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version}",
    notify => Class['sonarqube::service'],
  }
  -> sonarqube::move_to_home { 'data': }
  -> sonarqube::move_to_home { 'extras': }
  -> sonarqube::move_to_home { 'extensions': }
  -> sonarqube::move_to_home { 'logs': }

  # Uncompress (new) sonar version
  -> exec { 'install sonarqube distribution':
    command => "unzip -o ${sonarqube::tmpzip} -d ${sonarqube::installroot} && chown -R \
      ${sonarqube::user}:${sonarqube::group} ${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version} && chown -R ${sonarqube::user}:${sonarqube::group} ${sonarqube::home}", # lint:ignore:140chars
    creates => "${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version}/bin",
    notify  => Class['sonarqube::service'],
  }

  # Setup helper scripts to ensure that old versions of sonar and plugins
  # are removed.
  file { $sonarqube::helper_dir:
    ensure => directory,
  }

  file { "${sonarqube::helper_dir}/cleanup-old-plugin-versions.sh":
    content => epp("${module_name}/cleanup-old-plugin-versions.sh.epp"),
    mode    => '0755',
  }
  -> file { "${sonarqube::helper_dir}/cleanup-old-sonarqube-versions.sh":
    content => epp("${module_name}/cleanup-old-sonarqube-versions.sh.epp"),
    mode    => '0755',
  }
  -> exec { 'remove-old-versions-of-sonarqube':
    command     => "${sonarqube::helper_dir}/cleanup-old-sonarqube-versions.sh ${sonarqube::installroot} ${sonarqube::version}",
    path        => '/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin',
    refreshonly => true,
    subscribe   => File["${sonarqube::installroot}/${sonarqube::distribution_name}-${sonarqube::version}"],
  }

  # The plugins directory. Useful to later reference it from the plugin definition
  file { $sonarqube::plugin_dir:
    ensure => directory,
  }
}
