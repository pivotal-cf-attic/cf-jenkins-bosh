setup() {
  source /etc/profile.d/gvm.sh
}

@test "gvm is available" {
  which gvm
}

@test "go 1.1.2 is installed" {
  gvm use 1.1.2 && go version | grep 1.1.2
}

@test "default gvm script location" {
  grep 'export GVM_ROOT="/usr/local/share/gvm"' /etc/profile.d/gvm.sh
}
