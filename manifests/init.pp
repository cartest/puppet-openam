# == Class: openam
#
# Module for deployment and configuration of ForgeRock OpenAM with tools.
#
# === Authors
#
# Eivind Mikkelsen <eivindm@conduct.no>
#
# === Copyright
#
# Copyright (c) 2013 Conduct AS
#

class openam(
  $version                = hiera('openam::version'),
  $java_home              = hiera('openam::java_home'),
  $tomcat_user            = hiera('openam::tomcat_user'),
  $tomcat_service         = hiera('openam::tomcat_service', 'tomcat-openam'),
  $tomcat_home            = hiera('openam::tomcat_home'),
  $config_dir             = hiera('openam::config_dir', '/opt/openam'),
  $log_dir                = hiera('openam::log_dir', '/var/log/openam'),
  $locale                 = hiera('openam::locale', 'en_US'),
  $ssoadm                 = hiera('openam::ssoadm', '/usr/local/bin/ssoadm'),
  $enable_configuration   = hiera('openam::enable_configuration', true),
  $deployment_uri         = hiera('openam::deployment_uri'),
  $site_url               = hiera('openam::site_url'),
  $cookie_domain          = hiera('openam::cookie_domain'),
  $master                 = hiera('openam::master'),

  $server_protocol        = hiera('openam::server_protocol', 'http'),
  $server_port            = hiera('openam::server_port', '8080'),
  $amadmin_pw             = hiera('openam::amadmin_pw'),
  $amldapuser_pw          = hiera('openam::amldapuser_pw'),
  $encryption_key         = hiera('openam::encryption_key'),

  $userstore_host         = hiera('openam::userstore_host', 'localhost'),
  $userstore_ldap_port    = hiera('openam::userstore_ldap_port', '1389'),
  $userstore_suffix       = hiera('openam::userstore_suffix'),
  $userstore_binddn       = hiera('openam::userstore_binddn'),
  $userstore_bindpw       = hiera('openam::userstore_bindpw'),

  $configstore_host       = hiera('openam::configstore_host', 'localhost'),
  $configstore_ldap_port  = hiera('openam::configstore_ldap_port', '1389'),
  $configstore_admin_port = hiera('openam::configstore_admin_port', '4444'),
  $configstore_jmx_port   = hiera('openam::configstore_jmx_port', '1689'),
  $configstore_suffix     = hiera('openam::configstore_suffix'),
  $configstore_binddn     = hiera('openam::configstore_binddn'),
  $configstore_bindpw     = hiera('openam::configstore_bindpw'),

  $datastore              = 'embedded',
  $environment            = hiera('openam::environment'),
  $master_url             = hiera('openam::master_url')
) {
  $server_host = $::sso_server_hostname ? {
    undef   => $::fqdn,
    nil     => $::fqdn,
    default => $::sso_server_hostname,
  }

  $server_url = "${openam::server_protocol}://${openam::server_host}:${openam::server_port}"

  include openam::config
  include openam::logs
  include openam::tools

  Class['openam::config']    -> Class['openam::logs']
  Class['openam::logs']      -> Class['openam::tools']
}
