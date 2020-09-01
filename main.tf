data "aws_msk_cluster" "msk" {
  cluster_name = "${var.deploy_name}"
}

locals {
  brokers = "${sort(split("," , (replace(join(",", aws_msk_cluster.msk.*.bootstrap_brokers_tls), ":9094", "" ))))}"
  zookeeper = "${sort(split("," , (replace(join(",", aws_msk_cluster.msk.*.zookeeper_connect_string), ":2181", "" ))))}"
}

//  zookeeper

data "dns_a_record_set" "dns_record_zookeeper" {
  count = "${var.module_enabled ? aws_msk_cluster.msk.number_of_broker_nodes : 0}"
  host = "${local.zookeeper[count.index]}"
}

data "aws_network_interfaces" "network_interfaces_zookeeper" {
  count = "${var.module_enabled ? aws_msk_cluster.msk.number_of_broker_nodes : 0}"
  filter {
    name   = "private-ip-address"
    values = ["${element(flatten(data.dns_a_record_set.dns_record_zookeeper.*.addrs), count.index)}"]
  }
}

resource "aws_eip" "eip_zookeeper" {
  count = "${var.module_enabled ? aws_msk_cluster.msk.number_of_broker_nodes : 0}"
  vpc                       = true
  network_interface         = "${element(flatten(data.aws_network_interfaces.network_interfaces_zookeeper.*.ids), count.index)}"
  associate_with_private_ip = "${element(flatten(data.dns_a_record_set.dns_record_zookeeper.*.addrs), count.index)}"
  tags {
    Name        = "${element(flatten(data.dns_a_record_set.dns_record_zookeeper.*.host), count.index)}"
    Environment = "${var.environment}"
  }
}

//  brokers

data "dns_a_record_set" "dns_record_brokers" {
  count = "${var.module_enabled ? aws_msk_cluster.msk.number_of_broker_nodes : 0}"
  host = "${local.brokers[count.index]}"
}

data "aws_network_interfaces" "network_interfaces_brokers" {
  count = "${var.module_enabled ? aws_msk_cluster.msk.number_of_broker_nodes : 0}"
  filter {
    name   = "private-ip-address"
    values = ["${element(flatten(data.dns_a_record_set.dns_record_brokers.*.addrs), count.index)}"]
  }
}

resource "aws_eip" "eip_brokers" {
  count = "${var.module_enabled ? aws_msk_cluster.msk.number_of_broker_nodes : 0}"
  vpc                       = true
  network_interface         = "${element(flatten(data.aws_network_interfaces.network_interfaces_brokers.*.ids), count.index)}"
  associate_with_private_ip = "${element(flatten(data.dns_a_record_set.dns_record_brokers.*.addrs), count.index)}"
  tags {
    Name        = "${element(flatten(data.dns_a_record_set.dns_record_brokers.*.host), count.index)}"
    Environment = "${var.environment}"
  }
}
