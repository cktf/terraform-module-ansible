#!/bin/bash

%{ if playbook != "" ~}
export ROOT=/tmp/ansible_$(date +%s)
mkdir -p $ROOT

%{ for key, val in hosts ~}
%{ if try(val.connection.cacert, null) != null ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.cacert)}.crt > /dev/null
${val.connection.cacert}
EOF
%{ endif ~}
%{ if try(val.connection.private_key, null) != null ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.private_key)}.key > /dev/null
${val.connection.private_key}
EOF
%{ endif ~}
%{ if try(val.connection.certificate, null) != null ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.certificate)}.key > /dev/null
${val.connection.certificate}
EOF
%{ endif ~}
%{ if try(val.connection.bastion_private_key, null) != null ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.bastion_private_key)}.key > /dev/null
${val.connection.bastion_private_key}
EOF
%{ endif ~}
%{ if try(val.connection.bastion_certificate, null) != null ~}
cat <<-EOF | tee $ROOT/${sha256(val.connection.bastion_certificate)}.key > /dev/null
${val.connection.bastion_certificate}
EOF
%{ endif ~}
%{ endfor ~}

chmod -f 644 $ROOT/*.crt || :
chmod -f 600 $ROOT/*.key || :

cat <<-EOF | tee $ROOT/inventory.yml > /dev/null
%{ for key, group in groups ~}
${key}:
    vars:
        ${indent(8, yamlencode(group.vars))}
    hosts:
        %{~ for hkey, host in hosts ~}
        %{~ if contains(host.groups, key) ~}
        ${hkey}:
            %{~ if try(host.connection.type, null) != null ~}
            ansible_connection: "${host.connection.type}"
            %{~ endif ~}
            %{~ if try(host.connection.host, null) != null ~}
            ansible_host: "${host.connection.host}"
            %{~ endif ~}
            %{~ if try(host.connection.host_key, null) != null ~}
            ansible_host_key_checking: "true"
            %{~ else ~}
            ansible_host_key_checking: "false"
            %{~ endif ~}
            %{~ if try(host.connection.port, null) != null ~}
            ansible_port: "${host.connection.port}"
            %{~ endif ~}
            %{~ if try(host.connection.user, null) != null ~}
            ansible_user: "${host.connection.user}"
            %{~ endif ~}
            %{~ if try(host.connection.password, null) != null ~}
            ansible_password: "${host.connection.password}"
            %{~ endif ~}
            %{~ if try(host.connection.private_key, null) != null ~}
            ansible_private_key_file: "$ROOT/${sha256(host.connection.private_key)}.key"
            %{~ endif ~}
            %{~ if try(host.connection.certificate, null) != null ~}
            ansible_ssh_extra_args: "-o CertificateFile=$ROOT/${sha256(host.connection.certificate)}.crt"
            %{~ endif ~}
            %{~ if try(host.connection.bastion_host, null) != null ~}
            ansible_ssh_common_args: "-o ProxyCommand=\"ssh -W %h:%p ${host.connection.bastion_user}@${host.connection.bastion_host} -o StrictHostKeyChecking=${(try(host.connection.bastion_host_key, null) != null) ? "yes" : "no"} -o UserKnownHostsFile=/dev/null -p ${host.connection.bastion_port} ${(try(host.connection.bastion_private_key, null) != null) ? "-i $ROOT/${sha256(host.connection.bastion_private_key)}.key" : ""} ${(try(host.connection.bastion_certificate, null) != null) ? "-o CertificateFile=$ROOT/${sha256(host.connection.bastion_certificate)}.crt" : ""}\""
            %{~ else ~}
            %{~ if try(host.connection.proxy_host, null) != null ~}
            ansible_ssh_common_args: "-o ProxyCommand=\"nc --proxy-type=${host.connection.proxy_scheme} --proxy-auth=${host.connection.proxy_user_name}:${host.connection.proxy_user_password} --proxy=${host.connection.proxy_host}:${host.connection.proxy_port} %h %p\""
            %{~ endif ~}
            %{~ endif ~}
            %{~ if try(host.connection.timeout, null) != null ~}
            ansible_ssh_timeout: "${replace(host.connection.timeout, "m", "")}"
            ansible_winrm_connection_timeout: "${replace(host.connection.timeout, "m", "")}"
            %{~ endif ~}
            %{~ if try(host.connection.https, null) != null ~}
            ansible_winrm_scheme: "${host.connection.https ? "https" : "http"}"
            %{~ endif ~}
            %{~ if try(host.connection.use_ntlm, null) != null ~}
            ansible_winrm_transport: "${host.connection.use_ntlm ? "ntlm" : "basic"}"
            %{~ endif ~}
            %{~ if try(host.connection.insecure, null) != null ~}
            ansible_winrm_server_cert_validation: "${host.connection.insecure ? "ignore" : "validate"}"
            %{~ endif ~}
            %{~ if try(host.connection.cacert, null) != null ~}
            ansible_winrm_ca_trust_path: "$ROOT/${sha256(host.connection.cacert)}.crt"
            %{~ endif ~}
        %{~ endif ~}
        %{~ endfor ~}
    children:
        ${indent(8, yamlencode({for group in group.children : group => {}}))}
%{ endfor ~}
EOF

ansible-playbook -i $ROOT/inventory.yml ${extra_args} ${playbook}
%{ endif ~}
