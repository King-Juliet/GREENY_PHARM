variable "namespace_name"{
    description = "Name of redshift namespace"
}


variable "db_name"{
    description = "Name of master database"
}


variable "admin_username"{
    description = "Username of master database"
}


variable "admin_user_password"{
    description = "Password of master database"
}


variable "kms_key_arn"{
    description = "ARN of the kms key to use for enrypting data"
}


variable "owner"{
    description = "Team that deployed the redshift serverless"
}


variable "workgroup_name"{
    description = "Name of redshift workgroup"
}


variable "base_capacity"{
    description = "Base capacity for the workgroup"
}


variable "security_group_ids"{
    description = "List of security group ids to attach to the redshift"
}


variable "subnet_ids"{
    description = "List of subnet ids to provison the redshift"
}
