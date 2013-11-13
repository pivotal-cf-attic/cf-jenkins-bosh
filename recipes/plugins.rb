plugins = [
  "git",
  "git-client",
  "github",
  "multiple-scms",
  "github-api",
  "ssh-credentials",
  "ssh-agent",
  "credentials",
  "git-parameter",
  "subversion",
  "promoted-builds",
  "conditional-buildstep",
  "maven-plugin",
  "javadoc",
  "mailer",
  "scm-api",
  "token-macro",
  "parameterized-trigger",
  "run-condition",
  "build-timeout",
  "ansicolor",
  "greenballs",
  "buildgraph-view",
  "build-flow-plugin",
  "iphoneview",
]

plugins.each do |plugin|
  jenkins_plugin plugin do
    action :install
  end
end
