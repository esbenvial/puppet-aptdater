# apt-dater
class aptdater (
  String $user            = 'apt-dater',
  String $homedir         = '/var/lib/apt-dater',
  Array[Hash] $publickeys = [],
  Boolean $sudo_enable    = true,
  Boolean $export_host    = true,
) {
  $publickeys.each |Hash $key| {
    ssh_authorized_key  { "${user}-${key['name']}":
      ensure  => present,
      key     => $key['key'],
      type    => $key['type'],
      user    => $user,
      require => User[$user],
    }
  }

  if $export_host {
    @@aptdater::host { $facts['hostname']: }
  }

  user { $user:
    ensure     => present,
    shell      => '/bin/bash',
    home       => $homedir,
    managehome => true,
    system     => true,
  }

  package {'apt-dater':
    ensure  => present,
    require => User['apt-dater'],
  }

  if $sudo_enable {
    sudo::conf { $user:
      priority => 20,
      content  => "${user} ALL=NOPASSWD: /usr/bin/apt-get, /usr/bin/aptitude",
      require  => User[$user],
    }
  }

  package {'apt-dater-host':
    ensure  => present,
    require => User[$user],
  }

  package {'imvirt':
    ensure => present,
  }
}
