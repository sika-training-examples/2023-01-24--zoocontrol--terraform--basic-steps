## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.51.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 3.32.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.51.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 3.32.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/4.51.0/docs/resources/instance) | resource |
| [cloudflare_record.this](https://registry.terraform.io/providers/cloudflare/cloudflare/3.32.0/docs/resources/record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami"></a> [ami](#input\_ami) | AMI to use for the instance | `string` | `"ami-0c75b861029de4030"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use for the instance | `string` | `"t3.nano"` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | SSH Key name to use for the instance | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the ec2 instance | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data to pass to the instance | `any` | `null` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Cloudflare Zone ID to use for the DNS record | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_instance"></a> [aws\_instance](#output\_aws\_instance) | n/a |
| <a name="output_cloudflare_record"></a> [cloudflare\_record](#output\_cloudflare\_record) | n/a |
| <a name="output_domain"></a> [domain](#output\_domain) | n/a |
| <a name="output_ip"></a> [ip](#output\_ip) | n/a |
