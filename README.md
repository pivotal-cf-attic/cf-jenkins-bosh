# cf-jenkins

[![Build Status](https://travis-ci.org/pivotal-cf-experimental/cf-jenkins.png)](https://travis-ci.org/pivotal-cf-experimental/cf-jenkins)

This repository is a Chef cookbook for configuring Jenkins for continuous integration of Cloud Foundry projects.

## Usage

### Running unit tests

To run the unit tests (using [ChefSpec](https://github.com/sethvargo/chefspec)):

```shell
bundle exec rake spec:unit
```

### Running integration tests

After installing vagrant and the omnibus Chef plugin:

```shell
brew install vagrant
vagrant plugin install vagrant-omnibus
```

To run the integration specs:

```shell
bundle exec rake spec:integration
```

However, that command can take an uncomfortably long time while you're iterating on changing the cookbook because it creates the VM from scratch every time.
A faster way to iterate would be to run the vagrant commands manually and run the tests using RSpec directly.

```shell
vagrant up
bundle exec rspec spec/integration
```

Upon changing code in the cookbook, you can re-provision the Vagrant VMs individually to cut down on waiting.

```shell
vagrant provision {master,slave}
```
