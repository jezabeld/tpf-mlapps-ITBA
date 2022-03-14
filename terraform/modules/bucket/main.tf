resource "aws_s3_bucket" "mwaabucket" {
	# variable para indicar creacion o no del bucket
	#count = var.create_bucket ? 1 : 0
	#bucket = var.bucket_name
	versioning {
		enabled = true
	}
	tags = var.v_tags
	force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "mwaa" {
	# required: https://docs.aws.amazon.com/mwaa/latest/userguide/mwaa-s3-bucket.html
	bucket                  = aws_s3_bucket.mwaabucket.id #? aws_s3_bucket.mwaabucket.id : "arn:aws:s3:::${var.bucket_name}"
	block_public_acls       = true
	block_public_policy     = true
	ignore_public_acls      = true
	restrict_public_buckets = true

	provisioner "local-exec" {
		command = <<EOF
cd .. ;
aws s3 sync config/ s3://${aws_s3_bucket.mwaabucket.id}/config/ --profile ${var.profile};
aws s3 sync dags/ s3://${aws_s3_bucket.mwaabucket.id}/${var.dag_s3_path}/ --profile ${var.profile};
mkdir data && cd data ;
kaggle datasets download -d yuanyuwendymu/airline-delay-and-cancellation-data-2009-2018
unzip airline-delay-and-cancellation-data-2009-2018.zip -d raw/;
aws s3 sync raw/ s3://${aws_s3_bucket.mwaabucket.id}/data/ --profile ${var.profile};
rm airline-delay-and-cancellation-data-2009-2018.zip;
EOF
	}
}
/**/