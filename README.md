# terraform-route53-backups
Backup aws route53 hosted zones and health checks to s3 bucket

module "backup-route53" {
  source = "git::ssh://username@example.com/storage.git"
  providers = {
    aws.src = aws.caask_ca1
  }
  bucket = "caask-route53-backups"
  retention_period = 14
}
