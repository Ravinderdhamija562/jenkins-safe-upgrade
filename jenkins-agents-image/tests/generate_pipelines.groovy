// generate_pipelines.groovy - This script runs within the Jenkins Seed Job's workspace

import groovy.json.JsonSlurper // This should be available in your Jenkins 2.462.1 LTS environment

println "Running generate_pipelines.groovy script"

def jobConfigsDir = new File('/var/jenkins_home/workspace/Job-Generator-Seed/Jenkins/jenkins-agents-image/tests/job_configs')// 'pwd()' is available in Jenkins Pipelines

if (!jobConfigsDir.exists() || !jobConfigsDir.isDirectory()) {
    // Using 'error' will fail the build, which is good for automation if configs are missing
    throw new RuntimeException("Job configurations directory '${jobConfigsDir.getAbsolutePath()}' not found or is not a directory. Please check the hardcoded path in generate_pipelines.groovy.")
}

def jobFolders = jobConfigsDir.listFiles().findAll { it.isDirectory() }

if (jobFolders.isEmpty()) {
    println "No job configuration folders found in '${jobConfigsDir.getAbsolutePath()}'."
    return
}

jobFolders.each { jobFolder ->
    def configFile = new File(jobFolder, 'config.json')

    if (!configFile.exists()) {
        println "Skipping folder '${jobFolder.name}': No config.json found."
        return
    }

    println "Processing configuration for job: ${jobFolder.name} from ${configFile.name}"

    def config
    try {
        config = new JsonSlurper().parse(configFile)
    } catch (Exception e) {
        println "Error parsing config for '${jobFolder.name}': ${e.message}"
        return
    }

    // --- Job DSL Definition Starts Here ---
    // Job DSL methods like 'pipelineJob', 'scm', 'triggers' etc., are directly available here
    pipelineJob(config.jobName) {
        description(config.description ?: "Auto-generated pipeline job for ${config.jobName}")

        definition {
            scm {
                git {
                    remote {
                        url config.gitRepo
                        if (config.credentialsId) {
                            credentials config.credentialsId
                        }
                    }
                    branch config.gitBranch
                }
                scriptPath(config.jenkinsfilePath ?: 'Jenkinsfile')
                lightweight(true) // Enable lightweight checkout for better performance
            }
        }

        if (config.parameters) {
            parameters {
                config.parameters.each { param ->
                    if (param.type == 'string') {
                        stringParam(param.name, param.defaultValue ?: '', param.description ?: '')
                    }
                    // Add other parameter types like booleanParam, choiceParam as needed
                }
            }
        }
        // ... add more common Job DSL configurations as needed (e.g., disable, properties)
    }
    // --- Job DSL Definition Ends Here ---
}