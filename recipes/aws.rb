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
  action [ :attach ]
end
