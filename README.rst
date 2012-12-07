Puppet-buildout
---------------

Puppet-buildout is puppet module to setup zc.buildout environments.

If a source parameter is provided, it will get the source buildout
configuration to run the buildout. If path is supplied, it will use a
path relative to the buildout directory for the buildout configuration
file. If neither is specified, it will try and use an existing
buildout.cfg in the buildout directory.

Sample Usage::

  buildout::venv { "/my/buildout_dir":
    source => "puppet:///files/mybuildout.cfg",
    python => "/path/to/custom/python"
  }

  buildout:venv { "/other/buildout_dir":
    path => "special.cfg"
  }

  buildout:venv { "/default/buildout_dir": }
  
