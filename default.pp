
$username = 'tk'
$gui = true
$privileged = true

class dotfiles {
  file { "/home/$username/.vim":
    source  => "/home/$username/dotfiles/.vim",
    recurse => true
  }

  file { "/home/$username/.fonts":
    source  => "/home/$username/dotfiles/.fonts",
    recurse => true
  }

  file { "/home/$username/.vimrc":        source => "/home/$username/dotfiles/.vimrc" }
  file { "/home/$username/.bash_profile": source => "/home/$username/dotfiles/.bash_profile" }
  file { "/home/$username/.screenrc":     source => "/home/$username/dotfiles/.screenrc" }
  file { "/home/$username/.htoprc" :      source => "/home/$username/dotfiles/.htoprc" }
  file { "/home/$username/.conkyrc" :     source => "/home/$username/dotfiles/.conkyrc" }
}

class ruby_dev_environment {
  #Git gets brought in here, so let's make sure this happens before dotfiles
  class { 'rbenv': before                          => Class['dotfiles']}
  rbenv::plugin { 'sstephenson/ruby-build': latest => true }
  rbenv::build { '2.1.5': global                   => true }
}

class mypackages {
  ##Per-OS package selectors
  $vimpkg = $operatingsystem ? {
    ubuntu => 'vim-nox',
    debian => 'vim-nox',
    centos => 'vim-enhanced',
    redhat => 'vim-enhanced',
  }

  $gpgpkg = $operatingsystem ? {
    ubuntu => 'gnupg2',
    debian => 'gnupg2',
    centos => 'gpg',
    redhat => 'gpg',
  }

  #Package installs
  package { $vimpkg: ensure  => latest }
  package { $gpgpkg: ensure  => latest }
  package { 'screen': ensure => latest }
  package { 'htop': ensure   => latest }
  package { 'wget': ensure   => latest }
  package { 'curl': ensure   => latest }
  package { 'perl': ensure   => latest }
  package { 'ruby': ensure   => absent } #We have rbenv, so remove the package
  package { 'nmap': ensure   => latest }

  if $gui == true {
    package { 'conky': ensure => latest }
  }

}

vcsrepo { "/home/$username/dotfiles":
  ensure   => present,
  provider => git,
  source   => 'https://github.com/Karunamon/dotfiles.git',
  before   => Class['dotfiles'],
}

class sshsettings {
  if $privileged == true {
    augeas { "ssh_config":
      context => "/files/etc/ssh/ssh_config",
      changes => [
        "set TCPKeepAlive no",
        "set ClientAliveInterval 25",
        "set ClientAliveCountMax 3",
        "set GSSAPIAuthenticaton no",
        "set ForwardX11 yes",
        ],
    }
  }
}

include dotfiles
include mypackages
include ruby_dev_environment
include sshsettings
