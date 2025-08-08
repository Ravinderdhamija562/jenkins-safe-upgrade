[
    name: 'Test-Plugin-pwd',
    script: '''
        pipeline {
            agent any
            stages {
                stage('Initialize') {
                    steps {
                        script {
                            def workspaceDir = pwd()
                            echo "Current Workspace Directory: ${workspaceDir}"
                        }
                    }
                }
            }
        }
    '''
]
