
variable "jenkins_agents_cloudwatch_loggroups_names" {
  type    = list(string)
}

variable "jenkins_agent_cloudwatch_loggroups_retention" {
  type    = number
  default = 60 # Retention period in days
}

variable "access_key" {
  description = "AWS access key (Can be set via ACCESS_KEY env variable)"
  type        = string
  default     = null
}

variable "secret_key" {
  description = "AWS secret key (Can be set via SECRET_KEY env variable)"
  type        = string
  default     = null
}

variable "token" {
  description = "AWS session token (Can be set via TF_VAR_token env variable)"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region"
  type        = string
}
