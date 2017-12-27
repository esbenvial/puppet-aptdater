# apt-dater
class aptdater (
  String $uid             = '5001',
  String $gid             = '5001',
  String $group           = 'apt-dater',
  String $user            = 'apt-dater',
  String $homedir         = '/var/lib/apt-dater',
  Array[Hash] $publickeys = [],
  Boolean $sudo_enable    = true,
  Boolean $export_host    = true,
) {
  group { $group:
    ensure => present,
    gid    => $gid,
  }

  $publickeys.each |Hash $key| {
    ssh_authorized_key  { "${user}-${key['name']}":
      ensure => present,
      key    => $key['key'],
      type   => $key['type'],
      user   => $user,
    }
  }

  if $export_host {
    @@aptdater::host { $facts['hostname']: }
  }

  user { $user:
    ensure  => present,
    uid     => $uid,
    gid     => $gid,
    shell   => '/bin/bash',
    require => Group[$group],
    home    => $homedir,
  }

  package {'apt-dater':
    ensure  => present,
    require => User['apt-dater'],
  }

  if $sudo_enable {
    sudo::conf { $user:
      priority => 20,
      content  => "$user ALL=NOPASSWD: /usr/bin/apt-get, /usr/bin/aptitude",
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

  file { $homedir:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0775',
    require => User[$user],
  }
}
