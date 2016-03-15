#
# Cookbook Name:: tomcat
# Recipe:: default
#
# Copyright 2016, Jyrki Oraskari
#

execute "apt-get update" do
  command "apt-get update"
end

package 'software-properties-common python-software-properties' do
  action :install
end

execute "add-apt-repository -y ppa:openjdk-r/ppa" do
  user "root"
  command "add-apt-repository -y ppa:openjdk-r/ppa"
end

execute "apt-get update" do
  user "root"
  command "apt-get update"
end

package 'openjdk-8-jdk' do
  action :install
end

package 'git' do
  action :install
end

package 'ant' do
  action :install
end


bash "install_program" do
  user "root"
  cwd "/tmp"
  code <<-EOH
    groupadd tomcat
    useradd -s /bin/sh -g tomcat -d /opt/tomcat tomcat

    cd /tmp
    git clone https://github.com/apache/tomcat80.git
    cd tomcat80
    ant
    mv /tmp/tomcat80/output/build /opt/tomcat

    rm -f /tmp/*
    cd /opt/tomcat
    mkdir work
    chown -R tomcat:tomcat * 
    chmod g+rwx *
    chmod g+r conf/*
    ln -s /etc/init.d/tomcat /etc/rc1.d/K99tomcat
    ln -s /etc/init.d/tomcat /etc/rc2.d/S99tomcat
    cd /opt/tomcat/webapps
    rm -r ROOT
    rm -r docs
    rm -r examples
    rm -r manager
    rm -r host*

    iptables -A INPUT -i eth0 -p tcp --dport 80 -j ACCEPT

    apt-get install authbind
    touch /etc/authbind/byport/80
    chmod 500 /etc/authbind/byport/80
    chown tomcat /etc/authbind/byport/80
  EOH
end

cookbook_file '/opt/tomcat/bin/startup.sh' do
  source 'startup.sh'
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
  action :create
end


cookbook_file '/opt/tomcat/conf/server.xml' do
  source 'server.xml'
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
  action :create
end


cookbook_file '/etc/init.d/tomcat' do
  source 'tomcat'
  owner 'root'
  group 'tomcat'
  mode '0755'
  action :create
  notifies :run, "bash[start_tomcat]", :immediately
end

bash "start_tomcat" do
  user "root"
  cwd "/tmp"
  code <<-EOH
      sh /etc/init.d/tomcat start    
  EOH
  action :nothing
end

