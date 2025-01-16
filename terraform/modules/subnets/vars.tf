variable "vpc_id"{
    description = "ID of the vpc to proovision the subnet"
    }


variable "subnet_cidr"{
    description = "CIDR block range of the subnet"
}


variable "az"{
    description = "Availability zone to provision the subnet"
}


variable "map_public_ip_on_launch"{
    description = "False or True based on whether to attach public IP address to the subnet"
    default = false
}


variable "subnet_name"{
    description = "Name of the subnet"
}


variable "subnet_owner"{
    description = "Team that created the subnet"
}
