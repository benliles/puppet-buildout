# Class: buildout
#
# This module manages buildout and provides a define for setting up buildout
# environments.
#
class buildout {

    package { "python": }

    # Definition: buildout::venv
    #
    # setup buildout virtual python environment
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
    #    buildout::venv { "/path/to/buildout_env":
    #        source => "puppet:///files/mybuildout.cfg",
    #        python => "/path/to/your/python",
    #    }
    #
    define venv($source=false, $path=false, $owner=false, $group=false, $python='/usr/bin/python', $ensure=present) {
        if $path {
            $config = "$name/buildout.cfg"
        } else {
            $config = "$name/buildout.cfg"
        }

        if $owner != false {
            File { owner => $owner }
        }
        if $group != false {
            File { group => $group }
        }

        if $ensure == present {
            file { $name:
                ensure => directory
            }
            
            file { "$name/bootstrap.py":
                source => "puppet:///modules/buildout/bootstrap.py",
                require => File[$name],
            }
            if $source {
              file { $config:
                source  => $source,
                require => File[$name]
              }
            }
            else {
                file { $config:
                    require => File[$name],
                }
            }
            exec { "${python} $name/bootstrap.py":
                cwd     => $name,
                require => [File["$name/bootstrap.py"], File[$config]],
                creates => "$name/bin/buildout",
            }
            exec { "$name/bin/buildout -c $config":
                cwd => $name,
                require => [
                    Exec["${python} $name/bootstrap.py"],
                    File[$config]],
                subscribe => File[$config],
                refreshonly => true,
            }
        } else {
            file { "$name":
                ensure => absent,
                force => true,
            }
        }
    }
}
