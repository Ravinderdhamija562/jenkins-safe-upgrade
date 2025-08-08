[
    name: 'Test-artifactory-download',
    script: """
        pipeline {
            agent {
                label 'UB20-MEDIUM'
            }
            stages {
                stage('Artifactory setup') {
                    steps {
                        script {
                            withCredentials([
                                usernamePassword(credentialsId: 'ARTIFACTORY_DOCKER_LOGIN', passwordVariable: 'ART_PASS', usernameVariable: 'ART_USER')
                            ]) {
                                    sh '''
                                            curl -f --connect-timeout 10 \
                                            --max-time 30 \
                                            --retry 20 \
                                             --retry-delay 30 \
                                             --retry-max-time 900 \
                                             https://artifactory-rd.company.io/artifactory/ep-tools/jfrog-cli/v2-jf/2.49.1/scripts/install-cli.sh \
                                            | sudo bash -s -- 2.49.1

                                            sudo chown -f nsadmin:nsadmin /usr/local/bin/jf
                                            jf -v

                                            jf config add artifactory-hen \
                                            --interactive=false \
                                            --artifactory-url="https://artifactory-ep-hen.company.io/artifactory/" \
                                            --user=\${ART_USER} --password=\${ART_PASS}

                                            jf config add artifactory-rd \
                                            --interactive=false \
                                            --artifactory-url="https://artifactory-rd.company.io/artifactory/" \
                                            --user=\${ART_USER} --password=\${ART_PASS}
                                            jf config show

                                            jf rt download ep-tools/jfrog-cli/v2-jf/2.49.1/scripts/install-cli.sh .  --server-id=artifactory-rd
                                    '''
                                }
                        }
                    }
                }
                stage('Testing artifactory hen download') {
                    steps {
                        script {
                            withCredentials([
                                usernamePassword(credentialsId: 'ARTIFACTORY_DOCKER_LOGIN', passwordVariable: 'ART_PASS', usernameVariable: 'ART_USER')
                            ]) {
                                    sh '''
                                            jf config show
                                            jf rt download ep-tools/jfrog-cli/v2-jf/2.49.1/scripts/install-cli.sh .  --server-id=artifactory-rd
                                    '''
                                }
                        }
                    }
                }
            }
        }
    """
]
