## Create a AWS WorkSpace using Terraform.

#### Amazon WorkSpaces enables you to provision virtual, cloud-based Windows or Linux desktops for your users and that is called WorkSpaces. WorkSpaces eliminates the need to procure and deploy hardware or install complex or required software. You can quickly add or remove users as your needs change. Users can access their virtual desktops from multiple devices or web browsers. You can follow this [link](https://docs.aws.amazon.com/workspaces/latest/adminguide/amazon-workspaces.html) to know more.

-------------

**Files:** 
```
    module.tf
    provider.tf
    resource.tf 
```

## Apply the terraform script

1. First configure the aws credentials using aws-cli with your profile name.

        aws configure --profile terraform

2. Now, from the current directory run the following command to validate the script.

        terraform validate
3. Now intialize the current working directory.

         terraform init
3. To check the plan for the terraform

        terraform plan

4. Applying the terraform script

        terraform apply -auto-approve
