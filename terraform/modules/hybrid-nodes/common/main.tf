/**
 * ハイブリッドノード用のIAMロール
 */
resource "aws_iam_role" "hybrid_node_role" {
  name        = "${var.cluster_name}-EKSHybridNodeRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ssm.amazonaws.com"
        },
        "Action" : [
          "sts:TagSession",
          "sts:AssumeRole"
        ]
      },
    ]
  })
}
 
resource "aws_iam_role_policy_attachment" "aws_managed_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ])
  role       = aws_iam_role.hybrid_node_role.name
  policy_arn = each.key
}
 
resource "aws_iam_policy" "hybrid_node_policy" {
  name = "${var.cluster_name}-EKSHybridNodePolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ssm:DescribeInstanceInformation",
          "ssm:DeregisterManagedInstance"
        ],
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": "eks:DescribeCluster",
        "Effect": "Allow",
        "Resource": "*"
      },
      {
        "Action": "eks-auth:AssumeRoleForPodIdentity",
        "Effect": "Allow",
        "Resource": "*"
      }
    ],
  })
}
resource "aws_iam_role_policy_attachment" "hybrid_node_policy" {
  role = aws_iam_role.hybrid_node_role.name
  policy_arn = aws_iam_policy.hybrid_node_policy.arn
}

resource "aws_eks_access_entry" "hybrid_node" {
  // https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/access-entries.html
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry
  cluster_name = var.cluster_name
  principal_arn = aws_iam_role.hybrid_node_role.arn
  type = "HYBRID_LINUX"
}

/**
 * セキュリティグループ
 */
resource "aws_security_group" "hybrid_node" {
  name        = "${var.cluster_name}-HybridNodeSG"
  description = "Allow HTTP, HTTPS access."
  vpc_id      = var.onpremise_vpc_id

  // NOTE: ノード間のvxlan(udp, port 4789)が許可されていないといけない
  ingress {
    description = "Allow All access."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  tags = {
    Name = "${var.cluster_name}-HybridNodeSG"
  }
}
