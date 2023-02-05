
## Problem Statement:
- Create the private key and security group which allows the port 80.
- Launch Amazon AWS EC2 instance.
- In this EC2 instance use the key and security group which we have created in step 1 to log-in remote or local.
- Launch one Volume (EBS) and mount that volume into /var/www/html
- The developer has uploaded the code into GitHub repo also the repo has some images.
- Copy the GitHub repo code into /var/www/html
- Create an S3 bucket, and copy/deploy the images from GitHub repo into the s3 bucket and change the permission to public readable.
- Create a Cloudfront using S3 bucket(which contains images) and use the Cloudfront URL to update in code in /var/www/html
# The procedure of this project is explained step by step in this blog:
[Blog for DevOps project using Terraform Automation](https://vishal7771.hashnode.dev/devops-project-to-setup-infrastructure-on-aws-using-terraform)

# Author
[Vishal](https://github.com/VishalPraneeth)

