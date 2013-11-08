if node['aws']['access_key'] && node['aws']['secret_access_key']
  if node['aws']['elastic_ip']
    aws_elastic_ip 'jenkins ip' do
      aws_access_key node['aws']['access_key']
      aws_secret_access_key node['aws']['secret_access_key']
      ip node['aws']['elastic_ip']
      action :associate
    end
  end

  if node['aws']['ebs_volume_id']
    aws_ebs_volume 'jenkins_ebs_home' do
      aws_access_key node['aws']['access_key']
      aws_secret_access_key node['aws']['secret_access_key']
      volume_id node['aws']['ebs_volume_id']
      device '/dev/sdi'
      action :attach
    end

    execute 'format drive' do
      command 'mkfs -t ext4 /dev/xvdi'
      not_if 'file -s /dev/xvdi | grep ext4'
    end

    directory node[:jenkins][:server][:home] do
      owner 'root'
      group 'root'
      mode 00644
    end

    mount node[:jenkins][:server][:home] do
      device '/dev/xvdi'
      fstype 'ext4'
      action [:mount, :enable]
    end
  end
end
