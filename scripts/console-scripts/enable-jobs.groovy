import jenkins.model.*
import hudson.model.*

def jenkins = Jenkins.instance

// 🛑 Enter the job names you want to enable (comma-separated)
def jobsToEnable = ["job1","job2"]
jobsToEnable.each { jobName ->
    def job = jenkins.getItemByFullName(jobName, Job)
    if (job) {
        job.setDisabled(false)
        job.save() // Ensure the job config.xml is updated
        println "✅ Enabled: ${jobName}"
    } else {
        println "❌ Job Not Found: ${jobName}"
    }
}

// Save changes
jenkins.save()

// Prevents "Result: null" from printing
return