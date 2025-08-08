import jenkins.model.*
import hudson.model.*

def jenkins = Jenkins.instance

// 🛑 Enter the job names you want to disable (comma-separated)
def jobsToUpdate = ["automation-dependency-check"]


jobsToUpdate.each { jobName ->
    def job = jenkins.getItemByFullName(jobName, Job)
    if (job) {

        // Migrate job description to new AWS Jenkins
        // Replace "ci-feature" with "npe-cisystem-feature" in the job URL
        def currentJobUrl = job.getAbsoluteUrl()
        def newJobUrl = currentJobUrl.replace("ci-feature", "npe-cisystem-feature")
        println "🔗 Current Job URL: ${currentJobUrl}"
        println "🔗 New Job URL: ${newJobUrl}"
        def disableMessage = "<b style='font-size:16px; color:red;'>DO NOT ENABLE THIS JOB.</b><br><br>" +
                 "This job has been disabled in this Jenkins and enabled in the new AWS jenkins. New URL <a href='${newJobUrl}'>${newJobUrl}</a>"

        job.setDescription(disableMessage)
        println "✅ Disabled and updated description for: ${jobName}"
    } else {
        println "❌ Job Not Found: ${jobName}"
    }
}

// Save changes
jenkins.save()

// Prevents "Result: null" from printing
return