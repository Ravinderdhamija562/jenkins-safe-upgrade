resource "aws_security_group" "jenkins_agent_sg" {
  name        = "npe-cisystem-${var.env}-jenkins-agent-sg"
  description = "Security Group for jenkins agents"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.jenkins_agent_sg_ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.jenkins_agent_sg_egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name                      = "npe-cisystem-${var.env}-jenkins-agent-sg"
    terraform                 = true
  }
}
