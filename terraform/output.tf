output "output-ip-host" {
  value = <<OUTPUT

Application Load Balancer
external = ${yandex_alb_load_balancer.load-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address}

VM Bastion Host
internal = ${yandex_compute_instance.bastion-host.network_interface.0.ip_address}
external = ${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address}

VM Web-Server1
internal = ${yandex_compute_instance.web-server1.network_interface.0.ip_address}

VM Web-Server2
internal = ${yandex_compute_instance.web-server2.network_interface.0.ip_address}

VM Prometheus
internal = ${yandex_compute_instance.prometheus.network_interface.0.ip_address}

VM Grafana
internal = ${yandex_compute_instance.grafana.network_interface.0.ip_address}
external = ${yandex_compute_instance.grafana.network_interface.0.nat_ip_address}

VM ElasticSearch
internal = ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}

VM Kibana
internal = ${yandex_compute_instance.kibana.network_interface.0.ip_address}
external = ${yandex_compute_instance.kibana.network_interface.0.nat_ip_address}

OUTPUT
}

output "output-ansible-hosts" {
  value = <<OUTPUT

[bastionhost]
bastion-host ansible_host=${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address} ansible_ssh_user=vasyaeva

[webservers]
web1 ansible_host=${yandex_compute_instance.web-server1.network_interface.0.ip_address}
web2 ansible_host=${yandex_compute_instance.web-server2.network_interface.0.ip_address}

[prometheus]
prometheus-host ansible_host=${yandex_compute_instance.prometheus.network_interface.0.ip_address}

[grafana]
grafana-host ansible_host=${yandex_compute_instance.grafana.network_interface.0.ip_address}

[elasticsearch]
elasticsearch-host ansible_host=${yandex_compute_instance.elasticsearch.network_interface.0.ip_address}

[kibana]
kibana-host ansible_host=${yandex_compute_instance.kibana.network_interface.0.ip_address}

[webservers:vars]
ansible_ssh_user=vasyaeva
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p vasyaeva@${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address}"'

[prometheus:vars]
ansible_ssh_user=vasyaeva
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p vasyaeva@${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address}"'

[grafana:vars]
ansible_ssh_user=vasyaeva
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p vasyaeva@${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address}"'

[elasticsearch:vars]
ansible_ssh_user=vasyaeva
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p vasyaeva@${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address}"'

[kibana:vars]
ansible_ssh_user=vasyaeva
ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p vasyaeva@${yandex_compute_instance.bastion-host.network_interface.0.nat_ip_address}"'

OUTPUT
}
