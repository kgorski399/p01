resource "aws_cloudwatch_event_rule" "farm_state_machine_schedule" {
  name                = "FarmStateMachineSchedule"
  description         = "Wywołuje maszynę stanów FarmStateMachine co 5 minut"
  schedule_expression = "cron(*/5 * * * ? *)"
}

resource "aws_iam_role" "eventbridge_role" {
  name = "EventBridgeInvokeStepFunctionRole"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "events.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "EventBridgeInvokeStepFunctionPolicy"
  role = aws_iam_role.eventbridge_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "states:StartExecution",
        "Resource" : "${aws_sfn_state_machine.farm_state_machine.arn}"
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "farm_state_machine_target" {
  rule      = aws_cloudwatch_event_rule.farm_state_machine_schedule.name
  target_id = "FarmStateMachine"
  arn       = aws_sfn_state_machine.farm_state_machine.arn
  role_arn  = aws_iam_role.eventbridge_role.arn
}
