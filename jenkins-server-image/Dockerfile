FROM jenkins/jenkins:2.516.1

USER root

RUN apt-get update \
  && apt-get install --no-install-recommends -y \
    jq=1.6-2.1

USER jenkins

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
COPY --chown=jenkins:jenkins entrypoint.sh /usr/local/bin/entrypoint.sh
COPY --chown=jenkins:jenkins init.groovy.d /usr/share/jenkins/ref/init.groovy.d

RUN jenkins-plugin-cli --latest false -f /usr/share/jenkins/ref/plugins.txt

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
