# Setup LogRhythm client
# Client forwards rsyslog logs to agent server
class ss_logrhythm::vector (
  Stdlib::Compat::Ip_address $listen_ip   = '0.0.0.0', # IP Address of agent to listen
  Integer                    $listen_port = 6514,      # Port used to pass Syslog data to Vector agent
  String                     $listen_mode = 'udp',     # Mode used to listen (tcp,udp)
) inherits ss_logrhythm {

  # Add Vector.dev apt source for installing Vector package
  apt::source { 'vector':
    comment  => 'Mirror for Vector.dev package',
    location    => 'https://repositories.timber.io/public/vector/deb/ubuntu',
    release     => $::lsbdistcodename,
    repos       => 'main',
    require     => [
      Package['apt-transport-https', 'ca-certificates']
    ],
    key         => {
      'id' => '1E46C153E9EFA24018C36F753543DB2D0A2BC4B8',
      'source' => 'https://repositories.timber.io/public/vector/gpg.3543DB2D0A2BC4B8.key',
    },
  }

  # Install Vector package
  package { 'vector': 
    ensure => 'present',
  }

  Class['apt::update'] -> Package['vector']

  # Configure Vector with default settings
  # Expects the following to be provided via environment variables in /etc/defaults/vector
  #  - STREAM_NAME
  #  - ROLE_ARN
  #  - REGION
  #  - HOSTNAME
  file { '/etc/vector/vector.toml':
    ensure  => 'present',
    content => template('ss_logrhythm/vector.toml.erb'),
    owner   => root,
    group   => root,
    mode    => '0644',
    require => Package['vector'],
  }
}
