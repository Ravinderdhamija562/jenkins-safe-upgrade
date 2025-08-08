[
    name: 'Test-Plugin-mailext',
    script: """
        pipeline {
            agent any

            environment {
                EMAIL_ADDRESS = "<your-email@example.com>"
    	    }
            stages {
                stage('Testing plugin mailext') {
                    steps {
                        script {
                            def emailBody = '''
                            Dear Team,

This is a test email sent to verify the functionality of the emailext plugin in our Jenkins setup.

If you have received this email, it confirms that the email notification feature is working correctly.

Please do not respond to this email as it is only intended for testing purposes.

Thank you.
                            '''
                            emailext body: emailBody, subject: 'Test Email for Jenkins emailext Plugin Functionality', to: "\${env.EMAIL_ADDRESS}"
                        }
                    }
                }
                stage('Verify Email Sent') {
                    steps {
                        script {
                            // Check logs for email success/failure messages
                            def log = currentBuild.rawBuild.getLog(100) // Get last 100 lines of logs
                            if (log.join('\\n').contains('FAILURE')) {
                                error("Email failed: Success message not found in logs.")
                            }
                        }
                    }
                }
            }
        }
    """
]
