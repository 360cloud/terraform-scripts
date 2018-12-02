data "aws_region" "current" {}

data "http" "workstation_external_ip" {
  url = "https://ipv4.icanhazip.com"
}

data "aws_iam_policy_document" "workers_assume_role_policy" {
  statement {
    sid = "EKSWorkerAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["eks-worker-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon
}

data "aws_iam_policy_document" "cluster_assume_role_policy" {
  statement {
    sid = "EKSClusterAssumeRole"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/templates/kubeconfig.tpl")}"

  vars {
    cluster_name                      = "${var.cluster_name}"
    endpoint                          = "${aws_eks_cluster.this.endpoint}"
    region                            = "${data.aws_region.current.name}"
    cluster_auth_base64               = "${aws_eks_cluster.this.certificate_authority.0.data}"
    context_name                      = "${var.kubeconfig_context_name}"
    user_name                         = "${var.kubeconfig_user_name}"
    aws_authenticator_command         = "${var.kubeconfig_aws_authenticator_command}"
    aws_authenticator_additional_args = "${length(var.kubeconfig_aws_authenticator_additional_args) > 0 ? "        - ${join("\n        - ", var.kubeconfig_aws_authenticator_additional_args)}" : "" }"
    aws_authenticator_env_variables   = "${length(var.kubeconfig_aws_authenticator_env_variables) > 0 ? "      env:\n${join("\n", data.template_file.aws_authenticator_env_variables.*.rendered)}" : ""}"
  }
}

data "template_file" "aws_authenticator_env_variables" {
  template = <<EOF
        - name: $${key}
          value: $${value}
EOF

  count = "${length(var.kubeconfig_aws_authenticator_env_variables)}"

  vars {
    value = "${element(values(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
    key   = "${element(keys(var.kubeconfig_aws_authenticator_env_variables), count.index)}"
  }
}

data template_file config_map_aws_auth {
  template = "${file("${path.module}/templates/config-map-aws-auth.yaml.tpl")}"

  vars {
    role_arn = "${aws_iam_role.workers.arn}"
  }
}

data template_file userdata {
  template = "${file("${path.module}/templates/userdata.sh.tpl")}"
  count    = "${length(var.worker_groups)}"

  vars {
    region              = "${data.aws_region.current.name}"
    cluster_name        = "${var.cluster_name}"
    endpoint            = "${aws_eks_cluster.this.endpoint}"
    cluster_auth_base64 = "${aws_eks_cluster.this.certificate_authority.0.data}"
    max_pod_count       = "${lookup(local.max_pod_per_node, lookup(var.worker_groups[count.index], "instance_type", lookup(var.workers_group_defaults, "instance_type")))}"
    pre_userdata        = "${lookup(var.worker_groups[count.index], "pre_userdata",lookup(var.workers_group_defaults, "pre_userdata"))}"
    additional_userdata = "${lookup(var.worker_groups[count.index], "additional_userdata",lookup(var.workers_group_defaults, "additional_userdata"))}"
  }
}
