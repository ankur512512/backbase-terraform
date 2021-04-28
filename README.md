Bonus Task (required for Senior):
- This task exists because we interested in your terraform knowledge, you can choose to complete it
or not.
- Make a small terraform project, that deploys a centos AMI to a new VPC.
- I want to be able to curl http://google.com from inside the AMI.
- you choose the rest of the details, if any.



Solution:

Prerequites:

1. Terraform installed (v0.15.0)
2. A key pair for EC2 instances (ssh key pair that we will be using to connect to ec2 instance, here we have used id_rsa.pub and id_rsa for public and private key respectively.)


Steps: 

1. Download the source code in your working directory using below command.

	git clone url
	
2. cd into that project with below command:

    cd backbase-terraform
	
3. Copy the public and private key from your home directory to current working directory where the code exists. (modify the source path if you need)

	cp ~/.ssh/id_rsa* .
	
   You will see the id_rsa and id_rsa.pub file copied into the working directory.
   
4. Modify the main.tf file to provide AWS credentials. Replace my-access-key and my-secret-key with your own AWS account's access key and secret key and save it.

	provider "aws" {
      profile    = "default"
      region     = "us-east-1"
      access_key = "my-access-key"
      secret_key = "my-secret-key"
    }
	
5. Run the terraform commands.

	terraform fmt
	terraform init
	terraform plan
	terraform apply
	
  Wait till terraforom creates all the resources and until you see a message like this:
  
  Apply complete! Resources: 3 added, 1 changed, 1 destroyed.
  
6. Testing: Check the AWS console to see all the resources created as execpted. 

  Navigate to EC2 instances for region "us-east-1" and you will find a EC2 instance with name "centos" running there.
  Get the public ip from "Public IPv4 address" field for this instance.

  ssh to the instance using below command:
  
    ssh -o StrictHostKeyChecking=no centos@<public-ip of your instance>

  Now you can run curl command to see the connectivity with google:
    curl -L http://google.com
	
  (We have used -L option to follow the automatic redirects otherwise we get 301 Moved status)	
