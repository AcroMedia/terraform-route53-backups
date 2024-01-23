terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = ">= 5.1.0"
        configuration_aliases = [ aws.src ]
    }
  }
}
