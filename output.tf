output "vpc_id" {
  value = aws_vpc.ha_net.id
}


output "nacl" {
  value       = aws_vpc.ha_net.default_network_acl_id
  description = "ID of network ACL that regulates subnets."
}


output "sg" {
  value       = aws_vpc.ha_net.default_security_group_id
  description = "ID of security group that regulates servers."
}


output "main_route_table" {
  value       = aws_vpc.ha_net.main_route_table_id
  description = "Main route table associated with this VPC."
}


output "multi_tenant" {
  value       = aws_vpc.ha_net.instance_tenancy
  description = "Tenancy of EC2 Instances permitted on VPC"
}


output "tags" {
  value       = aws_vpc.ha_net.tags_all
  description = "A map of tags, including tags inherited from the provider"
}


output "owner" {
  value       = aws_vpc.ha_net.owner_id
  description = "AWS account that owns VPC"
}


output "dns_support" {
  value       = aws_vpc.ha_net.enable_dns_support
}


output "dns_hostnames" {
  value       = aws_vpc.ha_net.enable_dns_hostnames
}


output "ip6_cidr" {
  value       = aws_vpc.ha_net.ipv6_cidr_block
  description = "/56 block provided by AWS."
}


output "app_gateway_id" {
  value = aws_internet_gateway.app_gateway.id
  description = "id of internet gateway on vpc."
}


output "app_gateway_owner" {
  value = aws_internet_gateway.app_gateway.owner_id
  description = "ID of account that owns internet gateway on VPC."
}


output "app_gateway_tags" {
  value = aws_internet_gateway.app_gateway.tags_all
}


output "ip6_egress_gateway_id" {
  value = aws_egress_only_internet_gateway.ip6_egress_gateway.id
}


output "ip6_egress_gateway_tags" {
  value = aws_egress_only_internet_gateway.ip6_egress_gateway.tags_all
}


output "default_route_table_id" {
  value = aws_default_route_table.rules.id
}


output "default_route_table_vpc" {
  value = aws_default_route_table.rules.vpc_id
}


output "default_route_table_tags" {
  value = aws_default_route_table.rules.tags_all
}


output "public_route_table_id" {
  value = aws_route_table.public.id
}


output "public_route_table_associations" {
  value = values(aws_route_table_association.public).*.id
}


output "az_names" {
  value = data.aws_availability_zones.current.names
  description = "List of AZs."
}


output "az_region" {
  value = data.aws_availability_zones.current.id
  description = "Region of AZs."
}


output "az_id" {
  value = data.aws_availability_zones.current.zone_ids
  description = "List of AZ IDs."
}


output "public_subnets" {
  value = values(aws_subnet.public).*.id
}


output "private_data_subnets" {
  value = values(aws_subnet.private_data).*.id
}


output "private_app_subnets" {
  value = values(aws_subnet.private_app).*.id
}


output "eip_IDs" {
  value = values(aws_eip.nat).*.id
  description = "IDs of Elastic IP4 addresses assigned to the NAT Gateways."
}


output "eip_IPs" {
  value = values(aws_eip.nat).*.public_ip
  description = "IPs assigned to the NAT Gateways."
}


output "nat_gateway_IDs" {
  value = values(aws_nat_gateway.ec2_to_igw).*.id
  description = "NAT Gateways residing in different AZs in public subnets."
}


output "nat_gateway_subnets" {
  value = values(aws_nat_gateway.ec2_to_igw).*.subnet_id
  description = "Subnets holding the NAT Gateways."
}


output "nat_gateway_EIPs" {
  value = values(aws_nat_gateway.ec2_to_igw).*.allocation_id
  description = "Allocation IDs of the Elastic IPs assigned to the NAT Gateways."
}


output "nat_gateway_public_IPs" {
  value = values(aws_nat_gateway.ec2_to_igw).*.public_ip
  description = "Public IPs needed to access the NAT Gateways."
}


output "nat_gateway_private_IPs" {
  value = values(aws_nat_gateway.ec2_to_igw).*.private_ip
  description = "Private IPs needed to access the NAT Gateways."
}


output "private_app_route_tables" {
  value = values(aws_route_table.private_app).*.id
  description = "IDs of the private-app route tables."
}


output "private_app_association_of_route_tables" {
  value = values(aws_route_table_association.private_app).*.id
  description = "IDs of the association between a private-app route table and private-app subnets."
}


output "sg_lb_allow_tls" {
  value       = aws_security_group.lb_allow_tls.id
  description = "ID of server-firewall that enforces TLS."
}


output "sg_postgres" {
  value       = aws_security_group.postgres.id
  description = "ID of server-firewall that shields Postgres servers."
}


output "sg_endpoints" {
  value       = aws_security_group.endpoints.id
  description = "ID of server-firewall that VPC Endpoints."
}


output "sg_cred_rotation_lambda" {
  value       = aws_security_group.cred_rotation_lambda.id
  description = "ID of server-firewall that shields Lambda ENI inside VPC."
}


output "nacl_private_data" {
  value       = aws_network_acl.private_data.id
  description = "ID of network-firewall that permits transmission between private-app subnets and private-data subnets."
}


output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3.*.id
}


output "s3_endpoint_dns" {
  value = aws_vpc_endpoint.s3.*.dns_entry
}


output "s3_endpoint_owner_id" {
  value = aws_vpc_endpoint.s3.*.owner_id
}

output "ecr_endpoint_id" {
  value = aws_vpc_endpoint.ecr.*.id
}


output "ecr_endpoint_dns" {
  value = aws_vpc_endpoint.ecr.*.dns_entry
}


output "ecr_owner_id" {
  value = aws_vpc_endpoint.ecr.*.owner_id
}


output "s3_ID_holding_vpc_flow_logs" {
  value = aws_s3_bucket.vpc_flow_log.id
}


output "vpc_flow_logs_ID" {
  value = aws_flow_log.vpc.id
}


output "s3_IDs_holding_private_data_flow_logs" {
  value = values(aws_s3_bucket.private_data_flow_log).*.id
}


output "private_data_flow_logs_IDs" {
  value = values(aws_flow_log.private_data).*.id
}


output "account_ID" {
  value = data.aws_caller_identity.requestor.account_id
}


output "account_ARN" {
  value = data.aws_caller_identity.requestor.arn
}


output "user_ID" {
  value = data.aws_caller_identity.requestor.user_id
}


output "secrets_manager_endpoint_id" {
  value = aws_vpc_endpoint.secrets.*.id
}


output "secrets_manager_endpoint_nii" {
  value = aws_vpc_endpoint.secrets.*.network_interface_ids
}


output "secrets_manager_endpoint_dns" {
  value = aws_vpc_endpoint.secrets.*.dns_entry
}


output "secrets_manager_endpoint_dns_name" {
  value = join("", aws_vpc_endpoint.secrets.*.dns_entry.0.dns_name)
}


output "subdomain" {
  value = aws_route53_zone.employee.zone_id
}


output "personnel_subdomain_name" {
  value = aws_route53_record.employee_entrance.name
}


output "personnel_fqdn" {
  value = aws_route53_record.employee_entrance.fqdn
}


output "sg_bastion" {
  value = module.bastion.bastion_host_security_group
}
