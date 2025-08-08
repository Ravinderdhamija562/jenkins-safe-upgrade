import jenkins.model.*
import hudson.model.*
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import java.text.SimpleDateFormat

def jenkins = Jenkins.instance
def jobs = jenkins.getAllItems(WorkflowJob)
def delimiter = ",,"

def dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss")

// Print CSV Header
println "Job Name${delimiter}Enabled${delimiter}Pipeline Type${delimiter}SCM Repository${delimiter}Branch${delimiter}Cron Schedule${delimiter}SCM Schedule${delimiter}Created On${delimiter}Created By${delimiter}Last Executed${delimiter}Last Successful${delimiter}Last Modified By${delimiter}Consecutive Failures"

jobs.each { job ->
    def isEnabled = !job.isDisabled()
    def pipelineType = "Pipeline"
    def scmRepo = "N/A"
    def branch = "N/A"
    def cronSchedule = "N/A"
    def scmSchedule = "N/A"
    def createdOn = "N/A"
    def createdBy = "Unknown"
    def lastExecuted = "N/A"
    def lastSuccessful = "N/A"
    def lastModifiedBy = "N/A"
    def consecutiveFailures = 0

    def definition = job.getDefinition()
    if (definition instanceof org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition) {
        def scm = definition.getScm()
        if (scm && scm.getRepositories()) {
            scmRepo = scm.getRepositories()[0].getURIs()[0].toString()
        }
        branch = definition.getScriptPath() ?: "Jenkinsfile"
    } else if (definition instanceof org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition) {
        pipelineType = "Pipeline (Inline)"
    }

    job.getTriggers()?.each { _, value ->
        if (value instanceof hudson.triggers.TimerTrigger) {
            cronSchedule = value.getSpec()?.replaceAll("\\r|\\n", " ")?.trim() ?: "N/A"
        }
        if (value instanceof hudson.triggers.SCMTrigger) {
            scmSchedule = value.getSpec()?.replaceAll("\\r|\\n", " ")?.trim() ?: "N/A"
        }
    }

    def firstBuild = job.getBuilds().reverse().find { it != null }
    if (firstBuild) {
        createdOn = dateFormat.format(firstBuild.getTime())

        def causes = firstBuild.getCauses()
        def userCause = causes.find { it.getClass().getSimpleName().contains("UserIdCause") }
        if (userCause) {
            createdBy = userCause.getUserId() ?: "Unknown"
        }
    }

    def lastBuild = job.getLastBuild()
    if (lastBuild) {
        lastExecuted = dateFormat.format(lastBuild.getTime())

        def causes = lastBuild.getCauses()
        if (causes) {
            lastModifiedBy = causes.collect { it.getShortDescription() }.join(", ")
        }
    }

    def lastSuccessfulBuild = job.getLastSuccessfulBuild()
    if (lastSuccessfulBuild) {
        lastSuccessful = dateFormat.format(lastSuccessfulBuild.getTime())
    }

    def failureCount = 0
    def currentBuild = lastBuild
    while (currentBuild != null && currentBuild.getResult() == hudson.model.Result.FAILURE) {
        failureCount++
        currentBuild = currentBuild.getPreviousBuild()
    }
    consecutiveFailures = failureCount

    // Print CSV row
    println "\"${job.fullName}\"${delimiter}\"${isEnabled}\"${delimiter}\"${pipelineType}\"${delimiter}\"${scmRepo}\"${delimiter}\"${branch}\"${delimiter}\"${cronSchedule}\"${delimiter}\"${scmSchedule}\"${delimiter}\"${createdOn}\"${delimiter}\"${createdBy}\"${delimiter}\"${lastExecuted}\"${delimiter}\"${lastSuccessful}\"${delimiter}\"${lastModifiedBy}\"${delimiter}\"${consecutiveFailures}\""
}

// Prevent Jenkins from printing "Result:"
return