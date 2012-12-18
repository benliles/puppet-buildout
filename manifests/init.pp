# Definition: buildout
#
# setup buildout python environment
#
# Parameters:
#   $source  - source from which to grab buildout.cfg
#   $path    - relative path for buildout configuration file
#   $python  - the python interpreter to use
#   $ensure  - flag to setup or remove the buildout environment
#
# Actions:
#   setup buildout virtual python environment
#
# Requires:
#   $source must be set
#
# Sample Usage:
#
#    buildout { "/path/to/buildout_env":
#        source => "puppet:///files/mybuildout.cfg",
#        python => "/path/to/your/python",
#    }
#
class buildout {

  package { "python": }

  define venv (
    $source=false,
    $path="buildout.cfg",
    $owner=false,
    $group=false,
    $python='/usr/bin/python',
    $ensure=present,
    $refreshonly=false,
    $force=false,
  ) {
    if $ensure == present {
      $config = "${name}/${path}"

      if $owner != false {
        File { owner => $owner }
      }
      if $group != false {
        File { group => $group }
      }

      file { "${name}":
        ensure => directory
      }

      file { "${name}/bootstrap.py":
        source => "puppet:///modules/buildout/bootstrap.py",
        require => File["${name}"],
      }

      if $source {
        file { $config:
          source  => $source,
          require => File["${name}"]
        }
      }
      else {
        file { $config:
          require => File["${name}"],
        }
      }

      exec { "${python} ${name}/bootstrap.py":
        cwd         => "${name}",
        creates     => "${name}/bin/buildout",
        require     => [
          File["${name}/bootstrap.py"],
          File[$config],
        ],
      }
      exec { "${name}/bin/buildout -c ${config}":
        cwd         => "${name}",
        refreshonly => $refreshonly,
        subscribe   => [
          File[$config],
          Exec["${python} ${name}/bootstrap.py"],
        ],
        require    => [
          File[$config],
          Exec["${python} ${name}/bootstrap.py"],
        ],
      }
    } else {
      file { "${name}":
        ensure => absent,
        force => true,
      }
    }
  }
}
