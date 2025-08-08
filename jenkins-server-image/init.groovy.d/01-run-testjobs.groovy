import jenkins.model.*
import org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition
import org.jenkinsci.plugins.workflow.job.WorkflowJob
import hudson.model.ListView

def runTestJobs = System.getenv('RUN_TESTJOBS')
println "RUN_TESTJOBS:${runTestJobs}"
def jenkinsHomeDir = System.getenv('JENKINS_HOME')

if (runTestJobs != null && runTestJobs.equalsIgnoreCase('true')) {
    def jenkins = Jenkins.instance

    // Directory containing job scripts
    def jobScriptsDir = new File("/usr/share/jenkins/ref/init.groovy.d/testjobs")

    // Create or get the view
    def viewName = "UpgradeTestJobs"
    def view = jenkins.getView(viewName)
    if (view == null) {
        println "Creating view: ${viewName}"
        view = new ListView(viewName)
        jenkins.addView(view)
        println "View created successfully."
    } else {
        println "View ${viewName} already exists."
    }
    def scheduledBuilds = [] // Store build futures and job names
    // Iterate over each job script file and create jobs
    jobScriptsDir.eachFile { file ->
        if (file.name.endsWith('.groovy')) {
            def jobConfig = evaluate(file.text)
            def jobName = jobConfig.name
            def jobScript = jobConfig.script

            def job = jenkins.getItem(jobName)
            if (job == null) {
                println "Creating job: ${jobName}"
                job = jenkins.createProject(WorkflowJob, jobName)
                job.setDefinition(new CpsFlowDefinition(jobScript, true))
                job.save()
                println "Job created successfully."
            } else {
                println "Job ${jobName} already exists."
            }

            // Add the job to the view
            if (!view.contains(job)) {
                println "Adding job ${jobName} to view ${viewName}"
                view.add(job)
            }

            // Schedule build but don't wait (store future)
            println "Triggering job ${jobName} now"
            scheduledBuilds << [
                future: job.scheduleBuild2(0),
                name: jobName
            ]
        }
    }
    println "All jobs triggered. Waiting for results..."
    // Wait for all builds to complete (parallel execution)
    def buildResults = []
    scheduledBuilds.each { entry ->
        def build = entry.future.get() // Blocks until individual build completes
        def result = "${entry.name}: ${build.result}"
        println result
        buildResults.add(result)
    }
    println "All jobs completed. Results:"
    buildResults.each { println it }

    // Write the build results to a file for the script to check
    def buildResultFile = new File("${jenkinsHomeDir}/build_results.txt")
    buildResultFile.withWriter { writer ->
        buildResults.each { result ->
            writer.writeLine(result)
        }
    }

    // Send slack notification for build result
    def sendSlackScriptPath = '/usr/share/jenkins/ref/init.groovy.d/build-results-notification'
    def sendSlackScriptFile = new File(sendSlackScriptPath)
    def sendSlackScriptConfig = evaluate(sendSlackScriptFile.text)
    def sendSlackScriptName = sendSlackScriptConfig.name
    def sendSlackScript = sendSlackScriptConfig.script
    def sendSlackjob = jenkins.getItem(sendSlackScriptName)
    if (sendSlackjob == null) {
        println "Creating job: ${sendSlackScriptName}"
        sendSlackjob = jenkins.createProject(WorkflowJob, sendSlackScriptName)
        sendSlackjob.setDefinition(new CpsFlowDefinition(sendSlackScript, true))
        sendSlackjob.save()
        println "Slack notification Job created successfully."
    } else {
        println "Slack notification Job ${sendSlackScriptName} already exists."
    }
    // Add the job to the view
    if (!view.contains(sendSlackjob)) {
        println "Adding job ${sendSlackScriptName} to view ${viewName}"
        view.add(sendSlackjob)
    }
    // Schedule the job to run immediately and wait for it to finish
    def buildSlackjob = sendSlackjob.scheduleBuild2(0).get()
    def buildSlackjobresult = "${sendSlackScriptName}: ${buildSlackjob.getResult()}"
    println "Build result notifcation job status: ${buildSlackjobresult}"
}
