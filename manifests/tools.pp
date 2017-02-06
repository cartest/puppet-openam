# == Class: openam::tools
#
# Module for deployment of ssoAdminTools.
#
# === Authors
#
# Eivind Mikkelsen <eivindm@conduct.no>
#
# === Copyright
#
# Copyright (c) 2013 Conduct AS
#
class openam::tools {

  package { 'unzip': ensure => present }

  if $enable_configuration {
    file { "${openam::config_dir}/cli":
      ensure  => directory,
      owner   => $openam::tomcat_user,
      group   => $openam::tomcat_user,
      mode    => '0755',
      require => Exec['configure openam'],
    }

    exec { 'deploy ssoadm':
      cwd     => '/var/lib/openam',
      creates => "${openam::config_dir}/cli/setup",
      require => [
        Exec['configure openam'],
        File["${openam::config_dir}/cli"],
        Package['unzip']
        ],
      command => "/usr/bin/unzip SSOAdminTools-${openam::version}.zip -d ${openam::config_dir}/cli/",
    }

    exec { 'configure ssoadm':
      cwd         => "${openam::config_dir}/cli",
      creates     => "${openam::config_dir}/cli${openam::deployment_uri}",
      environment => "JAVA_HOME=${openam::java_home}",
      command     => "${openam::config_dir}/cli/setup -p ${openam::config_dir} -d ${openam::log_dir}/debug -l ${openam::log_dir}/log",
      require     => Exec['deploy ssoadm'],
    }

    file { "${openam::config_dir}/.pass":
      ensure  => present,
      owner   => $openam::tomcat_user,
      group   => $openam::tomcat_user,
      mode    => '0400',
      require => Exec['configure ssoadm'],
      content => "${openam::amadmin_pw}\n",
    }

    file { $openam::ssoadm:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0700',
      content => "#!/bin/bash\nexport JAVA_HOME=${openam::java_home}\ncommand=\$1\nshift;\n${openam::config_dir}/cli${openam::deployment_uri}/bin/ssoadm \$command -u amadmin -f ${openam::config_dir}/.pass \$@",
      require => File["${openam::config_dir}/.pass"],
    }
  }
}
