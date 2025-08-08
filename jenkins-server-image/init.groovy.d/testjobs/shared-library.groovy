[
    name: 'Test-shared-library',
    script: '''
        @Library('ns_pipeline_library')_
        pipeline {
            agent any
            stages {
                stage('Testing shared library') {
                    steps {
                        script {
                            ns_pipeline.get_rd_artifactory()
                        }
                    }
                }
            }
        }
    '''
]
