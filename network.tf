resource "exoscale_nlb" "this" {
  zone = var.zone
  name = format("%s-nlb", var.name)

  description = "TODO" # TODO
  labels = {
    "lentidas-stack.io" = "true"
    "sks-cluster-name"  = var.name
    "sks-cluster-id"    = resource.exoscale_sks_cluster.this.id
  }
}

resource "exoscale_security_group" "this" {
  name        = format("%s-sg", var.name)
  description = "Security group for the to the ${var.name} cluster (UUID: ${resource.exoscale_sks_cluster.this.id})."
}

resource "exoscale_security_group_rule" "sks_logs" {
  security_group_id = resource.exoscale_security_group.this.id
  description       = "Allow kubelet traffic between worker nodes."
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 10250
  end_port          = 10250
}

resource "exoscale_security_group_rule" "calico_traffic" {
  count = var.cni == "calico" ? 1 : 0

  security_group_id      = resource.exoscale_security_group.this.id
  user_security_group_id = resource.exoscale_security_group.this.id
  description            = "Allow Calico VXLAN communication between worker nodes."
  type                   = "INGRESS"
  protocol               = "UDP"
  start_port             = 4789
  end_port               = 4789
}

resource "exoscale_security_group_rule" "cilium_traffic" {
  count = var.cni == "cilium" ? 1 : 0

  security_group_id      = resource.exoscale_security_group.this.id
  user_security_group_id = resource.exoscale_security_group.this.id
  description            = "Allow Cilium VXLAN communication between worker nodes."
  type                   = "INGRESS"
  protocol               = "UDP"
  start_port             = 8472
  end_port               = 8472
}

resource "exoscale_security_group_rule" "cilium_health_check" {
  count = var.cni == "cilium" ? 1 : 0

  security_group_id      = resource.exoscale_security_group.this.id
  user_security_group_id = resource.exoscale_security_group.this.id
  description            = "Allow Calico health checks between worker nodes."
  type                   = "INGRESS"
  protocol               = "TCP"
  start_port             = 4240
  end_port               = 4240
}

resource "exoscale_security_group_rule" "cilium_health_check_icmp" {
  count = var.cni == "cilium" ? 1 : 0

  security_group_id      = resource.exoscale_security_group.this.id
  user_security_group_id = resource.exoscale_security_group.this.id
  description            = "Allow Calico health checks ICMP between worker nodes."
  type                   = "INGRESS"
  protocol               = "ICMP"
  icmp_code              = 0
  icmp_type              = 8
}

resource "exoscale_security_group_rule" "all" {
  description            = "Allow all traffic from the security group itself."
  security_group_id      = resource.exoscale_security_group.this.id
  user_security_group_id = resource.exoscale_security_group.this.id
  type                   = "INGRESS"
  protocol               = "TCP"
  start_port             = 1
  end_port               = 65535
}

# resource "exoscale_security_group_rule" "nodeport_tcp_services" {
#   count = var.tcp_node_ports_world_accessible ? 1 : 0

#   security_group_id = resource.exoscale_security_group.this.id
#   description       = "NodePort TCP services"
#   type              = "INGRESS"
#   protocol          = "TCP"
#   cidr              = "0.0.0.0/0"
#   start_port        = 30000
#   end_port          = 32767
# }

# resource "exoscale_security_group_rule" "nodeport_udp_services" {
#   count = var.udp_node_ports_world_accessible ? 1 : 0

#   security_group_id = resource.exoscale_security_group.this.id
#   description       = "NodePort UDP services"
#   type              = "INGRESS"
#   protocol          = "UDP"
#   cidr              = "0.0.0.0/0"
#   start_port        = 30000
#   end_port          = 32767
# }

# resource "exoscale_security_group_rule" "http" {
#   security_group_id = resource.exoscale_security_group.this.id
#   description       = "Allow incoming HTTP traffic from the outside world."
#   type              = "INGRESS"
#   protocol          = "TCP"
#   cidr              = "0.0.0.0/0"
#   start_port        = 80
#   end_port          = 80
# }

# resource "exoscale_security_group_rule" "https" {
#   security_group_id = resource.exoscale_security_group.this.id
#   description       = "Allow incoming HTTP traffic from the outside world."
#   type              = "INGRESS"
#   protocol          = "TCP"
#   cidr              = "0.0.0.0/0"
#   start_port        = 443
#   end_port          = 443
# }
