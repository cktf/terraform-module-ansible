locals {
  script = templatefile("${path.module}/templates/playbook.sh", {
    hosts      = var.hosts
    groups     = var.groups
    playbook   = var.playbook
    extra_args = var.extra_args
  })
}

resource "terraform_data" "this" {
  lifecycle {
    create_before_destroy = true
  }

  triggers_replace = merge(var.triggers, {
    time   = timestamp()
    script = sha256(local.script)
  })

  provisioner "local-exec" {
    command = "echo ${base64encode(local.script)} | base64 -d | bash"
  }
}
