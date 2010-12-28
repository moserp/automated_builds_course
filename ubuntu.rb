require 'common'

policy :ubuntu, :roles => :app do
  requires :mtu
  requires :apt_sources

  requires :subversion
  requires :apache

  requires :sample_user
end

package :apache do
  requires :apache_binaries
  requires :apache_config
end

package :apache_binaries do
  apt 'apache2'
  apt 'libapache2-svn'
end

package :apache_config do
  # Replace the existing one, it's only got comments in it
  transfer 'dav_svn.conf', '/etc/apache2/mods-available/dav_svn.conf' do
    post :install, 'apache2ctl restart'
  end
end

package :subversion do
  requires :subversion_binaries
  requires :subversion_home
  requires :subversion_sample_project
end

package :subversion_binaries do
  apt 'subversion'
end

package :subversion_home do
  runner 'addgroup subversion'
  runner 'mkdir /home/svn'
end

package :subversion_sample_project do
  runner 'mkdir /home/svn/test_project'
  runner 'svnadmin create /home/svn/test_project'
  runner 'chown -R www-data:subversion /home/svn/test_project'
  runner 'chmod -R g+rws /home/svn/test_project'
end

package :sample_user do
  runner 'htpasswd -bc /etc/subversion/passwd testuser password'
end

package :apt_sources do
  push_text 'deb http://gb.archive.ubuntu.com/ubuntu/ lucid universe', '/etc/apt/sources.list'
  push_text 'deb-src http://gb.archive.ubuntu.com/ubuntu/ lucid universe', '/etc/apt/sources.list'
  push_text 'deb http://gb.archive.ubuntu.com/ubuntu/ lucid-updates universe', '/etc/apt/sources.list'
  push_text 'deb-src http://gb.archive.ubuntu.com/ubuntu/ lucid-updates universe', '/etc/apt/sources.list'
  noop do
    post :install, 'apt-get update'
  end
end

deployment do
  delivery :capistrano do
    set :user, 'root'
    role :app, '109.144.14.236', :primary => true
    default_run_options[:pty] = true
  end
end
