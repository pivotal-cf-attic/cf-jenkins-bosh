aws_elastic_ip "runtime prod jenkins" do
  aws_access_key node['aws']['access_key']
  aws_secret_access_key node['aws']['secret_access_key']
  ip node['aws']['elastic_ip']
  action :associate
end

aws_ebs_volume "db_ebs_volume" do
  aws_access_key node['aws']['access_key']
  aws_secret_access_key node['aws']['secret_access_key']
  volume_id node['aws']['ebs_volume_id']
  device "/dev/sdi"
  action :attach
  notifies :run, 'execute[format drive]', :immediately
end

execute "format drive" do
  command "mkfs -t ext4 /dev/xvdi"
  not_if "file -s /dev/xvdi | grep ext4"
  action :nothing
  notifies :create, 'directory[/mnt/jenkins]', :immediately
end

directory "/mnt/jenkins" do
  owner "root"
  group "root"
  mode 00644
  action :nothing
  notifies :enable, 'mount[/mnt/jenkins]', :immediately
end

mount "/mnt/jenkins" do
  device "/dev/xvdi"
  fstype "ext4"
  action :nothing
end
