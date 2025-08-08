[
    name: 'Test-Plugin-checkout',
    script: '''
        pipeline {
            agent any
            stages {
                stage('Testing checkout plugin') {
                    steps {
                        script {
                            checkout scmGit(branches: [[name: '*/develop']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-https', url: 'https://github.com/company/sandbox.git']])
                        }
                    }
                }
            }
        }
    '''
]
