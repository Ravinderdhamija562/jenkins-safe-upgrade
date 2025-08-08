import jenkins.model.*
import hudson.model.*

def jenkins = Jenkins.instance

// 🛑 Enter the job names you want to disable (comma-separated)
def jobsToDisable = ["job1","job2"]
jobsToDisable.each { jobName ->
    def job = jenkins.getItemByFullName(jobName, Job)
    if (job) {
        job.setDisabled(true)
        job.save() // Ensure the job config.xml is updated
        println "✅ Disabled: ${jobName}"
    } else {
        println "❌ Job Not Found: ${jobName}"
    }
}

// Save changes
jenkins.save()

// Prevents "Result: null" from printing
return