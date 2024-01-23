data "archive_file" "lambda_zip" {
  type = "zip"
  source_dir = "${path.module}/backup"
  output_path = "backup-route53.zip"
}

resource "aws_lambda_function" "route53_backup" {
  provider = aws.src
  function_name    = "backup-route53"
  runtime          = "python3.10"
  handler          = "backup_route53.handle"
  role             = aws_iam_role.lambda_exec_role.arn
  publish = true
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  environment {
    variables = {
      BUCKET            = var.bucket,
      RETENTION_PERIOD  = var.retention_period
    }
  }
  timeout = 300
}

resource "aws_iam_role" "lambda_exec_role" {
  provider = aws.src
  name = "route53-backup-lambda-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com",
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  provider = aws.src
  name = "lambda_execution_policy"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    "Statement": [
		{
			"Sid": "VisualEditor0",
			"Effect": "Allow",
			"Action": [
				"s3:PutEncryptionConfiguration",
				"s3:PutObject",
				"logs:CreateLogStream",
				"s3:PutLifecycleConfiguration",
				"s3:PutBucketPolicy",
				"s3:CreateBucket",
				"s3:ListBucket",
				"logs:CreateLogGroup",
				"logs:PutLogEvents",
				"s3:PutBucketVersioning"
			],
			"Resource": [
				"arn:aws:s3:::${var.bucket}/*",
				"arn:aws:s3:::${var.bucket}"
			]
		},
		{
			"Sid": "VisualEditor1",
			"Effect": "Allow",
			"Action": [
				"route53:ListTagsForResources",
				"route53:ListHealthChecks",
				"route53:GetHostedZone",
				"route53:ListHostedZones",
				"route53:ListResourceRecordSets",
				"route53:GetHealthCheck",
				"route53:ListHostedZonesByName",
				"route53:ListTagsForResource"
			],
			"Resource": "*"
		}
      ]
  })
}

resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  provider = aws.src
  name        = "route53-scheduled-backup-trigger"
  description = "Rule to schedule route53 backup  Lambda function execution"
  schedule_expression = "rate(1440 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  provider = aws.src
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "lambda_target"
  arn = aws_lambda_function.route53_backup.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_scheduler" {
  provider = aws.src
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.route53_backup.arn
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.lambda_schedule.arn
}

