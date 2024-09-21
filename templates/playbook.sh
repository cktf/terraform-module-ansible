#!/bin/bash

export ROOT=/tmp/ansible_$(date +%s)
mkdir -p $ROOT

%{ for key, val in hosts ~}
%{ if can(val.connection.cacert) ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.cacert)}.crt > /dev/null
${val.connection.cacert}
EOF
%{ endif ~}
%{ if can(val.connection.private_key) ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.private_key)}.key > /dev/null
${val.connection.private_key}
EOF
%{ endif ~}
%{ if can(val.connection.certificate) ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.certificate)}.key > /dev/null
${val.connection.certificate}
EOF
%{ endif ~}
%{ if can(val.connection.bastion_private_key) ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.bastion_private_key)}.key > /dev/null
${val.connection.bastion_private_key}
EOF
%{ endif ~}
%{ if can(val.connection.bastion_certificate) ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.bastion_certificate)}.key > /dev/null
${val.connection.bastion_certificate}
EOF
%{ endif ~}
%{ endfor ~}

cat <<-EOF | tee $ROOT/inventory.yml > /dev/null
%{ for key, group in groups ~}
${key}:
    vars:
        ${indent(8, yamlencode(group.vars))}
    hosts:
        %{~ for hkey, host in hosts ~}
        %{~ if contains(host.groups, key) ~}
        ${hkey}:
            %{~ if can(host.connection.type) ~}
            ansible_connection: "${host.connection.type}"
            %{~ endif ~}
            %{~ if can(host.connection.host) ~}
            ansible_host: "${host.connection.host}"
            %{~ endif ~}
            %{~ if can(host.connection.host_key) ~}
            ansible_host_key_checking: "true"
            %{~ else ~}
            ansible_host_key_checking: "false"
            %{~ endif ~}
            %{~ if can(host.connection.port) ~}
            ansible_port: "${host.connection.port}"
            %{~ endif ~}
            %{~ if can(host.connection.user) ~}
            ansible_user: "${host.connection.user}"
            %{~ endif ~}
            %{~ if can(host.connection.password) ~}
            ansible_password: "${host.connection.password}"
            %{~ endif ~}
            %{~ if can(host.connection.private_key) ~}
            ansible_private_key_file: "$ROOT/${sha256(host.connection.private_key)}.key"
            %{~ endif ~}
            %{~ if can(host.connection.certificate) ~}
            ansible_ssh_extra_args: "-o CertificateFile=$ROOT/${sha256(host.connection.certificate)}.crt"
            %{~ endif ~}
            %{~ if can(host.connection.bastion_host) ~}
            ansible_ssh_common_args: "-o ProxyCommand=\"ssh -W %h:%p ${host.connection.bastion_user}@${host.connection.bastion_host} -o StrictHostKeyChecking=${can(host.connection.bastion_host_key) ? "yes" : "no"} -p ${host.connection.bastion_port} ${can(host.connection.bastion_private_key) ? "-i $ROOT/${sha256(host.connection.bastion_private_key)}.key" : ""} ${can(host.connection.bastion_certificate) ? "-o CertificateFile=$ROOT/${sha256(host.connection.bastion_certificate)}.crt" : ""}\""
            %{~ else ~}
            %{~ if can(host.connection.proxy_host) ~}
            ansible_ssh_common_args: "-o ProxyCommand=\"nc --proxy-type=${host.connection.proxy_scheme} --proxy-auth=${host.connection.proxy_user_name}:${host.connection.proxy_user_password} --proxy=${host.connection.proxy_host}:${host.connection.proxy_port} %h %p\""
            %{~ endif ~}
            %{~ endif ~}
            %{~ if can(host.connection.timeout) ~}
            ansible_ssh_timeout: "${replace(host.connection.timeout, "m", "")}"
            ansible_winrm_connection_timeout: "${replace(host.connection.timeout, "m", "")}"
            %{~ endif ~}
            %{~ if can(host.connection.https) ~}
            ansible_winrm_scheme: "${host.connection.https ? "https" : "http"}"
            %{~ endif ~}
            %{~ if can(host.connection.use_ntlm) ~}
            ansible_winrm_transport: "${host.connection.use_ntlm ? "ntlm" : "basic"}"
            %{~ endif ~}
            %{~ if can(host.connection.insecure) ~}
            ansible_winrm_server_cert_validation: "${host.connection.insecure ? "ignore" : "validate"}"
            %{~ endif ~}
            %{~ if can(host.connection.cacert) ~}
            ansible_winrm_ca_trust_path: "$ROOT/${sha256(host.connection.cacert)}.crt"
            %{~ endif ~}
        %{~ endif ~}
        %{~ endfor ~}
    children:
        ${indent(8, yamlencode({for group in group.children : group => {}}))}
%{ endfor ~}
EOF

ansible-playbook -i $ROOT/inventory.yml ${extra_args} ${playbook}; CODE=$?

rm -Rf $ROOT
exit $CODE
