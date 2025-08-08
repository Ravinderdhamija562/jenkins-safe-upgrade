#!/bin/bash

test_setup() {
  if [ "${TEST_SETUP}" != "true" ]; then
    return
  fi

  echo "Default JENKINS_HOME is set to ${JENKINS_HOME}"
}

test_setup

#exec /usr/local/bin/jenkins.sh
exec /usr/bin/tini -- /usr/local/bin/jenkins.sh "$@"
