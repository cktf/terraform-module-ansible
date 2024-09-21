variable "triggers" {
  type        = any
  default     = {}
  sensitive   = false
  description = "Ansible Triggers"
}

variable "groups" {
  type = map(object({
    vars     = optional(any, {})
    children = optional(list(string), [])
  }))
  default     = {}
  sensitive   = false
  description = "Ansible Groups"
}

variable "hosts" {
  type = map(object({
    vars       = optional(any, {})
    groups     = list(string)
    connection = any
  }))
  default     = {}
  sensitive   = false
  description = "Ansible Hosts"
}

variable "playbook" {
  type        = string
  default     = ""
  sensitive   = false
  description = "Ansible Playbook"
}

variable "extra_args" {
  type        = string
  default     = ""
  sensitive   = false
  description = "Ansible Extra Args"
}
