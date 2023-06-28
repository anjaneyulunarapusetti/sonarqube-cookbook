#
# Cookbook:: sonarqube-cookbook
# Recipe:: sonarqube-recipe
#
# Copyright:: 2023, The Authors, All Rights Reserved.

# Install OpenJDK (Java Development Kit)
package 'openjdk-17-jdk' do
action :install
end



# Create a system user for SonarQube
user 'sonarqube' do
comment 'SonarQube User'
system true
shell '/bin/bash'
action :create
end



# Download SonarQube package
remote_file '/tmp/sonarqube.zip' do
source 'https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip'
owner 'root'
group 'root'
mode '0644'
action :create
end



# Extract the SonarQube package
execute 'extract_sonarqube' do
command 'unzip /tmp/sonarqube.zip -d /opt'
not_if { ::File.exist?('/opt/sonarqube-9.9.0.65466') }
action :run
end



execute 'configure_sonarqube' do
  command 'echo "sonar.embeddedDatabase.port=9092" >> /opt/sonarqube-9.9.0.65466/conf/sonar.properties '
action :run
end



execute 'change permission' do
  command 'chown -R sonarqube:sonarqube /opt/sonarqube-9.9.0.65466/'
action :run
end





# Set up SonarQube service
template '/etc/systemd/system/sonarqube.service' do
source 'sonarqube.service.erb'
owner 'sonarqube'
group 'sonarqube'
mode '0644'
notifies :restart, 'service[sonarqube]', :immediately
end



# Start and enable SonarQube service
service 'sonarqube' do
supports restart: true, status: true
action [:enable, :start]
end
