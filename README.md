# puppet-epel [![Build Status](https://secure.travis-ci.org/jstuart/puppet-epel.png)](http://travis-ci.org/jstuart/puppet-epel)
https://github.com/jstuart/puppet-epel

Manage EPEL installation via Puppet

You should look at the [EPEL module](https://github.com/stahnma/puppet-module-epel) by [Michael Stahnke](https://github.com/stahnma) which will likely better meet your needs.

## Usage

### Load using default configuration parameters

This will use the default public Fedora URIs. 

Load the module via Puppet Code or your ENC.

```puppet
    include epel
```

### Load using a static internal mirror

```puppet
  class { 'epel':
    release_uri     => 'http://yum.internal/epel/epel-release-latest-6.noarch.rpm',
    use_mirror      => false,
    static_base_uri => 'http://yum.internal/epel/6',
  }
```