// create_jobs.groovy - adapted for JSON parsing
// NO @Grab required for JsonSlurper
// import groovy.yaml.YamlSlurper // REMOVE THIS LINE
import groovy.json.JsonSlurper // THIS SHOULD BE AVAILABLE

// Standard Jenkins API imports
import jenkins.model.Jenkins
import hudson.model.FreeStyleProject
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import hudson.plugins.git.GitSCM
import hudson.plugins.git.UserRemoteConfig
import hudson.plugins.git.BranchSpec
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition
import hudson.model.ParametersDefinitionProperty
import hudson.model.StringParameterDefinition


// Define the base directory where your job_configs folder is located
// This path should be relative to where you execute the jenkins-cli.jar command
// def baseDir = new File('.')
// def jobConfigsDir = new File(baseDir, 'job_configs')

// println "DEBUG: Current Working Directory (baseDir): ${baseDir.getAbsolutePath()}"
// println "DEBUG: Attempting to find Job Configs Directory at: ${jobConfigsDir.getAbsolutePath()}"
// println "DEBUG: Does jobConfigsDir exist? ${jobConfigsDir.exists()}"
// println "DEBUG: Is jobConfigsDir a directory? ${jobConfigsDir.isDirectory()}"
// println "DEBUG: Is jobConfigsDir readable? ${jobConfigsDir.canRead()}"

def jobConfigsDir = new File('<path_to_your_job_configs_directory>') // Replace with your actual path
println "DEBUG: Job Configs Directory: ${jobConfigsDir.getAbsolutePath()}"

if (!jobConfigsDir.exists() || !jobConfigsDir.isDirectory()) {
    println "Error: Job configurations directory '${jobConfigsDir.getAbsolutePath()}' not found or is not a directory."
    throw new RuntimeException("Job configs directory missing.")
}

def jobFolders = jobConfigsDir.listFiles().findAll { it.isDirectory() }

if (jobFolders.isEmpty()) {
    println "No job configuration folders found in '${jobConfigsDir.getAbsolutePath()}'."
    return
}

def jenkins = Jenkins.instance

jobFolders.each { jobFolder ->
    // Only look for config.json now
    def configFile = new File(jobFolder, 'config.json')

    if (!configFile.exists()) {
        println "Skipping folder '${jobFolder.name}': No config.json found."
        return
    }

    println "Processing configuration for job: ${jobFolder.name} from ${configFile.name}"

    def config
    try {
        // Use JsonSlurper for JSON files
        config = new JsonSlurper().parse(configFile.text)
    } catch (Exception e) {
        println "Error parsing config for '${jobFolder.name}': ${e.message}"
        return
    }

    def jobName = config.jobName
    def existingJob = jenkins.getItem(jobName)

    if (existingJob) {
        println "Job '${jobName}' already exists. Deleting to recreate for update simplicity..."
        existingJob.delete()
    }

    def newJob = new WorkflowJob(jenkins, jobName)
    jenkins.add(newJob, jobName)

    def scm = new GitSCM(
        [new UserRemoteConfig(config.gitRepo, null, null, config.credentialsId)],
        [new BranchSpec(config.gitBranch ? "*/${config.gitBranch}" : '*/main')],
        false,
        [],
        null,
        null,
        []
    )

    def flowDefinition = new CpsScmFlowDefinition(scm, config.jenkinsfilePath ?: 'Jenkinsfile')
    flowDefinition.setLightweight(true)
    newJob.definition = flowDefinition

    newJob.description = config.description ?: "Auto-generated pipeline job for ${jobName}"

    if (config.parameters) {
        def jobProperty = new ParametersDefinitionProperty()
        config.parameters.each { param ->
            if (param.type == 'string') {
                jobProperty.parameterDefinitions.add(new StringParameterDefinition(param.name, param.defaultValue ?: '', param.description ?: ''))
            }
            // Add other parameter types (BooleanParameterDefinition, ChoiceParameterDefinition, etc.) if needed
        }
        newJob.addProperty(jobProperty)
    }

    newJob.save()
    println "Successfully created/updated job: ${jobName}"
}

println "Job creation/update process finished."