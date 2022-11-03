<a name="readme-top"></a>

# Terraform AWS S3 Uploader Module

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#features">Features</a></li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#requirements">Terraform Docs</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

A terraform project which calls a variety of modules to create a media upload and rekognition application based on serverless services.

The project creates a S3 hosted web front-end that allow upload of image or video files to a private S3 bucket. On upload, Event Bridge invokes a State Function machine which detects the image's MIME-Type and runs the appropriate AWS Rekognition function to establish the labels visible within the media. The labels output is stored in DynamoDB for future reference and is searchable via the web front-end. A Slack notification is also sent on completion of each Rekognition process.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FEATURES -->
## Features

The module deploys the following AWS infrastructure:
* 1x DynamoDB
* 1x S3 Bucket
* 1x terraform-aws-s3-website module (https://github.com/mpsamuels/terraform-aws-s3-website)
* 3x terraform-aws-state-machine modules (https://github.com/mpsamuels/terraform-aws-state-machine)
* 5x terraform-aws-lambda modules (https://github.com/mpsamuels/terraform-aws-lambda)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE -->
## Usage

```hcl

```



<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/mpsamuels/terraform-aws-lambda/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- REQUIREMENTS -->

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dynamo_lambda"></a> [dynamo\_lambda](#module\_dynamo\_lambda) | git@github.com:mpsamuels/terraform-aws-lambda.git//terraform | n/a |
| <a name="module_s3_images_to_rekognition"></a> [s3\_images\_to\_rekognition](#module\_s3\_images\_to\_rekognition) | git@github.com:mpsamuels/terraform-aws-state-machine.git//terraform | n/a |
| <a name="module_s3_upload_type_check"></a> [s3\_upload\_type\_check](#module\_s3\_upload\_type\_check) | git@github.com:mpsamuels/terraform-aws-lambda.git//terraform | n/a |
| <a name="module_s3_uploader"></a> [s3\_uploader](#module\_s3\_uploader) | git@github.com:mpsamuels/terraform-aws-s3-website.git//terraform | n/a |
| <a name="module_s3_video_to_rekognition"></a> [s3\_video\_to\_rekognition](#module\_s3\_video\_to\_rekognition) | git@github.com:mpsamuels/terraform-aws-state-machine.git//terraform | n/a |
| <a name="module_signed_url_download_lambda"></a> [signed\_url\_download\_lambda](#module\_signed\_url\_download\_lambda) | git@github.com:mpsamuels/terraform-aws-lambda.git//terraform | n/a |
| <a name="module_signed_url_lambda"></a> [signed\_url\_lambda](#module\_signed\_url\_lambda) | git@github.com:mpsamuels/terraform-aws-lambda.git//terraform | n/a |
| <a name="module_slack_notification"></a> [slack\_notification](#module\_slack\_notification) | git@github.com:mpsamuels/terraform-aws-lambda.git//terraform | n/a |
| <a name="module_wrapper_state_machine"></a> [wrapper\_state\_machine](#module\_wrapper\_state\_machine) | git@github.com:mpsamuels/terraform-aws-state-machine.git//terraform | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.dynamo_db_rekognition_results](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.upload_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.root_bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.upload_bucket_cors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_public_access_block.upload_bucket_public_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The hosted zone domain name used by the HTML frontend | `string` | n/a | yes |
| <a name="input_prefix_name"></a> [prefix\_name](#input\_prefix\_name) | String to prefix to resources names | `string` | n/a | yes |

## Outputs

No outputs.