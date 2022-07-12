# substrate
A foundation for an EKS cluster using dual-stack networking.

Kubernetes benefits from using IPv6, because the cluster can quickly assign IPv6 addresses to pods, and the pods can quickly communicate with each other. Other
resources, such as caches and databases, still need IPv4 to remain compatible with most of the AWS networking resources, but use IPv6 to communicate with the
Kubernetes pods.
