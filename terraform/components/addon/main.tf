terraform {
  required_version = "~> 1.10"

  backend "s3" {
  }

  required_providers {
    // AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.2"
    }
  }
}

// AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      PROJECT = "TERRAFORM_TUTORIAL_EKS",
    }
  }
}

/**
 * Pod Identity Agent
 *
 * - Amazon EKS Pod Identity エージェントのセットアップ
 *   https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/pod-id-agent-setup.html
 */
resource "aws_eks_addon" "eks_pod_identity_agent" {
  // https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon

  cluster_name = local.cluster_name
  addon_name   = "eks-pod-identity-agent"
  // バージョンの確認: aws eks describe-addon-versions --addon-name eks-pod-identity-agent
  addon_version = "v1.3.4-eksbuild.1"
}