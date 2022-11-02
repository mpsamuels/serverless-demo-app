module "s3_uploader" {
  #source      = "../terraform-aws-s3-website/terraform"
  source      = "git@github.com:mpsamuels/terraform-aws-s3-website.git//terraform"
  domain_name = var.domain_name
  prefix_name = var.prefix_name
  content     = templatefile("${path.module}/templates/web_page/index.tpl", { domain = var.domain_name })
}

module "s3_images_to_rekognition" {
  #source                       = "../terraform-aws-state-machine/terraform"
  source                       = "git@github.com:mpsamuels/terraform-aws-state-machine.git//terraform"
  prefix_name                  = "${var.prefix_name}-images"
  create_cloudwatch_event_rule = false
  upload_bucket_name           = aws_s3_bucket.upload_bucket.bucket
  definition                   = templatefile("${path.module}/templates/state_machines/image/state_machine.tpl", { region = data.aws_region.current.name, account = data.aws_caller_identity.current.account_id, source_bucket = aws_s3_bucket.upload_bucket.bucket, db = aws_dynamodb_table.dynamo_db_rekognition_results.name, lambda = module.slack_notification.aws_lambda_function })
  policy                       = templatefile("${path.module}/templates/state_machines/image/state_machine_policy.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket })
}

module "s3_video_to_rekognition" {
  #source                       = "../terraform-aws-state-machine/terraform"
  source                       = "git@github.com:mpsamuels/terraform-aws-state-machine.git//terraform"
  prefix_name                  = "${var.prefix_name}-video"
  create_cloudwatch_event_rule = false
  upload_bucket_name           = aws_s3_bucket.upload_bucket.bucket
  definition                   = templatefile("${path.module}/templates/state_machines/video/state_machine.tpl", { region = data.aws_region.current.name, account = data.aws_caller_identity.current.account_id, source_bucket = aws_s3_bucket.upload_bucket.bucket, db = aws_dynamodb_table.dynamo_db_rekognition_results.name, lambda = module.slack_notification.aws_lambda_function })
  policy                       = templatefile("${path.module}/templates/state_machines/video/state_machine_policy.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket })
}

module "wrapper_state_machine" {
  #source                       = "../terraform-aws-state-machine/terraform"
  source                       = "git@github.com:mpsamuels/terraform-aws-state-machine.git//terraform"
  prefix_name                  = "${var.prefix_name}-wrapper"
  create_cloudwatch_event_rule = true
  upload_bucket_name           = aws_s3_bucket.upload_bucket.bucket
  definition                   = templatefile("${path.module}/templates/state_machines/wrapper/state_machine.tpl", { region = data.aws_region.current.name, account = data.aws_caller_identity.current.account_id, image_machine = module.s3_images_to_rekognition.aws_sfn_state_machine, video_machine = module.s3_video_to_rekognition.aws_sfn_state_machine, lambda = module.s3_upload_type_check.aws_lambda_function })
  policy                       = templatefile("${path.module}/templates/state_machines/wrapper/state_machine_policy.tpl", { region = data.aws_region.current.name, account = data.aws_caller_identity.current.account_id, bucket = aws_s3_bucket.upload_bucket.bucket })

}

module "s3_upload_type_check" {
  #source             = "../terraform-aws-lambda/terraform"
  source             = "git@github.com:mpsamuels/terraform-aws-lambda.git//terraform"
  prefix_name        = "${var.prefix_name}-upload-type-check"
  upload_bucket_name = aws_s3_bucket.upload_bucket.bucket
  runtime            = "nodejs16.x"
  handler            = "app.handler"
  file_name          = "app.js"
  lambda             = templatefile("${path.module}/templates/lambda/file_type_check/lambda.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket, region = data.aws_region.current.name })
  policy             = templatefile("${path.module}/templates/lambda/file_type_check/lambda_policy.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket })
}

module "dynamo_lambda" {
  #source              = "../terraform-aws-lambda/terraform"
  source             = "git@github.com:mpsamuels/terraform-aws-lambda.git//terraform"
  prefix_name         = "${var.prefix_name}-dynamo-search"
  upload_bucket_name  = aws_s3_bucket.upload_bucket.bucket
  domain_name         = var.domain_name
  create_api_gw       = true
  stage_name          = "dynamo"
  handler             = "app.handler"
  runtime             = "python3.9"
  file_name           = "app.py"
  lambda              = templatefile("${path.module}/templates/lambda/dynamo_search/lambda.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket, region = data.aws_region.current.name, domain_name = var.domain_name, dynamo_table = aws_dynamodb_table.dynamo_db_rekognition_results.name })
  policy              = templatefile("${path.module}/templates/lambda/dynamo_search/lambda_policy.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket })
  aws_acm_certificate = module.s3_uploader.aws_acm_certificate
  r53_zone            = module.s3_uploader.aws_route53_zone
}

module "signed_url_lambda" {
  #source              = "../terraform-aws-lambda/terraform"
  source             = "git@github.com:mpsamuels/terraform-aws-lambda.git//terraform"
  prefix_name         = "${var.prefix_name}-file-uploader"
  upload_bucket_name  = aws_s3_bucket.upload_bucket.bucket
  domain_name         = var.domain_name
  create_api_gw       = true
  stage_name          = "signedurl"
  runtime             = "nodejs16.x"
  handler             = "app.handler"
  file_name           = "app.js"
  lambda              = templatefile("${path.module}/templates/lambda/signed_url/lambda.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket, region = data.aws_region.current.name, domain_name = var.domain_name })
  policy              = templatefile("${path.module}/templates/lambda/signed_url/lambda_policy.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket })
  aws_acm_certificate = module.s3_uploader.aws_acm_certificate
  r53_zone            = module.s3_uploader.aws_route53_zone
}

module "signed_url_download_lambda" {
  #source              = "../terraform-aws-lambda/terraform"
  source             = "git@github.com:mpsamuels/terraform-aws-lambda.git//terraform"  
  prefix_name         = "${var.prefix_name}-file-downloader"
  upload_bucket_name  = aws_s3_bucket.upload_bucket.bucket
  domain_name         = var.domain_name
  create_api_gw       = true
  stage_name          = "downloader"
  runtime             = "nodejs16.x"
  handler             = "app.handler"
  file_name           = "app.js"
  lambda              = templatefile("${path.module}/templates/lambda/signed_url_download/lambda.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket, region = data.aws_region.current.name, domain_name = var.domain_name })
  policy              = templatefile("${path.module}/templates/lambda/signed_url_download/lambda_policy.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket })
  aws_acm_certificate = module.s3_uploader.aws_acm_certificate
  r53_zone            = module.s3_uploader.aws_route53_zone
}

module "slack_notification" {
  #source             = "../terraform-aws-lambda/terraform"
  source             = "git@github.com:mpsamuels/terraform-aws-lambda.git//terraform"
  prefix_name        = "${var.prefix_name}-slack-notification"
  upload_bucket_name = aws_s3_bucket.upload_bucket.bucket
  domain_name        = var.domain_name
  stage_name         = "slack"
  handler            = "app.handler"
  runtime            = "python3.9"
  file_name          = "app.py"
  lambda             = templatefile("${path.module}/templates/lambda/slack_notification/lambda.tpl", { ssm_secret = var.ssm_secret, region = data.aws_region.current.name, domain_name = var.domain_name })
  policy             = templatefile("${path.module}/templates/lambda/slack_notification/lambda_policy.tpl", { bucket = aws_s3_bucket.upload_bucket.bucket })
}
