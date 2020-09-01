# AWS Public MSK Terraform module

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sagivle/erraform-aws-public-msk)


Terraform module that exposes an existing MSK cluster to the internet.

## Usage

```hcl
module "public_msk" {
  source = "sagivle/erraform-aws-public-msk/aws"

  deploy_name      = "my_msk"
  module_enabled   = true
  environment      = "prod"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| deploy\_name | The existing MSK cluster | `string` | `""` | yes |
| module\_enabled | Install MSKs unless set to false | `bool` | `true` | no |
| environment | Additional environment tags | `string` | `""` | yes |

## Requirements

- An existing MSK cluster.
- MSK in public subnets.
- MSK configured to use TLS.
