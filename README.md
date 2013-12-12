# cf-jenkins

This repository is a Chef cookbook for configuring Jenkins for continuous integration of Cloud Foundry projects.

## Usage

### Running unit tests

To run the unit tests (using [ChefSpec](https://github.com/sethvargo/chefspec)):

```shell
bundle exec rspec
```

### Running integration tests

To run the [Test Kitchen](https://github.com/test-kitchen/test-kitchen) integration specs:

```shell
bundle exec kitchen test
```

However, that command can take an uncomfortably long time while you're iterating on changing the cookbook because it creates the VM from scratch every time.
The interesting subcommands to make it quicker to iterate are:

* `bundle exec kitchen create` to create the VM
* `bundle exec kitchen converge` to run the cookbook against the created VM
* `bundle exec kitchen verify` to actually run the tests against the converged VM
* `bundle exec kitchen login ubuntu` to start a session on the VM to inspect logs, e.g. when converge fails
* `bundle exec kitchen destroy` if you want to destroy the VM
