variable "name_prefix" {
  description = "Prefix for instance names"
  type        = string
}

variable "tags" {
  description = "Additional tags for all instances"
  type        = map(string)
  default     = {}
}

variable "instances" {
  description = <<-EOF
    Map of EC2 instances to create.
    Required attributes:
    - ami (string)
    - instance_type (string)
    - subnet_id (string)
    - vpc_security_group_ids (list of strings)
    Optional attributes:
    - key_name (string)
    - user_data (string)
    - associate_public_ip_address (bool)
  EOF
  type = map(object({
    ami                         = string
    instance_type               = string
    subnet_id                   = string
    vpc_security_group_ids      = list(string)
    key_name                    = optional(string)
    user_data                   = optional(string)
    associate_public_ip_address = optional(bool)
  }))
}
