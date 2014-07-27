$username='vagrant'
$project = 'play_proj'

$inc_file_path = '/vagrant/manifests/files'

# tell puppet what to prepend to commands
Exec { 
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/","/usr/local/bin" ]
}

# a command to run system updates
exec { 'sys_update':
    command => "apt-get update --fix-missing",
}

class git {
    package{'git-core':
        ensure => 'installed',
        require => Exec['sys_update'],
    }
}

class home{
    user { "${username}":
      ensure     => "present",
      managehome => true,
      system => true,
      shell => "/bin/bash",
      home => "/home/${username}",
    } ->
    file { "/home/${username}/Downloads":
        ensure => 'directory',
        owner => "${username}",
    } ->
    file { "/home/${username}/Desktop":
        ensure => 'directory',
        owner => "${username}",
    }
}

class sublime{
    
    exec{'download':
        require => Class['home'],
        command => "wget http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2.tar.bz2",
        cwd => "/home/${username}/Downloads",
        # only if it hasn't already been done.
        creates => "/home/${username}/Downloads/Sublime\\ Text\\ 2.0.2.tar.bz2",
    } ->
    exec{'extract':
        command => "tar -jxvf Sublime\\ Text\\ 2.0.2.tar.bz2",
        cwd => "/home/${username}/Downloads",
        creates =>"/home/${username}/Downloads/Sublime\\ Text\\ 2",
    } ->
    exec {'create desktop link':
        command => "ln -s /home/${username}/Downloads/Sublime\\ Text\\ 2/sublime_text /home/${username}/Desktop/sublime_text",
        creates => "/home/${username}/Desktop/sublime_text",
    }   
}

class chrome{
    require fix_broken
    exec{'download chrome deb':
        command => 'wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb',
        cwd => "/home/${username}/Downloads",
        creates => "/home/${username}/Downloads/google-chrome-stable_current_i386.deb",
    } ->
    exec{'install stuff needed for chrome':
      command =>'apt-get install libappindicator1 libdbusmenu-gtk4 libfile-desktopentry-perl libfile-mimeinfo-perl libindicator7 libxss1 xdg-utils --assume-yes',
    } ->
    exec{'install chrome':
        command => 'dpkg -i google-chrome-stable_current_i386.deb',
        cwd => "/home/${username}/Downloads",
        creates => "/usr/bin/google-chrome",
    } -> 
    exec{'add shortcuts to desktop':
        command => "ln -s /usr/bin/google-chrome /home/${username}/Desktop/google-chrome",
        creates => "/home/${username}/Desktop/google-chrome",
    } ->
    exec{'set permissions':
        command =>"chmod +x /home/${username}/Desktop/*",
        provider => 'shell',
    }
}

class fix_broken{
    exec{'fix-broken-command':
        command => 'apt-get -f install --assume-yes',
    }
}

class gui{

  package{'xfce4':
    require => Exec['sys_update'],
    ensure => 'installed'       
  } ->
  package {'lightdm':
    ensure => 'installed',    
  } ->
  package {'lightdm-gtk-greeter':
    ensure => 'installed',
  } ->
  file {'/etc/lightdm/lightdm.conf':
    ensure => 'present',
    owner => 'root',
    content => "[SeatDefaults] \r\n greeter-session=lightdm-gtk-greeter",
  } ->
  service {'lightdm':
    ensure => 'running',
    enable => true,
  }
}

class java{
    require fix_broken
    package{'openjdk-7-jdk':
        ensure =>'installed',
    }
}

class scala{
  require java
  require home
  exec{'download activator':
    command => "wget http://downloads.typesafe.com/typesafe-activator/1.2.3/typesafe-activator-1.2.3.zip",
    cwd => "/home/${username}/Downloads",
    creates => "/home/${username}/Downloads/typesafe-activator-1.2.3.zip",
    user => "${username}",
  }->
  package{'unzip':
    ensure => 'installed',
  } ->
  exec{'unzip activator package':
    command => "unzip typesafe-activator-1.2.3.zip",
    cwd => "/home/${username}/Downloads",
    creates => "/home/${username}/Downloads/activator-1.2.3/",
  } ->
  exec {'add shortcut to desktop':
    command => "ln -s /home/${username}/activator-1.2.3/activator /home/${username}/Desktop/activator",
    creates => "/home/${username}/Desktop/activator",
  } ->
  exec{'set execution permission for the shortcut':
    command => "chmod +x /home/${username}/Desktop/activator",
  } ->
  file_line{'add activator to path':
    line => "PATH=$PATH:/home/${username}/Downloads/activator-1.2.3",
    ensure => 'present',
    path => "/home/${username}/.bashrc",
  }

}

include git
include gui
include sublime
include chrome
include home
include fix_broken
include java
include scala


