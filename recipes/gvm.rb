%w(curl git mercurial make binutils bison gcc).each do |pkg|
  package pkg do
    action :install
  end
end

gvm_installer = ::File.join(Chef::Config[:file_cache_path], 'gvm-installer')

gvm_destination = '/usr/local/share'
gvm_script = ::File.join(gvm_destination, 'gvm', 'scripts', 'gvm')

remote_file gvm_installer do
  source 'https://raw.github.com/moovweb/gvm/master/binscripts/gvm-installer'
  mode 0755
end

bash 'install GVM' do
  code "#{gvm_installer} master #{gvm_destination}"
  not_if { ::File.exists?(gvm_script) }
end

bash 'install go 1.1.2' do
  code "source #{gvm_script} && gvm install go1.1.2"
end

file '/etc/profile.d/gvm.sh' do
  mode 0755
  content <<-EOF
#!/bin/sh

export GVM_ROOT="#{gvm_destination}/gvm"

[[ -s "$GVM_ROOT/scripts/gvm" ]] && . "$GVM_ROOT/scripts/gvm"
EOF
end
