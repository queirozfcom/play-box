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
	
	exec{'download chrome deb':
		require => Class['fix_broken'],
		command => 'wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb',
		cwd => "/home/${username}/Downloads",
		creates => "/home/${username}/Downloads/google-chrome-stable_current_i386.deb",
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
	
	package{'xubuntu-desktop':
		ensure => 'installed',
		install_options => ['--no-install-recommends'],
		require => Class['chrome','fix_broken','java','home','sublime','git'],
	} ->
	package{'xubuntu-icon-theme':
		ensure => 'installed',
	} ->
	exec{'dpkg-reconfigure':
		command => 'dpkg-reconfigure lightdm',
	} ->
	file_line {'screen lock is false':
		ensure => 'present',
		path => '/etc/default/acpi-support',
		line => 'LOCK_SCREEN=false',
	} ->
	file_line{'screen lock is not true':
		ensure => 'absent',
		path => '/etc/default/acpi-support',
		line => 'LOCK_SCREEN=true',		
	} ->
	exec{'reboot':
		command => 'reboot',
	}
}

class java{
	require fix_broken
	package{'openjdk-7-jdk':
		ensure =>'installed',
	}
}

include git
include gui
include sublime
include chrome
include home
include fix_broken
include java


