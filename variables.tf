variable "hosts" {
  type = map(object({
    vars       = optional(any, {})
    groups     = optional(list(string), [])
    connection = any
  }))
  default     = {}
  sensitive   = false
  description = "Ansible Hosts"
}

variable "groups" {
  type = map(object({
    vars   = optional(any, {})
    groups = optional(list(string), [])
  }))
  default     = {}
  sensitive   = false
  description = "Ansible Groups"
}

variable "triggers" {
  type        = any
  default     = {}
  sensitive   = false
  description = "Ansible Triggers"
}

variable "playbook" {
  type        = string
  default     = null
  sensitive   = false
  description = "Ansible Playbook"
}

variable "create_args" {
  type        = string
  default     = ""
  sensitive   = false
  description = "Ansible Create Args"
}

variable "destroy_args" {
  type        = string
  default     = null
  sensitive   = false
  description = "Ansible Destroy Args"
}
