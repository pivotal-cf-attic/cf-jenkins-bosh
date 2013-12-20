%w(
  git
  parameterized-trigger
).each do |plugin|
  jenkins_plugin plugin do
    action :install
  end
end
