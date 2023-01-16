# puppet-sonarqube

[![Build Status](https://github.com/markt-de/puppet-sonarqube/actions/workflows/ci.yaml/badge.svg)](https://github.com/markt-de/puppet-sonarqube/actions/workflows/ci.yaml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/fraenki/sonarqube.svg)](https://forge.puppetlabs.com/fraenki/sonarqube)
[![Puppet Forge](https://img.shields.io/puppetforge/f/fraenki/sonarqube.svg)](https://forge.puppetlabs.com/fraenki/sonarqube)

#### Table of Contents

1. [Overview](#overview)
2. [Usage](#usage)
    - [Basic usage](#basic-usage)
    - [SonarQube Plugins](#sonarqube-plugins)
    - [LDAP Configuration](#ldap-configuration)
3. [Reference](#reference)
4. [Development](#development)
    - [Contributing](#contributing)
5. [License](#license)

## Overview

A puppet module to install and configure [SonarQube](https://www.sonarqube.org/) (former Sonar).

The main goal is compatibility with the latest LTS release of SonarQube. Older versions are not supported. However, newer versions should usually work too.

## Usage

### Basic usage

The minimum configuration should at least specify the desired version:

```puppet
class { 'java': }
class { 'sonarqube':
  version => '8.9.9.56886',
}
```

NOTE: The `$version` parameter expects a 4 digit version number (1.2.3.4), which can be found on the SonarQube download page (hidden in the filename).

A more complex example could look like this:

```puppet
class { 'java': }
class { 'sonarqube':
  version       => '8.9.9.56886',
  edition       => 'community',
  user          => 'sonar',
  group         => 'sonar',
  service       => 'sonar',
  installroot   => '/opt/sonar-install',
  home          => '/opt/sonar-data',
  log_folder    => '/var/log/sonar',
  download_url  => 'https://binaries.sonarsource.com/Distribution/sonarqube',
  jdbc          => {
    url         => 'jdbc:h2:tcp://localhost:9092/sonar',
    username    => 'sonar',
    password    => 'secretpassword',
  },
  web_java_opts => '-Xmx1024m',
  updatecenter  => 'true',
  http_proxy        => {
    host            => 'proxy.example.com',
    port            => '8080',
    ntlm_domain     => '',
    user            => '',
    password        => '',
    non_proxy_hosts => 'localhost|127.*|[::1]',
  },
  sso             => {
    enable        => 'true',
    emailheader   => 'X-Forwarded-Email',
    groupsheader  => 'X-Forwarded-Groups',
    loginheader   => 'X-Forwarded-Login',
    nameheader    => 'X-Forwarded-Name',
    refreshintervalinminutes => '5',
  }
}
```

### SonarQube Plugins

The `sonarqube::plugin` defined type can be used to install SonarQube plugins. Plugins are available from many different sources, so this module supports multiple download sources as well. It will also purge old plugin versions.

A plugin can be removed by setting the parameter `ensure` to `absent`.

Probably the best source for plugins is SonarSource. To download and install one of these plugins, use the following example:

```plugin
sonarqube::plugin { 'sonar-kotlin-plugin':
  version => '1.7.0.883',
}
```

Be sure to use the full version number as demonstrated in this example.
Check https://binaries.sonarsource.com/Distribution/ and https://docs.sonarqube.org/latest/analysis/languages/overview/ for a list of available plugins.

If the plugin is hosted on GitHub, then you only need to provide a GitHub identifier, which is essentially a combination of the GitHub username and project name:

```plugin
sonarqube::plugin { 'checkstyle-sonar-plugin':
  version => '4.31',
  ghid    => 'checkstyle/sonar-checkstyle',
}
```

Note that the GitHub project must provide jar files for its releases. Otherwise the download is prone to fail.

If none of these methods work, you may also specify a direct download URL, which should be seen as a last resort:

```plugin
sonarqube::plugin { 'sonar-detekt':
  version => '2.0.0',
  url     => 'https://github.com/detekt/sonar-kotlin/releases/download/sonar-detekt-2.0.0.jar',
}
```

Note that in this case the filename must exactly match the plugin name and version, otherwise this will not work.

Finally the old way to install plugins using Maven is still available, but it requires to set the `$legacy` parameter:

```puppet
class { 'maven::maven': }

sonarqube::plugin { 'sonar-javascript-plugin':
  legacy  => true,
  groupid => 'org.sonarsource.javascript',
  version => '2.10',
}
```

The defunct `maestrodev/puppet-maven` module is required to make this work. And it is most likely not very useful on newer versions of SonarQube and may be removed in future versions of this module. (Please open an issue on GitHub if you think this is still useful.)

### LDAP Configuration

The `sonarqube` class provides an easy way to configure security with LDAP, Crowd or PAM. Here's an example with LDAP:

```puppet
$ldap = {
  url          => 'ldap://myserver.mycompany.com',
  user_base_dn => 'ou=Users,dc=mycompany,dc=com',
  local_users  => ['foo', 'bar'],
}

class { 'java': }
-> class { 'sonarqube':
  ldap    => $ldap,
  version => '8.9.9.56886'
}

# Do not forget to add the SonarQube LDAP plugin that is not provided out of
# the box on SonarQube versions older than 8.0. Same thing with Crowd or PAM.
sonarqube::plugin { 'sonar-ldap-plugin':
  version => '2.2.0.608',
}
```

## Reference

Classes and parameters are documented in [REFERENCE.md](REFERENCE.md).

## Development

### Contributing

Please use the GitHub issues functionality to report any bugs or requests for new features. Feel free to fork and submit pull requests for potential contributions.

All contributions must pass all existing tests, new features should provide additional unit/acceptance tests.

## License

```
Copyright 2019-2022 markt.de GmbH & Co. KG
Copyright 2011-2013 MaestroDev, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
