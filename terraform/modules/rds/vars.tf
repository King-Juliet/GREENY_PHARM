variable "allocated_storage"{
    description = "Storage capacity for thr rds instance"
}


variable "max_allocated_storage"{
    description = "Max value to autoscale the rds instance to"
}


variable "instance_class"{
    description = "Type of compute node to use for the rds"
}


variable "storage_type"{
    description = "Type of storage to use for the rds instance"
}


variable "db_name"{
    description = "Name of master database"
}


variable "username"{
    description = "Username of master database"
}


variable "password"{
    description = "Password to master database"
}


variable "multi_az"{
    description = "True or False value based on whether you want the instance to be in multiple vailability zones "
}


variable "vpc_security_group_ids"{
    description = "Accepts a list of one or more security group ids for the rds instance"
}


variable "db_subnet_group_name"{
    description = "List of subnet group ids to deploy the rds"
}


variable "kms_key_arn"{
    description = "KMS encryption key arn"
}

