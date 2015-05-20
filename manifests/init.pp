# Class: epel
#
# This module manages the configuration of the EPEL repository.
#
# Notes:
#  * This is designed specifically for Enterprise Linux 6 based systems. Others
#    will not work.
#  * The 'epel-release' package will be kept at the 'latest' version, which
#    really shouldn't matter given that it's installed using the RPM provider.
#
# Parameters:
#
# $ensure::                        Status of the EPEL setup.  Valid values are
#                                  'present' and 'absent'.
#                                  Defaults to 'present'.
#                                  type:string
#
# $release_uri::                   URI the the epel-release package within your
#                                  environment.  This will be installed directly
#                                  using the RPM provider (not Yum).
#                                  Defaults to the public Fedora EPEL repository.
#                                  type:string
#
# $mirror_base_uri::               The base URI to use for mirror lookups.  This
#                                  will only be used if the value of $use_mirror
#                                  is true.
#                                  Defaults to the public Fedora EPEL repository.
#                                  type:string
#
# static_base_uri::                The base URI to use for the repository.  This
#                                  will only be used if the value of $use_mirror
#                                  is false.
#                                  Defaults to the public Fedora EPEL repository.
#                                  type:string 
#
# $use_mirror::                    Set whether the repositories should be 
#                                  configured to use a mirror (true). If this
#                                  parameter is set to false the static URI field
#                                  baseurl will be used.  If it is set to true
#                                  The dynamic URI field mirrorlist will be used.
#                                  Defaults to true (mirrorlist).
#                                  type:boolean
#
# $failover_method::               The Yum failover method to use.  Valid values
#                                  are 'priority' or 'roundrobin'.
#                                  Defaults to 'priority'.
#                                  type:string 
#
# $gpg_check::                     Enable or disable the checking of signatures from
#                                  the EPEL repositories.  If you are disabling this
#                                  you should probably consider your life choices.
#                                  Defaults to true.
#                                  type:boolean 
#
# $enable_epel::                   Enable or disable the main EPEL repository.
#                                  Defaults to true.
#                                  type:boolean 
#
# $enable_epel_debuginfo::         Enable or disable the debuginfo enabled version of
#                                  the main EPEL repository.
#                                  Defaults to false.
#                                  type:boolean 
#
# $enable_epel_source::            Enable or disable the main EPEL source repository.
#                                  Defaults to false.
#                                  type:boolean 
#
# $enable_epel_testing::           Enable or disable the test EPEL repository.
#                                  Defaults to false.
#                                  type:boolean 
#
# $enable_epel_testing_debuginfo:: Enable or disable the debuginfo enabled version of
#                                  the test EPEL repository.
#                                  Defaults to false.
#                                  type:boolean 
#
# $enable_epel_testing_source::    Enable or disable the test EPEL source repository.
#                                  Defaults to false.
#                                  type:boolean 
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
# * Simple usage
#
#     include epel
#
# * Use a static internal mirror
#
#  class { 'epel':
#    release_uri     => 'http://yum.internal/epel/epel-release-latest-6.noarch.rpm',
#    use_mirror      => false,
#    static_base_uri => 'http://yum.internal/epel/6',
#  }
#
class epel (
  # Common Params
  $ensure          = 'present',
  $release_uri     = 'http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm',
  $mirror_base_uri = 'https://mirrors.fedoraproject.org/metalink',
  $static_base_uri = 'http://download.fedoraproject.org/pub/epel',
  $use_mirror      = true,
  $failover_method = 'priority',
  $gpg_check       = true,
  # Main EPEL Repos
  $enable_epel           = true,
  $enable_epel_debuginfo = false,
  $enable_epel_source    = false,
  # Test EPEL Repos
  $enable_epel_testing           = true,
  $enable_epel_testing_debuginfo = false,
  $enable_epel_testing_source    = false,
) {
  
  if $::osfamily != 'RedHat' {
    fail('This module is only supported on Enterprise Linux based variants.')
  }
  
  # Validate our action
  validate_re($ensure, '^(present|absent)$', 'The ensure argument must be either "present" or "absent".')
  
  # If we're removing things we have all the information we need.
  if 'absent' == $ensure {
    
    package {'epel-release':
      ensure => 'purged',
    }
    
    file {'/etc/yum.repos.d/epel.repo':
      ensure => 'absent',
    }

    file {'/etc/yum.repos.d/epel-testing.repo':
      ensure => 'absent',
    }
    
  } else {
    
    # Stuff should be present so it's time to validate the rest of our input
    validate_string($release_uri)
    validate_bool($use_mirror)
    if $use_mirror {
      # Don't need the static param if we're using a mirror
      validate_string($mirror_base_uri)
    } else {
      # Don't need the mirror param if we're using a static repo
      validate_string($static_base_uri)
    }
    validate_re($failover_method, '^(priority|roundrobin)$', 'The failover_method argument must be either "priority" or "roundrobin".')
    validate_bool($gpg_check)
    validate_bool($enable_epel)
    validate_bool($enable_epel_debuginfo)
    validate_bool($enable_epel_source)
    validate_bool($enable_epel_testing)
    validate_bool($enable_epel_testing_debuginfo)
    validate_bool($enable_epel_testing_source)
    
    package {'epel-release':
      ensure   => 'latest',
      provider => 'rpm',
      source   => $release_uri,
    }
    
    file {'/etc/yum.repos.d/epel.repo':
      ensure  => 'file',
      content => template("${module_name}/etc/yum.repos.d/epel.repo.erb"),
      require => Package['epel-release'],
    }

    file {'/etc/yum.repos.d/epel-testing.repo':
      ensure  => 'file',
      content => template("${module_name}/etc/yum.repos.d/epel.repo.erb"),
      require => Package['epel-release'],
    }
  }
}
