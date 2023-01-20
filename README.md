# substrate
A foundation for an EKS cluster using dual-stack networking.

Kubernetes benefits from using IPv6, because the cluster can quickly assign IPv6 addresses to pods, and the pods can directly communicate with each other. Other
resources, such as caches and databases, still need IPv4 to remain compatible with most of the AWS networking resources, but use IPv6 to communicate with the
Kubernetes pods.

```terraform
// main.tf
resource "aws_vpc" "ha_net" {
  cidr_block = local.b_class

  # Both enabled to permit nodes to register with an EKS cluster.
  enable_dns_hostnames  = true
  enable_dns_support    = true # DNS Resolution enabled.

  instance_tenancy      = "default" # VM shared on a host.

  assign_generated_ipv6_cidr_block  = true

  tags = {
    Name = "network"
  }
}
```


### Subnets

1. Public, host the load balancers and NAT gateways
2. Private, host the micro-services
3. Private, host the caches
4. Private, host the databases


### Application Load Balancers and the AWS Load Balancer Controller
The AWS LB Controller needs the tag `kubernetes.io/role/elb` on the public subnets to discover them. Then it will deploy ALBs to the public subnets.
```terraform
// main.tf
resource "aws_subnet" "public" {
  for_each            = local.map_az_index

  vpc_id              = aws_vpc.ha_net.id
  availability_zone   = each.key
  cidr_block          = element(local.web_subnets_4, each.value)
  ipv6_cidr_block     = element(local.public_subnets_6, each.value)

  tags = {
    Name = "public-${each.key}"
    ip   = "dual"
    "kubernetes.io/role/elb" = 1
  }
}
```


### Network Firewalls
Requires opening ports on both sides of the firewall.


### Server Firewalls
Requires opening a port on only one side of the firewall, because AWS Security Groups permit responses on an open port.


### Endpoints
Requests to AWS Services must remain inside the VPC. Avoid the public web with internal endpoints from the _private app_ subnets.

1. S3
2. ECR
3. SQS
4. Dynamo
5. Secrets


### DNS
Create a domain that serves as a front door for employees to enter the VPC. This will need to be changed to use EC2 Systems Manager.


### Flowlogs
Each _private data_ subnet has network requests recorded and stored in S3 buckets.
