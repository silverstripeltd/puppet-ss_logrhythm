# Setup LogRhythm agent
# Install and configure packages and assume firewall allows connections
# Packages will be downloaded from s3://ss-packages/logrhythm (publicly accessible)
class ss_logrhythm::agent (
  Variant[Stdlib::HTTPSUrl,Stdlib::HttpUrl] $package_url,    # Agent public accessible .deb pachake URL (eg. https://s3-ap-southeast-2.amazonaws.com/ss-packages/logrhythm/scsm-x.x.x.xxxx-xx_amd64.deb)
  Stdlib::Compat::Ip_address                $agent_mediator, # Mediator hostname our platform agent server(s) send requests (eg. Advantage)
) inherits ss_logrhythm {

  # Install SCSM
  package { 'scsm':
    ensure   => installed,
    provider => dpkg,
    source   => "${$package_url}"
  }
  
  # Configure SCSM with default settings
  file { '/opt/logrhythm/scsm/config/scsm.ini':
    ensure  => 'present',
    replace => 'no',
    content => template('ss_logrhythm/scsm.ini.erb'),
    owner   => root,
    group   => root,
    mode    => '0666',
    require => Package['scsm'],
  }
  
  # Ensure SCSM service is running
  service {'scsm':
    ensure    => running,
    enable    => true,
    subscribe => File['/opt/logrhythm/scsm/config/scsm.ini'],
  }
  
}
