resource "aws_directory_service_directory" "managed-ad-by-aws" {
  name = "demo.local"
  description = "Muzakkir Managed Directory Service"
  password = "Development123"
  edition = "Standard"
  type = "MicrosoftAD"
  vpc_settings {
    vpc_id = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
  }
  tags = {
    Name = "Muzakkir-managed-ad"
    Environment = "Development"
  }
}




resource "aws_vpc_dhcp_options" "dns_resolver" {

  domain_name_servers = aws_directory_service_directory.managed-ad-by-aws.dns_ip_addresses

  domain_name = "demolocal"

  tags = {

    Name = "demo-dev"

    Environment = "Development"

  }

}




resource "aws_vpc_dhcp_options_association" "dns_resolver" {

  vpc_id = module.vpc.vpc_id

  
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id

}






data "aws_iam_policy_document" "workspaces" {

  statement {

    actions = ["sts:AssumeRole"]

    principals {

      type = "Service"

      identifiers = ["workspaces.amazonaws.com"]

    }

  }

}


resource "aws_iam_role" "workspaces-default" {

  name = "workspaces_Role"

  assume_role_policy = data.aws_iam_policy_document.workspaces.json

}

resource "aws_iam_role_policy_attachment" "workspaces-default-service-access" {

  role = aws_iam_role.workspaces-default.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess"

}

resource "aws_iam_role_policy_attachment" "workspaces-default-self-service-access" {

  role = aws_iam_role.workspaces-default.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"

}






resource "aws_workspaces_directory" "workspaces-directory" {

 directory_id = aws_directory_service_directory.managed-ad-by-aws.id

  subnet_ids   = module.vpc.private_subnets

  depends_on = [aws_iam_role.workspaces-default]


}

# Windows Standard Bundle

data "aws_workspaces_bundle" "standard_windows" {

 bundle_id = "wsb-8vbljg4r6"

}
# Linux Standard Bundle
data "aws_workspaces_bundle" "standard_linux" {
  bundle_id = "wsb-clj85qzj1"
}

resource "aws_kms_key" "workspaces-kms" {
  description = "Muzakkir  KMS"
  deletion_window_in_days = 7
}



resource "aws_workspaces_workspace" "workspaces" {

  directory_id = aws_workspaces_directory.workspaces-directory.id

  bundle_id = data.aws_workspaces_bundle.standard_linux.id


  user_name = "Demo"

  root_volume_encryption_enabled = true

  user_volume_encryption_enabled = true

  volume_encryption_key = aws_kms_key.workspaces-kms.arn

  workspace_properties {

    compute_type_name = "STANDARD"

    user_volume_size_gib = 50

    root_volume_size_gib = 80

    running_mode = "AUTO_STOP"

    running_mode_auto_stop_timeout_in_minutes = 60

  }

  tags = {

    Name = "demo-workspaces"

    Environment = "dev"

  }

  depends_on = [

    aws_iam_role.workspaces-default,

    aws_workspaces_directory.workspaces-directory

  ]

}