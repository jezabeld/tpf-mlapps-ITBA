# aws_iam_role.mwaarole:
resource "aws_iam_role" "mwaarole" {
    assume_role_policy    = data.aws_iam_policy_document.assume.json
    
    force_detach_policies = false
#    max_session_duration  = 3600
    name                  = "${var.env_name}-Role"
    path                  = "/service-role/"
    tags                  = var.v_tags
}


resource "aws_iam_role_policy" "mwaapolicy" {
    name = "mymwaapolicy"
    policy = data.aws_iam_policy_document.this.json
    role = aws_iam_role.mwaarole.id
}

data "aws_iam_policy_document" "assume" {
    version = "2012-10-17"
    statement {
            actions    = ["sts:AssumeRole"]
            effect    = "Allow"
            principals {
                identifiers = [
                    "airflow.amazonaws.com",
                    "airflow-env.amazonaws.com",
                ]
                type = "Service"
            }
        }

}

data "aws_iam_policy_document" "base" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "airflow:PublishMetrics"
    ]
    resources = [
      "arn:aws:airflow:us-east-1:*:environment/${var.env_name}"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:GetLogRecord",
      "logs:GetLogGroupFields",
      "logs:GetQueryResults"
    ]
    resources = [
      "arn:aws:logs:us-east-1:*:log-group:airflow-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
  statement {

    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]
    resources = [
      "arn:aws:sqs:us-east-1:*:airflow-celery-*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt"
    ]
    not_resources = [
      "arn:aws:kms:*:${var.account_id}:key/*"
    ]
    condition {
      test = "StringLike"
      values = [
        "sqs.us-east-1.amazonaws.com"]
      variable = "kms:ViaService"
    }
  }
}
data "aws_iam_policy_document" "aditional" {
    statement {
      effect = "Allow"
      actions = [
            "secretsmanager:GetResourcePolicy",
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds"
      ]
      resources = [ "arn:aws:secretsmanager:us-east-1:*:secret:*"]
    }
    statement {
      effect = "Allow"
      actions = [
          "secretsmanager:ListSecrets"
      ]
      resources = [ "*" ]
    }
    statement {
      effect = "Allow"
      actions = [
        "s3:PutObject*"
      ]
      resources = [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
}
data "aws_iam_policy_document" "this" {
  source_policy_documents = [
    data.aws_iam_policy_document.base.json ,
    data.aws_iam_policy_document.aditional.json
  ]
}