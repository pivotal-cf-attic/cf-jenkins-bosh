@test "ruby is installed and on the path" {
  which ruby
}

@test "ruby is version 1.9.3-p448" {
  ruby --version | grep 1.9.3p448
}
