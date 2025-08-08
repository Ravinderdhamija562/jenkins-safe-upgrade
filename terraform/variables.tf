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

variable "env" {
  description = "Jenkins environment (e.g., beta, test, main, feature)"
  type        = string
}


variable "role_path" {
  description = "The path for the IAM role"
  type        = string
}

variable "permissions_boundary" {
  description = "Permissions boundary ARN"
  type        = string
}

variable "ec2_actions" {
  description = "List of EC2 actions allowed by the policy"
  type        = list(string)
}

variable "cloudwatch_role_actions" {
  description = "List of EC2 actions allowed by the cloudwatch role policy"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "jenkins_agent_sg_ingress_rules" {
  description = "List of ingress rules for jenkins agent"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

variable "jenkins_agent_sg_egress_rules" {
  description = "List of egress rules for jenkins agent"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}