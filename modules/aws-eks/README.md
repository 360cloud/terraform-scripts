# terraform-aws-eks

A terraform module to create a managed Kubernetes cluster on AWS EKS.
Inspired by and adapted from [this doc](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)
and its [source code](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started).
Read the [AWS docs on EKS to get connected to the k8s dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html).

## Assumptions

* You want to create an EKS cluster and an autoscaling group of workers for the cluster.
* You want these resources to exist within security groups that allow communication and coordination. These can be user provided or created within the module.
* You've created a Virtual Private Cloud (VPC) and subnets where you intend to put the EKS resources.
* If using the default variable value (`true`) for `configure_kubectl_session`, it's required that both [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl) (>=1.10) and [`heptio-authenticator-aws`](https://github.com/heptio/authenticator#4-set-up-kubectl-to-use-heptio-authenticator-for-aws-tokens) are installed and on your shell's PATH.

## Usage example

A full example leveraging other community modules is contained in the [examples/eks_test_fixture directory](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture). Here's the gist of using it via the Terraform registry:

```hcl
module "eks" {
  source                = "terraform-aws-modules/eks/aws"
  cluster_name          = "test-eks-cluster"
  subnets               = ["subnet-abcde012", "subnet-bcde012a"]
  tags                  = "${map("Environment", "test")}"
  vpc_id                = "vpc-abcde012"
}
```

## Release schedule

Generally the maintainers will try to release the module once every 2 weeks to
keep up with PR additions. If particularly pressing changes are added or maintainers
come up with the spare time (hah!), release may happen more often on occasion.

## Testing

This module has been packaged with [awspec](https://github.com/k1LoW/awspec) tests through [kitchen](https://kitchen.ci/) and [kitchen-terraform](https://newcontext-oss.github.io/kitchen-terraform/). To run them:

1. Install [rvm](https://rvm.io/rvm/install) and the ruby version specified in the [Gemfile](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/Gemfile).
2. Install bundler and the gems from our Gemfile:

    ```bash
    gem install bundler && bundle install
    ```

3. Ensure your AWS environment is configured (i.e. credentials and region) for test.
4. Test using `bundle exec kitchen test` from the root of the repo.

For now, connectivity to the kubernetes cluster is not tested but will be in the
future. If `configure_kubectl_session` is set `true`, once the test fixture has
converged, you can query the test cluster from that terminal session with
`kubectl get nodes --watch --kubeconfig kubeconfig`.



## IAM Permissions

Testing and using this repo requires a minimum set of IAM permissions. Test permissions
are listed in the [eks_test_fixture README](https://github.com/terraform-aws-modules/terraform-aws-eks/tree/master/examples/eks_test_fixture/README.md).


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| cluster_name | Name of the EKS cluster. Also used as a prefix in names of related resources. | string | - | yes |
| cluster_security_group_id | If provided, the EKS cluster will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the workers and provide API access to your current IP/32. | string | `` | no |
| cluster_version | Kubernetes version to use for the EKS cluster. | string | `1.10` | no |
| config_output_path | Determines where config files are placed if using configure_kubectl_session and you want config files to land outside the current working directory. | string | `./` | no |
| configure_kubectl_session | Configure the current session's kubectl to use the instantiated EKS cluster. | string | `true` | no |
| kubeconfig_aws_authenticator_additional_args | Any additional arguments to pass to the authenticator such as the role to assume ["-r", "MyEksRole"] | string | `<list>` | no |
| kubeconfig_aws_authenticator_command | Command to use to to fetch AWS EKS credentials | string | `heptio-authenticator-aws` | no |
| kubeconfig_aws_authenticator_env_variables | Environment variables that should be used when executing the authenticator i.e. { AWS_PROFILE = "eks"} | string | `<map>` | no |
| kubeconfig_context_name | Name of the kubeconfig context. | string | `aws` | no |
| kubeconfig_user_name | Name of the kubeconfig user. | string | `aws` | no |
| subnets | A list of subnets to place the EKS cluster and workers within. | list | - | yes |
| tags | A map of tags to add to all resources. | string | `<map>` | no |
| vpc_id | VPC where the cluster and workers will be deployed. | string | - | yes |
| worker_groups | A list of maps defining worker group configurations. See workers_group_defaults for valid keys. | list | `<list>` | no |
| worker_security_group_id | If provided, all workers will be attached to this security group. If not given, a security group will be created with necessary ingres/egress to work with the EKS cluster. | string | `` | no |
| worker_sg_ingress_from_port | Minimum port number from which pods will accept communication. Must be changed to a lower value if some pods in your cluster will expose a port lower than 1025 (e.g. 22, 80, or 443). | string | `1025` | no |
| workers_group_defaults | Default values for target groups as defined by the list of maps. | map | `<map>` | no |
| workstation_cidr | Override the default ingress rule that allows communication with the EKS cluster API. If not given, will use current IP/32. | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_certificate_authority_data | Nested attribute containing certificate-authority-data for your cluster. This is the base64 encoded certificate data required to communicate with your cluster. |
| cluster_endpoint | The endpoint for your EKS Kubernetes API. |
| cluster_id | The name/id of the EKS cluster. |
| cluster_security_group_id | Security group ID attached to the EKS cluster. |
| cluster_version | The Kubernetes server version for the EKS cluster. |
| config_map_aws_auth | A kubernetes configuration to authenticate to this EKS cluster. |
| kubeconfig | kubectl config file contents for this EKS cluster. |
| worker_iam_role_name | IAM role name attached to EKS workers |
| worker_security_group_id | Security group ID attached to the EKS workers. |
| workers_asg_arns | IDs of the autoscaling groups containing workers. |
