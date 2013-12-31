require 'spec_helper'

describe 'cf-jenkins::pipeline_auth' do
  subject(:chef_run) do
    ChefSpec::Runner.new do |node|
      node.set['cf_jenkins']['ssl_passphrase'] = 'mypassphrase'
      node.set['cf_jenkins']['basic_auth_username'] = 'mybasicusername'
      node.set['cf_jenkins']['basic_auth_password'] = 'mybasicpassword'
    end.converge(described_recipe)
  end

  example { expect(chef_run.node['selfsigned_certificate']).to include(
    'destination' => '/var/lib/jenkins/ssl/',
    'sslpassphrase' => 'mypassphrase',
    'country' => 'us',
    'state' => 'ca',
    'city' => 'sf',
    'orga' => 'cf',
    'depart' => 'eng',
    'cn' => 'cf-eng',
    'email' => 'ssl@example.com',
  ) }

  example { expect(chef_run.node['jenkins']['http_proxy']).to include(
    'server_auth_method' => 'basic',
    'basic_auth_username' => 'mybasicusername',
    'basic_auth_password' => 'mybasicpassword',
  ) }

  example { expect(chef_run.node['jenkins']['http_proxy']['ssl']).to include(
    'enabled' => true,
    'redirect_http' => true,
    'cert_path' => '/var/lib/jenkins/ssl/server.crt',
    'key_path' => '/var/lib/jenkins/ssl/server.key',
  ) }
end
