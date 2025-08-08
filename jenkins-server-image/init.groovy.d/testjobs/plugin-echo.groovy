[
    name: 'Test-Plugin-echo',
    script: '''
        pipeline {
            agent {
                label 'UB16-MEDIUM'
            }
            stages {
                stage('Testing plugin echo') {
                    steps {
                        echo 'UB20-MEDIUM agent launched successfully'
                    }
                }
            }
        }
    '''
]
