# terraform-route53-backups
Backup aws route53 hosted zones and health checks to s3 bucket.

The module does the following 
* Creates an s3 bucket with a life-cycle policy to delete objects after 14 days.
* Uploads a lambda function to the specific region
* Creates a cloudwatch event that triggers the lambda to run every 24 hours(1440 minutes).

### How to use
Add the below to your terraform file

```
module "backup-route53" {
  source = "git@github.com:AcroMedia/terraform-route53-backups.git?ref=main"
  providers = {
    aws.src = aws.src #change-me
  }
  bucket = "acc-name-route53-backups" #change-me
  retention_period = 14 #change-me
  region = us-east-1 #change-me
}
```


