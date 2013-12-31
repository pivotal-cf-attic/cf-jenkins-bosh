node.set['selfsigned_certificate'] = {
  'destination' => '/var/lib/jenkins/ssl/',
  'sslpassphrase' => node['cf-jenkins']['ssl_passphrase'],
  'country' => 'us',
  'state' => 'ca',
  'city' => 'sf',
  'orga' => 'cf',
  'depart' => 'eng',
  'cn' => 'cf-eng',
  'email' => 'ssl@example.com',
}
node.set['jenkins']['http_proxy'] = {
  'server_auth_method' => 'basic',
  'basic_auth_username' => node['cf-jenkins']['basic_auth_username'],
  'basic_auth_password' => node['cf-jenkins']['basic_auth_password'],
  'ssl' => {
    'enabled' => true,
    'redirect_http' => true,
    'cert_path' => '/var/lib/jenkins/ssl/server.crt',
    'key_path' => '/var/lib/jenkins/ssl/server.key',
  }
}
