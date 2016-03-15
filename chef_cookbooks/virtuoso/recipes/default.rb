#
# Cookbook Name::virtuoso 
# Recipe:: default
#
# Copyright 2015, Jyrki Oraskari
#


execute "apt-get update" do
  command "apt-get update"
end

package 'git' do
  action :install
end

package 'autotools-dev' do
  action :install
end

package 'automake' do
  action :install
end

package 'bison' do
  action :install
end

package 'flex' do
  action :install
end


package 'gperf' do
  action :install
end

package 'libtool' do
  action :install
end

package 'libssl-dev' do
  action :install
end


bash "install_program" do
  user "root"
  cwd "/tmp"
  code <<-EOH
       groupadd virtuoso
       useradd -s /bin/sh -g virtuoso -d /opt/virtuoso virtuoso
       cd /tmp
       mkdir install
       cd install
       git init
       git remote add -t 'develop/7' -f origin https://github.com/openlink/virtuoso-opensource.git
       git checkout 'develop/7'
       git remote rm origin
       ./autogen.sh 
       mkdir /opt/virtuoso
       ./configure --prefix=/opt/virtuoso
       make 
       echo "make install"
       make install
       cd /opt/virtuoso
       chown -R virtuoso:virtuoso *
  EOH
end

cookbook_file '/etc/init.d/virtuoso' do
  source 'virtuoso'
  owner 'root'
  group 'virtuoso'
  mode '0755'
  action :create
  notifies :run, "bash[start_virtuoso]", :immediately
end

bash "start_virtuoso" do
  user "root"
  cwd "/tmp"
  code <<-EOH
      sh /etc/init.d/virtuoso start
      cd /etc/init.d
      update-rc.d virtuoso defaults
      cd /opt/virtuoso
      ln -s /opt/virtuoso/var/lib/virtuoso/db db      
  EOH
  action :nothing
end

