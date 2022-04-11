resource "aws_s3_bucket" "log_bucket" {
    bucket = "my-tf-log-bucket"
    # acl = "log-delivery-write"
    acl = "public-read"
    tags = {
        region = "us-east-2"
        Demo = "log-delivery-write"
        Version = "12"
  }
    server_side_encryption_configuration {
        rule {
            apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
            }
        }
    }
    acl    = var.s3_bucket_acl
    bucket = var.s3_bucket_name
    policy = var.s3_bucket_policy
    force_destroy = var.s3_bucket_force_destroy
    versioning {
        enabled    = var.versioning
        mfa_delete = var.mfa_delete
    }
    dynamic "logging" {
        for_each = var.logging
        content {
            target_bucket = logging.value["target_bucket"]
            target_prefix = "log/${var.s3_bucket_name}"
        }
    }
    replication_configuration {
        role = aws_iam_role.replication.arn
        rules {
            id     = "foobar"
            prefix = "foo"
            status = "Enabled"
            destination {
                bucket        = aws_s3_bucket.destination.arn
                storage_class = "STANDARD"
            }
        }
    }
}
resource "aws_s3_bucket_public_access_block" "log_bucket" {
    bucket = aws_s3_bucket.log_bucket.id
    block_public_acls   = true
    block_public_policy = true
    restrict_public_buckets = true
    ignore_public_acls=true
}
