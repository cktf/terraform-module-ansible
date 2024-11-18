locals {
  script = templatefile("${path.module}/templates/playbook.sh", {
    hosts      = var.hosts
    groups     = var.groups
    playbook   = var.playbook
    extra_args = var.extra_args
  })
}

resource "terraform_data" "this" {
  triggers_replace = merge(var.triggers, {
    script = sha256(local.script)
  })

  provisioner "local-exec" {
    quiet   = true
    command = "echo ${base64encode(local.script)} | base64 -d | bash"
  }
}
