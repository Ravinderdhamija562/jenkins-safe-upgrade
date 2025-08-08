import jenkins.model.Jenkins

// Get the number of executors
def numExecutors = Jenkins.instance.numExecutors
println("Number of executors: " + numExecutors)
