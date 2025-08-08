import jenkins.model.*

Jenkins.instance.getAllItems(AbstractItem.class).each { item ->
    if (item instanceof Job) {
        if (!item.isDisabled()) {
            item.setDisabled(true)
            println "Disabled job: ${item.fullName}"
        }
        else {
            println "Job is already disabled: ${item.fullName}"
        }
    }
}
println "All jobs disabled."