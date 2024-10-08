# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [6.0.0] - 2024-10-08

### Added
- SonarQube Scanner support
- Dependency [marktlib](https://github.com/markt-de/puppet-marktlib/)

### Changed
- Update PDK to 3.2.0
- Update module dependencies (incl. [#35])
- DSL modernization/rework
- CI workflow modernization/rework

### Removed
- Legacy os support
- SonarQube Runner support

### Fixed
- Stdlib deprecations for `ensure_packages()`
- GitHub Actions (unit+acceptance tests)
- Various paths for recent (OS and SonarQube) installations

## [5.3.0] - 2023-08-08

### Changed
- Update module dependencies and Puppet version requirements
- Update PDK to 3.0.0

### Fixed
- Fix GitHub Actions (unit+acceptance tests)

## [5.2.0] - 2023-07-11

### Added
- Add no proxy option ([#28])
- Add new parameter `$system_passcode` ([#29])

## [5.1.0] - 2023-01-04

### Added
- Add new parameter `$helper_dir` ([#27])

### Changed
- Increase NOFILE and NPROC service limits ([#25])
- Increase MAX_MAP_COUNT service limit ([#26])
- Run acceptance tests with latest version 9.8.0

### Fixed
- Fix setting PID file location on SonarQube 9.6 and later ([#24])

## [5.0.0] - 2022-10-31
This is a new major release and contains breaking changes. Of note is the
new requirement to specify the `$version` parameter using SonarQubes
4 digit version number.

### Added
- Add support for the `ldap.StartTLS` parameter ([#20])
- Add new parameter `$search_java_additional_opts` ([#21])
- Add new parameter `$pidfile` for backwards compatibility ([#23])

### Changed
- Remove default value for `$version` parameters
- Use `ensure_packages` to prevent duplicate declaration ([#18])
- Add Puppet header to files ([#22])
- Update OS support and dependencies
- Update to PDK 2.5.0
- Move acceptance tests to GitHub Actions
- Run acceptance tests with LTS version 8.9.9

### Fixed
- Fix unit tests & acceptance tests
- Fix puppet-lint offenses

### Deprecated
- Installing plugins from SonarSource is deprecated

### Removed
- Remove acceptance tests for LDAP configurations (requires a working LDAP server)

## [4.2.0] - 2021-10-27

### Added
- Add support for SSO authentication ([#12])

### Changed
- Replace legacy init.d with systemd service
- Update `$sonarqube::version` to current LTS version

### Fixed
- Fix service enable on Debian 10 ([#14])
- Service template not found when using a custom value for `$sonarqube::service` ([#8])

### Removed
- Remove legacy init.d file

## [4.1.0] - 2021-09-08

### Added
- Add new parameter `$manage_service` ([#9])
- Add support for `followReferrals` in LDAP parameters ([#11])

### Changed
- Update list of supported Puppet and operating system releases
- Bump module dependency versions

### Fixed
- Fix typos in README ([#10])

### Removed
- Remove support for EOL operating system releases

## [4.0.0] - 2020-05-15
This is a new major release in an ongoing effort to modernize the module.
NOTE: The change of the PID file could cause issues; it is recommended to update SonarQube to a new version while deploying this module version to ensure that the startup script uses the new PID file.

### Added
- Enable unit/acceptance tests on Travis CI
- Add unit/acceptance tests for plugin management
- Add support for RHEL/CentOS 8, Ubuntu 20.04
- Add new ways to download plugins: SonarSource, GitHub, direct download URL

### Changed
- Change default of `$version` to 7.9 (current LTS version)
- Change name of PID file in systemd service (requires the bundled sonar.sh)
- Rename `$package_name` to `$distribution_name`
- Enforce Puppet 4 data types
- Migrate `params.pp` to Hiera module data
- Replace dependency `puppet/wget` with `puppet/archive` ([#4])
- Convert templates from ERB to EPP
- Convert to Puppet Strings
- Declare classes private, remove class parameters from private classes
- Split main class into `sonarqube::install`, `sonarqube::config` and `sonarqube::service`

### Fixed
- Fix for error "missing property sonar.embeddedDatabase.port" ([md#76])
- Fix name of PID file on recent versions of SonarQube
- Assorted style fixes
- Fix unit/acceptance tests
- Fix very old bugs that were uncovered by the resurrected tests

### Removed
- Officially drop support for SonarQube <7.0
- Remove JDBC_URL from config for embedded database (avoids a SonarQube warning)
- Remove template for sonar.sh (use the one that comes bundled with SonarQube)
- Remove dependency on defunct `maestrodev/puppet-maven` module

## [3.1.0] - 2020-04-20

### Changed
- Update OS compatibility: drop SLES and Solaris

### Fixed
- Fix startup error: move sysctl handling to systemd service ([#2])

## [3.0.0] - 2019-10-23
This is the first release after forking the module. It should be possible to
migrate from maestrodev/sonarqube to this version with only minor modifications.

### Changed
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/75
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/78
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/80
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/81
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/89
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/92
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/95
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/96
- Apply PR https://github.com/maestrodev/puppet-sonarqube/pull/97
- Convert to PDK
- Update dependencies, os support and requirements

### Fixed
- Fixes for SonarQube 7.9 LTS ([#1])

[Unreleased]: https://github.com/markt-de/puppet-sonarqube/compare/v6.0.0...HEAD
[6.0.0]: https://github.com/markt-de/puppet-sonarqube/compare/v5.3.0...v6.0.0
[5.3.0]: https://github.com/markt-de/puppet-sonarqube/compare/v5.2.0...v5.3.0
[5.2.0]: https://github.com/markt-de/puppet-sonarqube/compare/v5.1.0...v5.2.0
[5.1.0]: https://github.com/markt-de/puppet-sonarqube/compare/v5.0.0...v5.1.0
[5.0.0]: https://github.com/markt-de/puppet-sonarqube/compare/v4.2.0...v5.0.0
[4.2.0]: https://github.com/markt-de/puppet-sonarqube/compare/v4.1.0...v4.2.0
[4.1.0]: https://github.com/markt-de/puppet-sonarqube/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/markt-de/puppet-sonarqube/compare/v3.1.0...v4.0.0
[3.1.0]: https://github.com/markt-de/puppet-sonarqube/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/markt-de/puppet-sonarqube/compare/v2.6.7...v3.0.0
[#35]: https://github.com/markt-de/puppet-sonarqube/pull/35
[#29]: https://github.com/markt-de/puppet-sonarqube/pull/29
[#28]: https://github.com/markt-de/puppet-sonarqube/pull/28
[#27]: https://github.com/markt-de/puppet-sonarqube/pull/27
[#26]: https://github.com/markt-de/puppet-sonarqube/pull/26
[#25]: https://github.com/markt-de/puppet-sonarqube/pull/25
[#24]: https://github.com/markt-de/puppet-sonarqube/pull/24
[#23]: https://github.com/markt-de/puppet-sonarqube/pull/23
[#22]: https://github.com/markt-de/puppet-sonarqube/pull/22
[#21]: https://github.com/markt-de/puppet-sonarqube/pull/21
[#20]: https://github.com/markt-de/puppet-sonarqube/pull/20
[#18]: https://github.com/markt-de/puppet-sonarqube/pull/18
[#14]: https://github.com/markt-de/puppet-sonarqube/pull/14
[#12]: https://github.com/markt-de/puppet-sonarqube/pull/12
[#11]: https://github.com/markt-de/puppet-sonarqube/pull/11
[#10]: https://github.com/markt-de/puppet-sonarqube/pull/10
[#9]: https://github.com/markt-de/puppet-sonarqube/pull/9
[#8]: https://github.com/markt-de/puppet-sonarqube/pull/8
[#4]: https://github.com/markt-de/puppet-sonarqube/pull/4
[#2]: https://github.com/markt-de/puppet-sonarqube/pull/2
[#1]: https://github.com/markt-de/puppet-sonarqube/pull/1
[md#76]: https://github.com/maestrodev/puppet-sonarqube/issues/76
