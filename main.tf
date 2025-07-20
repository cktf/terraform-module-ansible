terraform {
  required_version = ">= 1.5.0"
  required_providers {}
}

resource "terraform_data" "this" {
  triggers_replace = merge(var.triggers, {
    hash         = try(filemd5(var.playbook), md5(join("", [for f in fileset(var.playbook, "**") : filemd5("${var.playbook}/${f}") if !startswith(f, ".")])))
    hosts        = { for key, val in var.hosts : key => merge(val, { groups = coalescelist(val.groups, ["ungrouped"]) }) }
    groups       = merge({ ungrouped = { vars = {}, groups = [] } }, var.groups)
    playbook     = can(regex(".*\\.ya?ml$", var.playbook)) ? var.playbook : "${var.playbook}/main.yml"
    create_args  = var.create_args
    destroy_args = var.destroy_args
  })

  provisioner "local-exec" {
    when    = create
    quiet   = true
    command = "echo $SCRIPT | base64 -d | bash"
    environment = {
      SCRIPT = nonsensitive(base64encode(templatefile("${path.module}/templates/playbook.sh", {
        hosts      = self.triggers_replace.hosts
        groups     = self.triggers_replace.groups
        playbook   = self.triggers_replace.playbook
        extra_args = self.triggers_replace.create_args
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
        playbook   = self.triggers_replace.playbook
        extra_args = self.triggers_replace.destroy_args
      })))
    }
  }
}
