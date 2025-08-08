role_path              = "/application_role/"
region                 = "us-east-1"
permissions_boundary   = "arn:aws:iam::156041411903:policy/DefaultBoundaryPolicy"
ec2_actions = [
  "ec2:DescribeSpotInstanceRequests",
  "ec2:CancelSpotInstanceRequests",
  "ec2:GetConsoleOutput",
  "ec2:RequestSpotInstances",
  "ec2:RunInstances",
  "ec2:StartInstances",
  "ec2:StopInstances",
  "ec2:TerminateInstances",
  "ec2:CreateTags",
  "ec2:DeleteTags",
  "ec2:DescribeInstances",
  "ec2:DescribeInstanceTypes",
  "ec2:DescribeKeyPairs",
  "ec2:DescribeRegions",
  "ec2:DescribeImages",
  "ec2:DescribeAvailabilityZones",
  "ec2:DescribeSecurityGroups",
  "ec2:DescribeSubnets",
  "iam:ListInstanceProfilesForRole",
  "iam:PassRole",
  "ec2:GetPasswordData"
]
cloudwatch_role_actions = [
  "logs:CreateLogGroup",
  "logs:CreateLogStream",
  "logs:PutLogEvents",
  "logs:DescribeLogStreams",
  "logs:DescribeLogGroups",
  "cloudwatch:PutMetricData",
  "ec2:DescribeTags",
  "ec2:DescribeInstances",
  "ssm:GetParameter",
  "ssm:GetParameters"
]

jenkins_agent_sg_ingress_rules = [
  {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  },
  {
    description = "Allow ICMP(Ping)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

jenkins_agent_sg_egress_rules = [
  {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
]

vpc_id="vpc-03d2bb0a568c9ede1"