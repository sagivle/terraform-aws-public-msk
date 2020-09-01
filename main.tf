
locals {
  brokers = "${split("," , (replace(join(",", aws_msk_cluster.msk.*.bootstrap_brokers_tls), ":9094", "" )))}"
  zookeeper = "${split("," , (replace(join(",", aws_msk_cluster.msk.*.zookeeper_connect_string), ":2181", "" )))}"
}

//  zookeeper

data "dns_a_record_set" "dns_record_zookeeper" {
  count = "${aws_msk_cluster.msk.number_of_broker_nodes}"
  host = "${local.zookeeper[count.index]}"
}

data "aws_network_interfaces" "network_interfaces_zookeeper" {
  count = "${aws_msk_cluster.msk.number_of_broker_nodes}"
  filter {
    name   = "private-ip-address"
    values = ["${element(flatten(data.dns_a_record_set.dns_record_zookeeper.*.addrs), count.index)}"]
  }
}

resource "aws_eip" "eip_zookeeper" {
  count = "${aws_msk_cluster.msk.number_of_broker_nodes}"
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
  count = "${aws_msk_cluster.msk.number_of_broker_nodes}"
  host = "${local.brokers[count.index]}"
}

data "aws_network_interfaces" "network_interfaces_brokers" {
  count = "${aws_msk_cluster.msk.number_of_broker_nodes}"
  filter {
    name   = "private-ip-address"
    values = ["${element(flatten(data.dns_a_record_set.dns_record_brokers.*.addrs), count.index)}"]
  }
}

resource "aws_eip" "eip_brokers" {
  count = "${aws_msk_cluster.msk.number_of_broker_nodes}"
  vpc                       = true
  network_interface         = "${element(flatten(data.aws_network_interfaces.network_interfaces_brokers.*.ids), count.index)}"
  associate_with_private_ip = "${element(flatten(data.dns_a_record_set.dns_record_brokers.*.addrs), count.index)}"
  tags {
    Name        = "${element(flatten(data.dns_a_record_set.dns_record_brokers.*.host), count.index)}"
    Environment = "${var.environment}"
  }
}
