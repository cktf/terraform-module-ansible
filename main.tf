terraform {
  required_version = ">= 1.5.0"
  required_providers {}
}

resource "terraform_data" "this" {
  triggers_replace = merge(var.triggers, {
    hosts              = { for key, val in var.hosts : key => merge(val, { groups = coalescelist(val.groups, ["ungrouped"]) }) }
    groups             = merge({ ungrouped = { vars = {}, groups = [] } }, var.groups)
    create_playbook    = var.create_playbook
    create_extra_args  = var.create_extra_args
    destroy_playbook   = var.destroy_playbook
    destroy_extra_args = var.destroy_extra_args
  })

  provisioner "local-exec" {
    when    = create
    quiet   = true
    command = "echo $SCRIPT | base64 -d | bash"
    environment = {
      SCRIPT = nonsensitive(base64encode(templatefile("${path.module}/templates/playbook.sh", {
        hosts      = self.triggers_replace.hosts
        groups     = self.triggers_replace.groups
        playbook   = self.triggers_replace.create_playbook
        extra_args = self.triggers_replace.create_extra_args
      })))
    }
  }

  provisioner "local-exec" {
    when    = destroy
    quiet   = true
    command = "echo $SCRIPT | base64 -d | bash"
    environment = {
      SCRIPT = nonsensitive(base64encode(templatefile("${path.module}/templates/playbook.sh", {
        hosts      = self.triggers_replace.hosts
        groups     = self.triggers_replace.groups
        playbook   = self.triggers_replace.destroy_playbook
        extra_args = self.triggers_replace.destroy_extra_args
      })))
    }
  }
}
