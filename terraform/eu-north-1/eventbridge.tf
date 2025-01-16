# IAM policy to allow EventBridge to invoke Step Functions state machine
data "aws_iam_policy_document" "eventbridge_invoke_stfn_policy" {
  statement {
    effect    = "Allow"
    actions   = ["states:StartExecution"]
    resources = [aws_sfn_state_machine.stfn_state_machine.arn] 
  }
}


# IAM policy for EventBridge to assume roles that will be created for it to assume
data "aws_iam_policy_document" "eventbridge_execution_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


# Create EventBridge execution role and attach the IAM policy to the EventBridge execution role
resource "aws_iam_role" "eventbridge_execution_role" {
  name               = "eventbridge_execution_role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_execution_policy.json
}


# Attach the Step Function invocation policy to the created EventBridge execution role
resource "aws_iam_role_policy" "eventbridge_invoke_stfn_policy_attachment" {
  name   = "eventbridge_invoke_stfn_policy_attachment"
  role   = aws_iam_role.eventbridge_execution_role.name
  policy = data.aws_iam_policy_document.eventbridge_invoke_stfn_policy.json
}


# EventBridge Rule for scheduling the Step Function
resource "aws_cloudwatch_event_rule" "schedule_step_function" {
  name                = "ScheduleStepFunction"
  description         = "This EventBridge rule schedules the execution of Step Functions to run the Lambda Functions in sequence."  
  schedule_expression = "cron(41 17 1 10 ? 2024)"

}


# Add the Step Functions as the target for the EventBridge Rule
resource "aws_cloudwatch_event_target" "step_function_target" {
  rule      = aws_cloudwatch_event_rule.schedule_step_function.name
  target_id = "StepFunctionTarget"
  arn       = aws_sfn_state_machine.stfn_state_machine.arn  
  role_arn  = aws_iam_role.eventbridge_execution_role.arn  # IAM Role to allow EventBridge to invoke Step Functions
}