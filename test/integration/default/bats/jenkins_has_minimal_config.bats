@test "installing and running a jenkins job which requires gvm, go1.1.2, chruby, and ruby 1.9.3" {
  curl -s -X POST http://127.0.0.1:8080/job/dummy_job/build

  while true; do
    curl -s http://localhost:8080/job/dummy_job/api/json > /tmp/job.json

    build_status="Build failed."
    if grep --silent -v '"color":"notbuilt"' /tmp/job.json; then
      if grep --silent -v '"color":"red"' /tmp/job.json; then
        build_status="Build succeeded."
      fi
      break;
    fi
  done

  curl -s http://localhost:8080/job/dummy_job/lastBuild/consoleText # info for debugging displays on failure

  [ "${build_status}" = "Build succeeded." ]
}
