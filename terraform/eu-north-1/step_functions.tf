# IAM policy for stfn to allow it assume policies attached to  roles it is to assume, when created. -- basic execution policy
data "aws_iam_policy_document" "stfn_execution_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


# IAM policy to allow Step Functions to invoke the three Lambda functions created
data "aws_iam_policy_document" "stfn_invoke_lambda_policy" {
  statement {
    effect = "Allow"

    actions = ["lambda:InvokeFunction"]

    resources = [ # reference the arn output of the lambda functions
      module.lambda_functions.lambda_src_to_s3_raw_arn,
      module.lambda_functions.lambda_s3raw_to_s3staging_arn,
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_google_form_feedback",
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_customers_processing_func",
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_orders_processing_func",
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_purchase_orders_processing_func",
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_inventory_processing_func",
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_departments_processing_func",
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_suppliers_processing_func",
      "arn:aws:lambda:eu-north-1:996136076782:function:lambda_products_processing_func"
    ]
  }
}


# Create step function execution role and attach the IAM policy to the step function execution role-- Basic Execution policy attachment
resource "aws_iam_role" "stfn_execution_role" {
  name               = "stfn_execution_role"
  assume_role_policy = data.aws_iam_policy_document.stfn_execution_policy.json
}


# Attach the lambda invocation policy to the created step function execution role-- lambda invocation policy attachment
resource "aws_iam_role_policy" "stfn_invoke_lambda_policy_attachment" {
  name = "stfn_invoke_lambda_policy_attachment"
  role = aws_iam_role.stfn_execution_role.name
  policy = data.aws_iam_policy_document.stfn_invoke_lambda_policy.json
}


# Deploy the state machine
resource "aws_sfn_state_machine" "stfn_state_machine" {
  name     = "OrchestrateLambdaFunctions"
  role_arn = aws_iam_role.stfn_execution_role.arn
  definition = templatefile("${path.module}/stfn.asl.json",{
        s3_bucket        = var.s3_bucket
        s3_raw_prefix = "raw"
        s3_staging_prefix = "staging"
        date_suffix =  "2024-10-01"
        redshift_db_password = var.redshift_db_password
        db_password = var.db_password
  })
}