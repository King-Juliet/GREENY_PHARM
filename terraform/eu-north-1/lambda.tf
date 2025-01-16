# IAM policy for Lambda to allow lambda function assume roles that will be created for it to assume

data "aws_iam_policy_document" "lambda_execution_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

#s3 access policy
data "aws_iam_policy_document" "lambda_s3_access_policy" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::greeny-pharma-datalake"]  # Permission for the bucket itself
    effect    = "Allow"
  }
  
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::greeny-pharma-datalake/*"]  # Permission for objects in the bucket
    effect    = "Allow"
  }
}

#RDS access policy
data "aws_iam_policy_document" "lambda_rds_access_policy"{
    statement {
    actions   = ["rds-db:*", "rds:*"]
    resources = ["*"]  # Adjust this to match specific resources if needed
    effect    = "Allow"
  }
}

#Redshift serverless access policy
data "aws_iam_policy_document" "lambda_redshift_access_policy"{
    statement {
    effect = "Allow"

    # Allow Lambda functions to interact with Redshift Serverless
    actions = [
      "redshift-serverless:GetWorkgroup",
      "redshift-serverless:GetNamespace",
      "redshift-serverless:ListNamespaces",
      "redshift-serverless:ListWorkgroups",
      "redshift-serverless:ExecuteStatement",
      "redshift-serverless:GetCredentials"
    ]

    #ARN of Redshift Serverless resources
    resources = [
      "arn:aws:redshift-serverless:eu-north-1:account-id:workgroup/greeny-data-workgroup",
      "arn:aws:redshift-serverless:eu-north-1:account-id:namespace/greeny-data-namespace"
    ]
  }

}


# Create lambda execution role and attach the IAM policy to the step function execution role-- Basic Execution policy attachment

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_execution_policy.json
}


# Attach the s3 bucket access policy to the created lambda execution role-- s3 bucket access policy attachment

resource "aws_iam_role_policy" "lambda_s3_access_policy_attachment" {
  name = "lambda_s3_access_policy_attachment"
  role = aws_iam_role.lambda_execution_role.name
  policy = data.aws_iam_policy_document.lambda_s3_access_policy.json
}

# Attach the RDS access policy to the created lambda execution role-- RDS access policy attachment

resource "aws_iam_role_policy" "lambda_rds_access_policy_attachment" {
  name = "lambda_rds_access_policy_attachment"
  role = aws_iam_role.lambda_execution_role.name
  policy = data.aws_iam_policy_document.lambda_rds_access_policy.json
}


#Attach Redshift access policy to the created lambda execution role -- Redshift access policy attachment
resource "aws_iam_role_policy" "lambda_redshift_access_policy_attachment" {
  name = "lambda_redshift_access_policy_attachment"
  role = aws_iam_role.lambda_execution_role.name
  policy = data.aws_iam_policy_document.lambda_redshift_access_policy.json
}


# security group - lambda can only initiate outbound traffic, hence only egress rule required
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-function-sg"
  vpc_id      = module.vpc_module.vpc_id
  lifecycle {
    create_before_destroy = true
  }
}


#egress rule for rds
resource "aws_security_group_rule" "lambda_to_postgres" {
  type              = "egress"
  security_group_id = aws_security_group.lambda_sg.id
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  source_security_group_id = [aws_security_group.rds_security_group.id]
  description       = "Allow Lambda to send queries to PostgreSQL"
}

#egress rule for s3 bucket
resource "aws_security_group_rule" "lambda_to_s3" {
  type              = "egress"
  security_group_id = aws_security_group.lambda_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"  
  cidr_blocks       = ["0.0.0.0/0"]  
  description       = "Allow Lambda to send data to S3"
}


#egress rule for redshift
resource "aws_security_group_rule" "lambda_to_redshift" {
  type              = "egress"
  security_group_id = aws_security_group.lambda_sg.id
  from_port         = 5439
  to_port           = 5439
  protocol          = "tcp"
  source_security_group_id = [aws_security_group.redshift_security_group.id]  # Replace with Redshift CIDR block or its security group
  description       = "Allow Lambda to send data to Redshift"
}


#set lambda functions

resource "aws_lambda_function" "lambda_src_to_s3_raw" {
  function_name = "lambda_src_to_s3_raw"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.upload_src_data_to_s3"]  # Ensure it points to /app/
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_s3raw_to_s3staging" {
  function_name = "lambda_s3raw_to_s3staging"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.s3raw_to_s3staging"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_google_form_feedback" {
  function_name = "lambda_google_form_feedback"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.google_form_to_s3"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
 

resource "aws_lambda_function" "lambda_customers_processing_func" {
  function_name = "lambda_customers_processing_func"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.main_processing_customers"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_inventory_processing_func" {
  function_name = "lambda_inventory_processing_func"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.main_processing_inventory"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_orders_processing_func" {
  function_name = "lambda_orders_processing_func"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.main_processing_orders"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_products_processing_func" {
  function_name = "lambda_products_processing_func"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.main_processing_products"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_suppliers_processing_func" {
  function_name = "lambda_suppliers_processing_func"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.main_processing_suppliers"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_departments_processing_func" {
  function_name = "lambda_departments_processing_func"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.main_processing_departments"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}


resource "aws_lambda_function" "lambda_purchase_order_processing_func" {
  function_name = "lambda_purchase_order_processing_func"

  image_uri = "${module.greeny_ecr.repository_url}:latest"

  package_type = "Image"

  image_config {
    command = ["lambda_functions.main_processing_purchase_order"]
  }

  role = aws_iam_role.lambda_execution_role.arn

  memory_size = 512
  timeout = 900

  vpc_config {
    subnet_ids         = [module.lambda_subnet.subnet_id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}