variable "triggers" {
  type        = any
  default     = {}
  sensitive   = false
  description = "Ansible Triggers"
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

variable "create_playbook" {
  type        = string
  default     = ""
  sensitive   = false
  description = "Ansible Create Playbook"
}

variable "create_extra_args" {
  type        = string
  default     = ""
  sensitive   = false
  description = "Ansible Create Extra Args"
}

variable "destroy_playbook" {
  type        = string
  default     = ""
  sensitive   = false
  description = "Ansible Destroy Playbook"
}

variable "destroy_extra_args" {
  type        = string
  default     = ""
  sensitive   = false
  description = "Ansible Destroy Extra Args"
}
