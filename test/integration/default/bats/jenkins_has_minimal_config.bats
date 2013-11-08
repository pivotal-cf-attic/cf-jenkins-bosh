@test "installing and running a jenkins job which requires gvm, go1.1.2, chruby, and ruby 1.9.3" {
  curl -s -X POST http://127.0.0.1:8080/job/dummy_job/build

  while true; do
    curl -s http://localhost:8080/job/dummy_job/api/json > /tmp/job.json

    build_status=1
    if grep --silent -v '"color":"notbuilt"' /tmp/job.json; then
      if grep --silent '"color":"red"' /tmp/job.json; then
        echo "Build failed."
      else
        echo "Build succeeded."
        build_status=0
      fi
      break;
    fi
  done

  return ${build_status}
}
