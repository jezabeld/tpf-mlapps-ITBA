resource "aws_s3_bucket" "mwaabucket" {
	# variable para indicar creacion o no del bucket
	count = var.create_bucket ? 1 : 0
	bucket = var.bucket_name

	# required: https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-s3-bucket.html
	versioning {
		enabled = true
	}
	tags = var.v_tags
}

resource "aws_s3_bucket_public_access_block" "mwaa" {
	# required: https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-s3-bucket.html
	bucket                  = aws_s3_bucket.mwaabucket.id ? aws_s3_bucket.mwaabucket.id : "arn:aws:s3:::${var.bucket_name}"
	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true
}
