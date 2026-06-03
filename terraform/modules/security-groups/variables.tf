variable "name_prefix" {
  description = "Prefix for security group names"
  type        = string
}

variable "tags" {
  description = "Additional tags for all security groups"
  type        = map(string)
  default     = {}
}

variable "security_groups" {
  description = <<-EOF
    Map of security groups to create. Each key becomes the SG name suffix.
    Each value supports:
    - description (string)
    - vpc_id (string)
    - ingress_rules (list of objects):
        - description (optional string)
        - from_port (number)
        - to_port (number)
        - protocol (string, e.g. "tcp", "udp", "-1")
        - cidr_blocks (optional list of strings)
        - source_sg_key (optional string, references another SG in this map)
        - source_sg_ids (optional list of strings)
    - egress_rules (list of objects):
        - description (optional string)
        - from_port (number)
        - to_port (number)
        - protocol (string)
        - cidr_blocks (list of strings)
  EOF
  type = map(object({
    description = string
    vpc_id      = string
    ingress_rules = list(object({
      description   = optional(string)
      from_port     = number
      to_port       = number
      protocol      = string
      cidr_blocks   = optional(list(string))
      source_sg_key = optional(string)
      source_sg_ids = optional(list(string))
    }))
    egress_rules = list(object({
      description = optional(string)
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = optional(list(string))
    }))
  }))
}
