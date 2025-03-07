output "cluster_vpc_id" {
  value = module.cluster_vpc.vpc_id
}

output "cluster_vpc_cidr" {
  value = module.cluster_vpc.vpc_cidr_block
}

output "cluster_private_subnet_ids" {
  value = module.cluster_vpc.private_subnets
}

output "cluster_public_subnet_ids" {
  value = module.cluster_vpc.public_subnets
}

output "onpremise_vpc_id" {
  value = module.onpremise_vpc.vpc_id
}

output "onpremise_vpc_cidr" {
  value = module.onpremise_vpc.vpc_cidr_block
}

output "onpremise_private_subnet_ids" {
  value = module.onpremise_vpc.private_subnets
}

output "onpremise_public_subnet_ids" {
  value = module.onpremise_vpc.public_subnets
}

output "hybrid_nodes_remote_network_cidrs" {
  value = local.onpremise_private_subnets
}