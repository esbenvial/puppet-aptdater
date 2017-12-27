class { '::aptdater':
  sudo_enable => false,
  export_host => false,
  publickeys  => [
    {
      "key" => "testkey",
      "name" => "testkey",
      "type" => "ssh-ed25519"
    },

  ],
}
