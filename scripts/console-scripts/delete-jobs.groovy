import jenkins.model.*
import hudson.model.*

def jenkins = Jenkins.instance

// 🛑 Enter the job names you want to delete (comma-separated)
def jobsToDelete = ["job1-pipeline","job2-pipeline"]
jobsToDelete.each { jobName ->
    def job = jenkins.getItemByFullName(jobName, Job)
    if (job) {
        job.delete()
        println "✅ Deleted: ${jobName}"
    } else {
        println "❌ Job Not Found: ${jobName}"
    }
}

// Save changes
jenkins.save()

// Prevents "Result: null" from printing
return